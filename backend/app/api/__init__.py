"""HTTP routers (contract: docs/API.md).

Routers are deliberately thin: validate the request, call one module seam
(``app.ai.pipeline``, ``app.images.service``, ``app.places``, ``app.swaps``) and return its
response model. Seams are looked up on their module at call time, so tests can swap them.
"""
