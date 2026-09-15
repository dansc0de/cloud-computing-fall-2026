"""hello-api: the week 4 demo service.

Every field in the response maps to a Block A concept:
  hostname -> UTS namespace (Docker sets it to the container ID)
  pid      -> PID namespace (uvicorn is PID 1 inside the container)
  uid      -> USER in the Dockerfile (not 0, so not root)
"""

import os
import socket

from fastapi import FastAPI

app = FastAPI(title="hello-api")

MESSAGE = "Hello from ITCC"


@app.get("/")
def root() -> dict:
    return {
        "message": MESSAGE,
        "hostname": socket.gethostname(),
        "pid": os.getpid(),
        "uid": os.getuid(),
    }


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
