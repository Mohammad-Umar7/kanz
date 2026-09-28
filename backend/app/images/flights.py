"""In-flight de-duplication: one render per cache key, however many callers ask for it.

The app asks for step 3 while the background chain is still rendering step 2, and the
results screen asks for three after images while the tutorial screen may ask for the
same one. Rendering a picture twice wastes quota and, worse, can produce two different
pictures for the same key. ``SingleFlight`` runs the first caller's coroutine as a task
and lets every concurrent caller await that same task.

The task is shielded: if one HTTP client disconnects, its request is cancelled but the
render carries on for the others and still lands in the cache.
"""

from __future__ import annotations

import asyncio
from collections.abc import Awaitable, Callable
from typing import Generic, TypeVar

T = TypeVar("T")


class SingleFlight(Generic[T]):
    def __init__(self) -> None:
        self._tasks: dict[str, asyncio.Task[T]] = {}

    def running(self, key: str) -> bool:
        """True while a render for ``key`` is in flight."""
        task = self._tasks.get(key)
        return task is not None and not task.done()

    def __len__(self) -> int:
        return sum(1 for t in self._tasks.values() if not t.done())

    async def run(self, key: str, factory: Callable[[], Awaitable[T]]) -> T:
        """Await the in-flight task for ``key``, starting ``factory()`` if there is none."""
        task = self._tasks.get(key)
        if task is None or task.done():
            task = asyncio.ensure_future(factory())
            self._tasks[key] = task
            task.add_done_callback(lambda t, k=key: self._finished(k, t))
        return await asyncio.shield(task)

    def cancel_all(self) -> list[asyncio.Task[T]]:
        """Cancel every in-flight task (server shutdown) and return them so the caller can await them."""
        running = [t for t in self._tasks.values() if not t.done()]
        for task in running:
            task.cancel()
        return running

    def _finished(self, key: str, task: asyncio.Task[T]) -> None:
        if self._tasks.get(key) is task:
            del self._tasks[key]
        # Mark the outcome as retrieved: if every waiter was cancelled, nobody else will.
        if not task.cancelled():
            task.exception()
