# app.py
import os, requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()
OLLAMA = os.getenv("OLLAMA_BASE_URL", "http://ollama:11434")

# Enable CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"message": "Hello, world!"}

@app.post("/echo")
def echo(data: dict):
    return {"you_sent": data}

@app.get("/complete")
def complete(prompt: str = "Hello"):
    r = requests.post(f"{OLLAMA}/api/generate",
                      json={"model": "llama3.2:1b", "prompt": prompt})
    r.raise_for_status()
    return r.json()
