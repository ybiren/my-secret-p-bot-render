#!/usr/bin/env bash
set -euo pipefail

# Which FastAPI module to run (override in Render env if needed)
APP_MODULE="${APP_MODULE:-app:app}"   # e.g. change to fastapi_app.main:app
PORT="${PORT:-10000}"

# Start Ollama in background ONLY if installed; never block web startup
if command -v ollama >/dev/null 2>&1; then
  echo "Starting Ollama in background..."
  (ollama serve >/tmp/ollama.log 2>&1 &) || true
  # Optional: non-blocking wait loop if your app needs Ollama later
  # (while ! nc -z 127.0.0.1 11434; do sleep 0.2; done) &>/dev/null || true
else
  echo "Ollama not found; skipping."
fi

echo "Launching Uvicorn: $APP_MODULE on 0.0.0.0:$PORT"
exec uvicorn "$APP_MODULE" --host 0.0.0.0 --port "$PORT"
