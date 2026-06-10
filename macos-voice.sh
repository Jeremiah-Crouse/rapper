#!/bin/bash
set -e
echo "=== Da She Voice Server for macOS ==="

if ! command -v python3.10 &>/dev/null; then
  brew install python@3.10 2>/dev/null || echo "Need Python 3.10: brew install python@3.10"
fi

cd ~/Desktop && mkdir -p dashe-voice && cd dashe-voice
python3.10 -m venv venv 2>/dev/null || true
source venv/bin/activate 2>/dev/null || true
pip install -q TTS flask flask-cors 2>&1 | tail -1
curl -sL -o speaker.wav "https://qwert.crousia.com/speaker.wav"
echo "Speaker: $(wc -c < speaker.wav) bytes"
npm install -g localtunnel 2>/dev/null || sudo npm install -g localtunnel 2>/dev/null || true

# Ensure model files exist
MDIR="$HOME/Library/Application Support/tts/tts_models--multilingual--multi-dataset--xtts_v2"
mkdir -p "$MDIR"
touch "$MDIR/tos_agreed.txt"

# Download model if missing
if [ ! -f "$MDIR/model.pth" ]; then
  echo "Downloading model (1.9GB)..."
  curl -L -o "$MDIR/model.pth" 'https://qwert.crousia.com/xtts-v2/model.pth'
  curl -L -o "$MDIR/config.json" 'https://qwert.crousia.com/xtts-v2/config.json'
  curl -L -o "$MDIR/speakers_xtts.pth" 'https://qwert.crousia.com/xtts-v2/speakers_xtts.pth'
  curl -L -o "$MDIR/vocab.json" 'https://qwert.crousia.com/xtts-v2/vocab.json'
fi

cat > server.py << 'EOF'
from flask import Flask, request, send_file
from TTS.api import TTS
import torch, tempfile, os, threading
os.environ['TTS_HOME'] = os.path.expanduser('~/Library/Application Support/tts')

has_gpu = torch.backends.mps.is_available()
print(f"GPU: {has_gpu}")
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
EOF

echo "y" | python3 server.py &
sleep 5
lt --port 5000 &
echo "Tunnel starting..."
wait