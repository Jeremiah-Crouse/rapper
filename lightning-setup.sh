#!/bin/bash
# Run this in a Lightning AI Studio terminal
# Sets up XTTS v2 server with Cloudflare Tunnel for GPU voice cloning

echo "=== Installing TTS and dependencies ==="
pip install TTS flask flask-cors 2>&1 | tail -3

echo "=== Downloading speaker sample ==="
curl -sL -o speaker.wav "https://qwert.crousia.com/speaker.wav"
ls -lh speaker.wav

echo "=== Installing cloudflared ==="
curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared && chmod +x cloudflared

echo "=== Starting TTS server ==="
cat > server.py << 'PYEOF'
#!/usr/bin/env python3
from flask import Flask, request, send_file
from TTS.api import TTS
import torch, tempfile, os, threading

has_gpu = torch.cuda.is_available()
print(f"GPU: {torch.cuda.get_device_name(0) if has_gpu else 'N/A'}")
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=has_gpu)

app = Flask(__name__)
@app.route("/health")
def health():
    return {"status": "ok", "gpu": has_gpu}

@app.route("/synthesize", methods=["POST"])
def synthesize():
    text = request.get_json().get("text", "")
    if not text: return {"error": "text required"}, 400
    fd, path = tempfile.mkstemp(suffix=".wav")
    os.close(fd)
    tts.tts_to_file(text=text, file_path=path, speaker_wav="speaker.wav", language="en")
    return send_file(path, mimetype="audio/wav")

threading.Thread(target=lambda: app.run(host="0.0.0.0", port=5000, debug=False), daemon=True).start()
print("Server on :5000")
PYEOF

python3 server.py &
sleep 5

echo "=== Starting Cloudflare Tunnel ==="
./cloudflared tunnel --url http://127.0.0.1:5000 &
sleep 3

echo ""
echo "========================================"
echo "LIGHTNING AI GPU ENDPOINT"
echo "Look above for the trycloudflare.com URL"
echo "========================================"
echo ""
echo "To keep it running:"
echo "  Lightning AI Studios stay alive until you close them."
echo "  Set COLAB_GPU_URL=<url> on Echad to use this endpoint."
echo ""
echo "To check tunnel: ps aux | grep cloudflared"
wait
