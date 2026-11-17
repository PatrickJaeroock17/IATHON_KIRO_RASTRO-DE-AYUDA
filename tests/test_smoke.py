import json

from handlers.api import handler


def _event(method: str, path: str) -> dict:
    return {"rawPath": path, "requestContext": {"http": {"method": method}}}


def test_health_returns_ok_and_team(monkeypatch):
    monkeypatch.setenv("TEAM_ID", "T009")
    response = handler(_event("GET", "/health"))
    assert response["statusCode"] == 200
    assert json.loads(response["body"]) == {"status": "ok", "team": "T009"}


def test_app_serves_html_without_redirect():
    response = handler(_event("GET", "/app"))
    assert response["statusCode"] == 200
    assert response["headers"]["Content-Type"].startswith("text/html")
    assert "Rastro de Ayuda" in response["body"]


def test_unknown_route_returns_404():
    assert handler(_event("GET", "/no-existe"))["statusCode"] == 404
