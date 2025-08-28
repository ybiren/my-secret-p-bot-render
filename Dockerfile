# ---- Stage 1: install Ollama binary ----
FROM debian:bookworm-slim AS ollama_stage
RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://ollama.com/download/linux | sh  # installs /usr/local/bin/ollama

# ---- Final image ----
FROM python:3.11-slim

# Keep models under /app so you control persistence within the container
ENV PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    OLLAMA_MODELS=/app/.ollama

RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*

# Ollama binary
COPY --from=ollama_stage /usr/local/bin/ollama /usr/local/bin/ollama

WORKDIR /app

# Python deps first (better layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# App code + start script
COPY . .
RUN mkdir -p /app/.ollama \
 && chmod +x ./start.sh \
 && sed -i 's/\r$//' ./start.sh

# (Optional) helpful for local runs; Render ignores EXPOSE for scanning
EXPOSE 8000

# Start (FastAPI must bind 0.0.0.0:$PORT)
CMD ["bash","-lc","./start.sh"]
