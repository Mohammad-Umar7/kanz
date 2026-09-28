"""In-memory sliding-window rate limit per client IP on ``/v1/*``.

Each AI call spends shared Gemini quota, so one misbehaving client (a retry loop, a
stuck screen) must not starve everyone else. The limit counts requests in the last 60
seconds, not per calendar minute, so bursts at a minute boundary can't double it.

State lives in this process: run a single worker (see backend/README.md, "Deploy").
``/health`` and ``/static`` are not limited, so warm-up pings and image loads never count.
"""

from __future__ import annotations

import logging
import math
import time
from collections import deque
from collections.abc import Callable

from starlette.types import ASGIApp, Receive, Scope, Send

from app.core.error_handlers import kanz_error_response
from app.core.errors import RateLimited

log = logging.getLogger("kanz.ratelimit")


class SlidingWindowLimiter:
    """At most ``limit`` hits per ``window_s`` seconds for each key."""

    def __init__(
        self,
        limit: int,
        *,
        window_s: float = 60.0,
        clock: Callable[[], float] = time.monotonic,
        max_keys: int = 10_000,
    ) -> None:
        self.limit = limit
        self.window_s = window_s
        self._clock = clock
        self._max_keys = max_keys
        self._hits: dict[str, deque[float]] = {}

    def hit(self, key: str) -> float:
        """Record a request. Returns 0 if allowed, else the seconds until a slot frees up."""
        now = self._clock()
        cutoff = now - self.window_s
        hits = self._hits.get(key)
        if hits is None:
            if len(self._hits) >= self._max_keys:
                self._evict_idle(cutoff)
            hits = self._hits[key] = deque()
        while hits and hits[0] <= cutoff:
            hits.popleft()
        if len(hits) >= self.limit:
            return max(hits[0] + self.window_s - now, 0.001)
        hits.append(now)
        return 0.0

    def _evict_idle(self, cutoff: float) -> None:
        """Drop clients with no hits inside the window, so memory stays bounded."""
        for key in [k for k, hits in self._hits.items() if not hits or hits[-1] <= cutoff]:
            del self._hits[key]


class RateLimitMiddleware:
    """Answer ``429 rate_limited`` with ``Retry-After`` once a client exceeds the limit."""

    def __init__(self, app: ASGIApp, *, limiter: SlidingWindowLimiter, prefix: str = "/v1/") -> None:
        self.app = app
        self.limiter = limiter
        self.prefix = prefix

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if (
            scope["type"] == "http"
            and scope.get("method") != "OPTIONS"
            and scope.get("path", "").startswith(self.prefix)
        ):
            client = scope.get("client")
            key = client[0] if client else "unknown"
            wait_s = self.limiter.hit(key)
            if wait_s > 0:
                retry_after = str(max(1, math.ceil(wait_s)))
                log.info("rate_limited path=%s retry_after_s=%s", scope.get("path"), retry_after)
                response = kanz_error_response(RateLimited(), headers={"Retry-After": retry_after})
                await response(scope, receive, send)
                return
        await self.app(scope, receive, send)
