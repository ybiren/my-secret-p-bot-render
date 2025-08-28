# --- Stage 1: Preload Ollama model(s) into the image ---
FROM ollama/ollama:latest AS ollama_stage

# Pre-pull your model(s) so they’re baked into the image layer.
# Change/duplicate the line below for different models.
# Examples: "llama3.2:3b", "qwen2.5:3b", "bge-m3", etc.
RUN ollama serve & \
    sleep 6 && \
    ollama pull qwen2.5:3b && \
    pkill ollama

# --- Stage 2: App runtime (Python + Ollama binary + preloaded models) ---
FROM python:3.11-slim AS runtime

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates bash tini && \
    rm -rf /var/lib/apt/lists/*

# Copy Ollama binary and the preloaded models from stage 1
COPY --from=ollama_stage /bin/ollama /bin/ollama
COPY --from=ollama_stage /root/.ollama /root/.ollama

# Environment for Ollama + Render
ENV OLLAMA_HOST=0.0.0.0 \
    OLLAMA_MODELS=/root/.ollama/models \
    PORT=10000

# App setup
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your FastAPI app (ensure "main.py" has `app = FastAPI()` inside)
COPY . .

# Start script to run Ollama and Uvicorn together
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Use tini as PID 1 so background processes are reaped correctly
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
