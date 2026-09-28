"""Image pipeline (after images, step chain, bin image). Owned by the Image Generation workstream.

Public seam (keep these signatures):

    async def after_image(req: AfterImageRequest) -> ImageResponse
    async def step_image(req: StepImageRequest) -> ImageResponse
    async def bin_image(req: BinImageRequest) -> ImageResponse
    def start_step_chain(tutorial: Tutorial) -> None   # fire-and-forget background generation
"""
