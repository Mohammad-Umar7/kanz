"""Image generation: after images, the tutorial step chain and bin images.

Modules:
    service    the public seam (after_image, step_image, bin_image, start_step_chain),
               caching, in-flight de-duplication, concurrency and the background chain
    director   the Image Director: composes prompts from backend/prompts/image_*.md
    templates  the versioned prompt template format
    framing    aspect ratio matching and item crops
    flights    SingleFlight, one render per cache key
"""
