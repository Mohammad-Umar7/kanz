# Kanz API container image.
#
#   docker build -t kanz-api backend
#   docker run -p 8000:8000 --env-file backend/.env -v kanz-data:/srv/kanz/data kanz-api
#
# In production it runs behind the platform's HTTPS proxy (Cloud Run, Render, Fly.io).
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PORT=8000 \
    FORWARDED_ALLOW_IPS="*"

WORKDIR /srv/kanz

# Dependencies first, so a code change doesn't reinstall them.
COPY requirements.txt .
RUN pip install -r requirements.txt

RUN useradd --create-home --uid 10001 kanz
COPY app/ app/
COPY prompts/ prompts/
COPY knowledge/ knowledge/
COPY config/ config/
RUN mkdir -p data && chown kanz:kanz data

USER kanz
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
    CMD python -c "import os, urllib.request; urllib.request.urlopen(f'http://127.0.0.1:{os.environ[\"PORT\"]}/health', timeout=4)"

# One worker: the rate limiter and caches live in process memory.
# --proxy-headers takes the client IP from the platform proxy (FORWARDED_ALLOW_IPS above),
# so the per-client rate limit sees real phones, not the proxy.
CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port \"$PORT\" --proxy-headers"]
