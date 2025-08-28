#!/usr/bin/env bash
set -euo pipefail

# Start Ollama in the background
/bin/ollama serve &
# Give it a moment to boot (optional)
sleep 2

# (Optional) pull a small model in background to avoid blocking startup
# nohup /bin/ollama pull llama3.2:1b >/dev/null 2>&1 &

# Start FastAPI — must bind to $PORT on Render
exec uvicorn app:app --host 0.0.0.0 --port "${PORT:-10000}"
