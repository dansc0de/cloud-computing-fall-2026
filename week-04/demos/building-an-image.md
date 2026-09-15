# Demo 3: Building an image

A small FastAPI app managed with uv. `Dockerfile` installs dependencies before copying code; `Dockerfile.slow` does it the other way around.

## Build and run

```bash
cat Dockerfile
docker build -t hello-api .
docker images hello-api
docker history hello-api

docker run --rm -d --name hello-api -p 8080:8080 hello-api
curl -s localhost:8080/ | jq
```

- `hostname` is the container ID (UTS namespace)
- `pid` is 1 (PID namespace)
- `uid` is not 0 (`USER app`)

## Layer cache

```bash
docker build -t hello-api .                             # everything CACHED
# change main.py code
docker build -t hello-api .                             # dependencies still CACHED

docker build -f Dockerfile.slow -t hello-api:slow .
# change main.py code
docker build -f Dockerfile.slow -t hello-api:slow .     # uv sync runs again
```

## Ports

```bash
docker run -d --name no-publish hello-api
docker port no-publish                                  # empty: EXPOSE publishes nothing

docker run -d --name broken -p 8081:8080 hello-api \
  uvicorn main:app --host 127.0.0.1 --port 8080
curl -s localhost:8081/ || echo "failed"                # app only listens on the container's localhost

docker exec broken python -c \
  "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8080/health').read())"
```

## Cleanup

```bash
docker rm -f api no-publish broken
docker image rm hello-api hello-api:slow
```