# ---- Stage 1: install Ollama binary ----
FROM debian:bookworm-slim AS ollama_stage
RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://ollama.com/download/linux | sh
# installs /usr/local/bin/ollama

# ---- Final image ----
FROM python:3.11-slim

ENV PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    OLLAMA_MODELS=/app/.ollama  # keep models under /app

RUN apt-get update && apt-get install -y libgomp1 && rm -rf /var/lib/apt/lists/*

COPY --from=ollama_stage /usr/local/bin/ollama /usr/local/bin/ollama

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN mkdir -p /app/.ollama && chmod +x ./start.sh && sed -i 's/\r$//' ./start.sh

CMD ["bash","-lc","./start.sh"]
