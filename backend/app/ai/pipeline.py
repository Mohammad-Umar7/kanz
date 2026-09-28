"""LangGraph pipelines behind /v1/analyze, /v1/recommend and /v1/tutorial. Owned by AI Pipeline.

Public seam (keep these signatures):

    async def analyze(*, image: bytes | None, text: str | None, lang: str) -> AnalyzeResponse
    async def recommend(req: RecommendRequest) -> RecommendResponse
    async def tutorial(req: TutorialRequest) -> TutorialResponse
"""
