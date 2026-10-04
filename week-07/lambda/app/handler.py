"""Week 7 demo function: estimate how many tokens a message will cost.

Everything at module level runs ONCE per execution environment (the INIT phase,
a.k.a. the cold start). Everything inside handler() runs on EVERY invocation.

Request fields (all optional):
  message  text to estimate
  sleep    seconds to sleep, to trip the function timeout
  work     sha256 rounds to burn CPU, to show that memory is the CPU knob
"""

import base64
import hashlib
import json
import time
import uuid

ENV_ID = uuid.uuid4().hex[:8]  # a new value means a new execution environment
INIT_AT = time.time()
INVOCATIONS = 0  # survives between warm invocations, gone after a cold start


def _parse(event: dict) -> tuple[dict, bool]:
    """A direct invoke sends the request itself. API Gateway (payload 2.0)
    wraps the HTTP request, with the body as a string."""
    if "requestContext" not in event:
        return event, False
    body = event.get("body") or "{}"
    if event.get("isBase64Encoded"):
        body = base64.b64decode(body).decode()
    return json.loads(body), True


def _respond(result: dict, via_http: bool, status: int = 200) -> dict:
    if not via_http:
        return result
    return {
        "statusCode": status,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(result),
    }


def handler(event, context):
    global INVOCATIONS
    INVOCATIONS += 1

    try:
        req, via_http = _parse(event)
    except (json.JSONDecodeError, UnicodeDecodeError):
        return _respond({"error": "body must be JSON"}, True, 400)

    if req.get("sleep"):
        time.sleep(float(req["sleep"]))

    digest = b""
    for _ in range(min(int(req.get("work", 0)), 20_000_000)):
        digest = hashlib.sha256(digest).digest()

    words = len(str(req.get("message", "")).split())
    return _respond(
        {
            "words": words,
            "tokens_estimate": round(words * 4 / 3),  # rule of thumb: ~0.75 words per token
            "cold_start": INVOCATIONS == 1,
            "env_id": ENV_ID,
            "invocations_in_env": INVOCATIONS,
            "env_age_s": round(time.time() - INIT_AT, 1),
            "memory_mb": int(context.memory_limit_in_mb),
            "request_id": context.aws_request_id,
        },
        via_http,
    )
