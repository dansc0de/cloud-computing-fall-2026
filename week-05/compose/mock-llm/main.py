"""A stand-in for a real model server.

Same request and response shape as an OpenAI-compatible /v1/chat/completions
endpoint, so the proxy does not change when you swap in the real model.
"""

import time

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="mock-llm")


class Message(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    model: str = "mock"
    messages: list[Message]


def count_tokens(text: str) -> int:
    """Not a real tokenizer. Words are close enough to show metering."""
    return max(1, len(text.split()))


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/v1/chat/completions")
def completions(req: ChatRequest) -> dict:
    prompt = " ".join(m.content for m in req.messages)
    time.sleep(0.2)  # pretend to think
    reply = f"You said {count_tokens(prompt)} words. The real model would answer here."
    return {
        "id": "chatcmpl-mock",
        "model": req.model,
        "choices": [{"index": 0, "message": {"role": "assistant", "content": reply}}],
        "usage": {
            "prompt_tokens": count_tokens(prompt),
            "completion_tokens": count_tokens(reply),
            "total_tokens": count_tokens(prompt) + count_tokens(reply),
        },
    }
