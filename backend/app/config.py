"""Runtime configuration, loaded from environment variables and ``backend/.env``.

Every model id lives here (never hardcoded in nodes). Current ids are listed at
https://ai.google.dev/gemini-api/docs/models ; override any of them in ``.env``.
"""

from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_DIR = Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=BACKEND_DIR / ".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "Kanz"
    version: str = "1.0.0"
    environment: str = Field(default="development", description="development | production")

    # --- Secrets (only ever in .env / the host's secret store) ---
    gemini_api_key: str = ""
    google_maps_api_key: str = ""

    # --- Gemini models, by role ---
    model_vision: str = "gemini-3.6-flash"  # Material Analyst (multimodal, structured output)
    model_text: str = "gemini-3.6-flash"  # Designers, advisors, tutorial writer
    model_fallbacks: list[str] = ["gemini-3.5-flash", "gemini-flash-latest", "gemini-3.1-flash-lite"]
    thinking_level: str = "low"  # minimal | low | medium | high; low keeps latency inside targets
    model_image: str = "gemini-3.1-flash-image"  # native image editing ("Nano Banana 2")
    model_image_fallback: str = "gemini-3.1-flash-lite-image"
    model_embed: str = "gemini-embedding-001"
    embed_dim: int = 768

    # --- Image generation ---
    image_aspect_ratio: str = "4:3"
    image_size: str = "1K"
    step_images_autostart: bool = True  # start the step chain in the background when a tutorial is created

    # --- Timeouts (seconds) and retries ---
    timeout_vision_s: float = 25.0
    timeout_text_s: float = 30.0
    timeout_image_s: float = 90.0
    timeout_embed_s: float = 20.0
    llm_retries: int = 2  # extra attempts on 429/5xx, with exponential backoff

    # --- Places ---
    overpass_url: str = "https://overpass-api.de/api/interpreter"
    places_timeout_s: float = 12.0

    # --- HTTP server ---
    cors_origins: list[str] = ["*"]
    rate_limit_per_minute: int = 90  # per client IP, across /v1
    max_upload_mb: int = 10
    public_base_url: str = ""  # optional absolute prefix for returned URLs; relative paths when empty
    log_level: str = "INFO"

    # --- Paths ---
    data_dir: Path = BACKEND_DIR / "data"
    knowledge_dir: Path = BACKEND_DIR / "knowledge"
    prompts_dir: Path = BACKEND_DIR / "prompts"
    config_dir: Path = BACKEND_DIR / "config"

    @property
    def ai_configured(self) -> bool:
        return bool(self.gemini_api_key.strip())

    @property
    def places_google_configured(self) -> bool:
        return bool(self.google_maps_api_key.strip())

    @property
    def uploads_dir(self) -> Path:
        return self.data_dir / "uploads"

    @property
    def generated_dir(self) -> Path:
        return self.data_dir / "generated"

    @property
    def chroma_dir(self) -> Path:
        return self.data_dir / "chroma"

    @property
    def tutorials_dir(self) -> Path:
        return self.data_dir / "tutorials"


@lru_cache
def get_settings() -> Settings:
    return Settings()
