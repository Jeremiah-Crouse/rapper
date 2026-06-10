from huggingface_hub import snapshot_download
import os
path = os.path.expanduser("~/Library/Application Support/tts/tts_models--multilingual--multi-dataset--xtts_v2")
os.makedirs(path, exist_ok=True)
snapshot_download("coqui/XTTS-v2", local_dir=path, local_dir_use_symlinks=False)
print("Done")
