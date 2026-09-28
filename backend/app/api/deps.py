"""FastAPI dependencies shared by the routers."""

from typing import Annotated

from fastapi import Depends, Request

from app.config import Settings


def app_settings(request: Request) -> Settings:
    """The settings the running app was created with (``create_app(settings)``)."""
    return request.app.state.settings


SettingsDep = Annotated[Settings, Depends(app_settings)]
