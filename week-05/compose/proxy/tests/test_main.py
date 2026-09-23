from fastapi.testclient import TestClient

from main import USAGE, app

client = TestClient(app)


def test_health():
    assert client.get("/health").json()["status"] == "ok"


def test_usage_starts_at_zero():
    body = client.get("/usage/nobody").json()
    assert body["request_count"] == 0
    assert body["prompt_tokens"] == 0


def test_chat_reports_model_unreachable():
    """With no model running, the proxy should say so instead of crashing."""
    assert client.post("/chat", json={"user": "u", "message": "hi"}).status_code == 502


def test_usage_accumulates():
    USAGE["counted"]["prompt_tokens"] += 5
    USAGE["counted"]["request_count"] += 1
    body = client.get("/usage/counted").json()
    assert body["prompt_tokens"] == 5
    assert body["request_count"] == 1
