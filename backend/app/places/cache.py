"""A small in-process TTL cache for facility searches.

Drop-off points do not move, and the app asks for the same area repeatedly (results
screen, Drop-off tab, filter changes), so merged provider results are kept for ten
minutes. Keys use coordinates rounded to about 100 m. Distances are always recomputed
from the caller's exact position.
"""

from __future__ import annotations

import time
from collections import OrderedDict
from typing import Generic, TypeVar

V = TypeVar("V")

DEFAULT_TTL_S = 600.0


class TtlCache(Generic[V]):
    def __init__(self, max_entries: int = 256) -> None:
        self._data: OrderedDict[object, tuple[float, V]] = OrderedDict()
        self._max = max_entries

    def get(self, key: object) -> V | None:
        hit = self._data.get(key)
        if hit is None:
            return None
        expires, value = hit
        if expires < time.monotonic():
            del self._data[key]
            return None
        self._data.move_to_end(key)
        return value

    def put(self, key: object, value: V, ttl_s: float = DEFAULT_TTL_S) -> None:
        self._data[key] = (time.monotonic() + ttl_s, value)
        self._data.move_to_end(key)
        while len(self._data) > self._max:
            self._data.popitem(last=False)

    def clear(self) -> None:
        self._data.clear()

    def __len__(self) -> int:
        return len(self._data)
