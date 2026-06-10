#!/bin/bash
# macos-voice.sh — Run Da She's TTS server on macOS (Apple Silicon)
# One command: bash <(curl -sL https://raw.githubusercontent.com/Jeremiah-Crouse/rapper/master/macos-voice.sh)

set -e
echo "=== Da She Voice Server for macOS ==="

# Install Python 3.10 if needed
if ! command -v python3.10 &>/dev/null; then
  if command -v brew &>/dev/null; then
    brew install python@3.10
  else
    echo "Install Homebrew first: https://brew.sh"
    exit 1
  fi
fi

# Setup venv
cd ~/Desktop
mkdir -p dashe-voice
cd dashe-voice
python3.10 -m venv venv
source venv/bin/activate

# Install TTS + flask
pip install -q TTS flask flask-cors 2>&1 | tail -3

# Download speaker sample
curl -sL -o speaker.wav "https://qwert.crousia.com/speaker.wav"
echo "Speaker: $(wc -c < speaker.wav) bytes"

# Install localtunnel
npm install -g localtunnel 2>/dev/null || sudo npm install -g localtunnel

# Start server
cat > server.py << 'PYEOF'
from flask import Flask, request, send_file
from TTS.api import TTS
import torch, tempfile, os, threading

has_gpu = torch.cuda.is_available() and torch.backends.mps.is_available()
device = "mps" if has_gpu else "cpu"
print(f"GPU: {has_gpu}  Device: {device}")

tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=has_gpu)
app = Flask(__name__)

@app.route("/health")
def health(): return {"status":"ok","gpu":has_gpu}

@app.route("/synthesize", methods=["POST"])
def synth():
    text = request.get_json().get("text","")
    fd, path = tempfile.mkstemp(suffix=".wav"); os.close(fd)
    tts.tts_to_file(text=text, file_path=path, speaker_wav="speaker.wav", language="en")
    return send_file(path, mimetype="audio/wav")

threading.Thread(target=lambda: app.run(host="0.0.0.0", port=5000, debug=False), daemon=True).start()
print("Server on :5000")
import time
while True: time.sleep(60)
PYEOF

echo "Starting server..."
python3 server.py &
sleep 5

# Start tunnel
echo "Starting tunnel..."
lt --port 5000 &
sleep 3
echo ""
echo "=========================================="
echo "MACOS GPU ENDPOINT"
echo "Run: curl https://YOUR-URL.loca.lt/health"
echo "=========================================="
echo ""
echo "Keep this terminal open. Close = server stops."
wait
