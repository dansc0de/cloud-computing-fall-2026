# Fast build: dependencies are installed before the code is copied,
# so editing main.py only rebuilds the last few layers.
FROM python:3.14-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
# Use the image's Python. Never download one: a uv-managed Python lands in
# /root, which the non-root app user cannot read at runtime.
ENV UV_PYTHON=/usr/local/bin/python3.14 \
    UV_PYTHON_DOWNLOADS=never
WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project
COPY . .
RUN uv sync --frozen --no-dev

ENV PATH="/app/.venv/bin:$PATH"
RUN useradd --create-home app
USER app
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]