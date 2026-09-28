"""Per-stage latency measurement.

Every pipeline stage runs inside ``stage_timer(timings, "analysis")``; the elapsed
milliseconds land in the response's ``timings_ms`` and in the log, e.g.
``stage=analysis ms=4120 ok=True``. Targets: analysis < 6 s, ideas < 8 s, tutorial < 10 s.
"""

import logging
import time
from collections.abc import Iterator
from contextlib import contextmanager

log = logging.getLogger("kanz.timing")


@contextmanager
def stage_timer(timings: dict[str, int] | None, stage: str) -> Iterator[None]:
    start = time.perf_counter()
    ok = False
    try:
        yield
        ok = True
    finally:
        ms = int((time.perf_counter() - start) * 1000)
        if timings is not None:
            timings[stage] = ms
        log.info("stage=%s ms=%d ok=%s", stage, ms, ok)
