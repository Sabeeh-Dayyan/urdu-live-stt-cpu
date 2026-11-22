# CPU image (Linux x86_64). Build: docker build -t live-stt:cpu .
# Server deployment: deploy/docker-compose.yml (docs/DEPLOYMENT.md).
FROM python:3.11-slim-bookworm
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH=/opt/venv/bin:$PATH PYTHONPATH=/app/src
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir uv==0.13.9
WORKDIR /app
COPY pyproject.toml uv.lock README.md ./
RUN uv sync --frozen --no-dev --no-install-project --extra bench
COPY src ./src
COPY config ./config
COPY ui ./ui
COPY bench ./bench
COPY infra ./infra
# Models are mounted at /app/models (see RUNBOOK); not baked into the image.
EXPOSE 8000 9100-9130
ENTRYPOINT ["python", "-m", "live_stt.cli"]
CMD ["supervise", "-c", "config/server-cpu.yaml"]
