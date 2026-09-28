"""SingleFlight: one run per key, shared by every concurrent caller."""

import asyncio

import pytest

from app.images.flights import SingleFlight


async def test_concurrent_callers_share_one_run() -> None:
    flights: SingleFlight[str] = SingleFlight()
    runs = 0

    async def work() -> str:
        nonlocal runs
        runs += 1
        await asyncio.sleep(0.01)
        return "done"

    results = await asyncio.gather(*(flights.run("k", work) for _ in range(5)))
    assert results == ["done"] * 5
    assert runs == 1
    assert not flights.running("k")
    assert len(flights) == 0


async def test_errors_reach_every_waiter_and_the_next_call_runs_again() -> None:
    flights: SingleFlight[str] = SingleFlight()
    attempts = 0

    async def flaky() -> str:
        nonlocal attempts
        attempts += 1
        await asyncio.sleep(0.01)
        if attempts == 1:
            raise RuntimeError("boom")
        return "ok"

    results = await asyncio.gather(flights.run("k", flaky), flights.run("k", flaky), return_exceptions=True)
    assert all(isinstance(r, RuntimeError) for r in results)
    assert await flights.run("k", flaky) == "ok"
    assert attempts == 2


async def test_a_cancelled_waiter_does_not_cancel_the_shared_run() -> None:
    flights: SingleFlight[str] = SingleFlight()
    release = asyncio.Event()

    async def slow() -> str:
        await release.wait()
        return "kept"

    first = asyncio.create_task(flights.run("k", slow))
    second = asyncio.create_task(flights.run("k", slow))
    await asyncio.sleep(0)
    first.cancel()
    with pytest.raises(asyncio.CancelledError):
        await first
    assert flights.running("k")
    release.set()
    assert await second == "kept"


async def test_different_keys_run_independently() -> None:
    flights: SingleFlight[str] = SingleFlight()

    async def value(v: str) -> str:
        await asyncio.sleep(0)
        return v

    assert await asyncio.gather(flights.run("a", lambda: value("a")), flights.run("b", lambda: value("b"))) == [
        "a",
        "b",
    ]
