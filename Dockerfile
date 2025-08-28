# Dockerfile
FROM python:3.11-slim

ENV PIP_ROOT_USER_ACTION=ignore \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# FIX: path is relative to /app
RUN chmod +x ./start.sh

# Use shell form so $PORT expands on Render
CMD ["bash","-lc","./start.sh"]
