# hello-api

A tiny FastAPI service for the week 4 container demos. Managed with [uv](https://docs.astral.sh/uv/).

## Project files

| File | Purpose |
|---|---|
| `pyproject.toml` | Project metadata, runtime dependencies, dev dependency group, pytest config |
| `uv.lock` | Exact resolved versions of every package. Commit it. The Dockerfile builds with `--frozen`, which requires it |
| `.python-version` | Tells uv which Python to use locally (3.12, matching `python:3.12-slim`) |
| `main.py` | The app |
| `tests/test_main.py` | pytest tests |
| `Dockerfile` / `Dockerfile.slow` | Fast vs slow layer ordering for the caching demo |
| `.dockerignore` / `.gitignore` | Keep `.venv`, caches, and secrets out of images and git |

## Run it locally (no Docker)

```bash
uv sync                                  # create .venv from uv.lock (includes dev group)
uv run pytest -v                         # 4 tests
uv run uvicorn main:app --reload --port 8080
curl -s localhost:8080/ ; echo
```

Locally, `pid` will be a normal process ID and `uid` will be yours. In the container they become `1` and a non-root UID. That contrast is the demo.

## Everyday uv commands

```bash
uv add fastapi                           # add a runtime dependency (updates pyproject.toml + uv.lock)
uv add --dev pytest                      # add to the dev group
uv remove httpx                          # remove a dependency
uv lock                                  # re-resolve uv.lock after editing pyproject.toml by hand
uv lock --check                          # CI check: fails if uv.lock is stale
uv sync --frozen --no-dev                # exactly what the Dockerfile runs: lock as-is, no dev tools
uv tree                                  # dependency tree
uv python list                           # Pythons uv can see
```

## Build and run the container

```bash
docker build -t hello-api .
docker run -d --name api -p 8080:8080 hello-api
curl -s localhost:8080/ ; echo
```

See `../README.md` for the full lecture demo sequence.
