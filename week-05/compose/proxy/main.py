"""The service students actually call.

It takes a chat request, forwards it to the model service, and keeps a
running count of the tokens each user has spent.

Two lines matter for the rest of the semester:
  LLM_URL   in Compose this is http://llm:8000 (a service name)
            on Fargate  this is http://localhost:8000 (a sidecar container)
  USAGE     an in-memory dict, so it resets every time the container
            restarts. That is the problem a database solves later.
"""

import os
import socket
from collections import defaultdict

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

LLM_URL = os.environ.get("LLM_URL", "http://llm:8000")

app = FastAPI(title="proxy llm")

USAGE: dict[str, dict[str, int]] = defaultdict(
    lambda: {"prompt_tokens": 0, "completion_tokens": 0, "request_count": 0}
)


class ChatRequest(BaseModel):
    user: str = "student"
    message: str


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "hostname": socket.gethostname()}


@app.get("/usage/{user}")
def usage(user: str) -> dict:
    return {"user": user, **USAGE[user]}


@app.post("/chat")
def chat(req: ChatRequest) -> dict:
    try:
        resp = httpx.post(
            f"{LLM_URL}/v1/chat/completions",
            json={"model": "mock", "messages": [{"role": "user", "content": req.message}]},
            timeout=30,
        )
        resp.raise_for_status()
    except httpx.HTTPError as err:
        raise HTTPException(status_code=502, detail=f"model unreachable: {err}") from err

    body = resp.json()
    reply = body["choices"][0]["message"]["content"]
    used = body["usage"]

    counters = USAGE[req.user]
    counters["prompt_tokens"] += used["prompt_tokens"]
    counters["completion_tokens"] += used["completion_tokens"]
    counters["request_count"] += 1

    return {"reply": reply, "usage": used, "served_by": socket.gethostname()}
