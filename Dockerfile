FROM python:3.11-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates bash tini && \
    rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash

# App deps
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt

# App code + start script
COPY . .
RUN chmod +x /start.sh

ENV OLLAMA_HOST=0.0.0.0:11434 \
    PORT=10000

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"]
