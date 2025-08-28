# Stage 1: get the Ollama binary
FROM ollama/ollama:latest AS ollama_stage

# Stage 2: Python runtime + Ollama binary
FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates bash tini && \
    rm -rf /var/lib/apt/lists/*

# Copy the binary and default models dir
COPY --from=ollama_stage /bin/ollama /usr/local/bin/ollama
COPY --from=ollama_stage /root/.ollama /root/.ollama

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt
COPY . .
RUN chmod +x /start.sh

ENV OLLAMA_HOST=0.0.0.0:11434 \
    PORT=10000

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
