#!/usr/bin/env bash
set -euo pipefail

# Start Ollama in background
/bin/ollama serve &
# (Optional) give it a moment to boot
sleep 2

# If you want to ensure a model exists at runtime (if not baked), uncomment:
# /bin/ollama pull qwen2.5:3b || true

# Start FastAPI (listening on the Render-assigned PORT=10000)
exec uvicorn main:app --host 0.0.0.0 --port "${PORT:-10000}"
