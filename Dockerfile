FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

WORKDIR /app

# bytecode compilation for faster cold starts on Cloud Run
ENV UV_COMPILE_BYTECODE=1
# Use 'copy' instead of hardlinks for multi-stage copy safety
ENV UV_LINK_MODE=copy

# 1. Mount cache for faster rebuilds, sync dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev --python 3.12

# 2. Add source and sync project
ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --python 3.12


# --- FINAL STAGE ---
FROM python:3.12-slim-bookworm

WORKDIR /app

# SRE Best Practice: Run as non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy the environment from builder
# Ensure it's owned by appuser immediately
COPY --from=builder --chown=appuser:appuser /app/.venv /app/.venv

# Ensure PATH is set to find uvicorn and other binaries
ENV PATH="/app/.venv/bin:$PATH"

# Copy the rest of the app with correct ownership
COPY --chown=appuser:appuser . /app

USER appuser

# GCP Cloud Run expects the app to listen on the port, we default to 8080
CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8080"]
