import json
import os
from pathlib import Path

WEB_DIR = Path(__file__).resolve().parent.parent / "web"


def _response(status: int, body: str, content_type: str = "application/json") -> dict:
    return {
        "statusCode": status,
        "headers": {"Content-Type": content_type, "Cache-Control": "no-store"},
        "body": body,
    }


def _json(status: int, payload: dict) -> dict:
    return _response(status, json.dumps(payload, ensure_ascii=False))


def handler(event: dict, context: object = None) -> dict:
    method = event.get("requestContext", {}).get("http", {}).get("method", "GET")
    path = event.get("rawPath", "/")

    if method == "GET" and path == "/health":
        return _json(200, {"status": "ok", "team": os.environ.get("TEAM_ID", "")})

    if method == "GET" and path in ("/", "/app", "/app/"):
        html = (WEB_DIR / "index.html").read_text(encoding="utf-8")
        return _response(200, html, "text/html; charset=utf-8")

    return _json(404, {"error": "No encontrado"})
