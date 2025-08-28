# ---- Stage 1: install Ollama binary ----
FROM debian:bookworm-slim AS ollama_stage
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://ollama.com/install.sh | sh   # installs /usr/local/bin/ollama

# ---- Final image ----
FROM python:3.11-slim

ENV PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    OLLAMA_MODELS=/app/.ollama \
    OLLAMA_HOST=0.0.0.0:11434 \
    PORT=10000

# runtime deps: bash for start.sh, tini for PID 1, libgomp1 for some models
RUN apt-get update && apt-get install -y --no-install-recommends bash tini libgomp1 \
 && rm -rf /var/lib/apt/lists/*

# Ollama binary
COPY --from=ollama_stage /usr/local/bin/ollama /usr/local/bin/ollama

WORKDIR /app

# deps first = better layer cache
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt

# app code + start script
COPY . .
RUN mkdir -p /app/.ollama \
 && chmod +x ./start.sh \
 && sed -i 's/\r$//' ./start.sh

# (EXPOSE is optional/ignored by Render health checks)
# EXPOSE 8000

# Use tini as PID 1; then run start.sh
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash", "-lc", "./start.sh"]
