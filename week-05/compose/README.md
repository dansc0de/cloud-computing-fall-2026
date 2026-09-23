# Demo 1: Docker Compose

Two containers: a `proxy` service that takes chat requests, and an `llm` service that answers them. The model is a stub, so the whole stack runs in your VM.

## Start the stack

```bash
cd compose
docker compose up --build        # leave it running so you can watch the logs
```

In a second terminal:

```bash
docker compose ps                # only proxy publishes a port
docker compose logs llm | tail
```

## Use it

```bash
curl -s localhost:8080/health

curl -s -X POST localhost:8080/chat \
  -H 'content-type: application/json' \
  -d '{"user": "team-01", "message": "hello from itcc"}'

curl -s localhost:8080/usage/team-01
```

Run the chat request a few more times and watch the counters climb. They live in memory inside the proxy, which is the point of the next experiment.

## Things to point out

```bash
# service names are DNS names on the Compose network
docker compose exec proxy python -c \
  "import urllib.request; print(urllib.request.urlopen('http://llm:8000/health').read())"

# the model has no published port, so this fails from the VM
curl -s --max-time 3 localhost:8000 || echo "not published, by design"

# depends_on with a healthcheck: proxy waited for llm to be healthy
docker inspect -f '{{.State.Health.Status}}' $(docker compose ps -q llm)

# what happens when a dependency disappears
docker compose stop llm
curl -s -X POST localhost:8080/chat -H 'content-type: application/json' \
  -d '{"user": "team-01", "message": "anyone home?"}'
docker compose start llm
```

## Restarting loses the counters

```bash
docker compose restart proxy
curl -s localhost:8080/usage/team-01   # back to zero
```

Containers are disposable, so anything you want to keep has to live outside the container. That is what volumes and databases are for, and we will need both later.

## Stop it

```bash
docker compose down
```

## Run the tests

```bash
cd proxy && uv run pytest -v
```
