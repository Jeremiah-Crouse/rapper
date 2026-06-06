# Voice Cloning Rapper

A Python project for voice cloning and generating rap lyrics using AI, based on Coqui TTS YourTTS model (Bark integration planned).

## Features

- Voice cloning using YourTTS model
- Text-to-speech synthesis
- Future: AI-generated rap lyrics
- Future: Lyrical quantizer integration
- Future: Bark model integration for advanced features

## Setup

1. Install Python 3.11 (required for TTS compatibility)
   ```bash
   brew install python@3.11
   ```

2. Create virtual environment
   ```bash
   python3.11 -m venv venv
   source venv/bin/activate
   ```

3. Install dependencies
   ```bash
   pip install -r requirements.txt
   ```

## Usage

1. Prepare voice sample: Place your voice audio file as `bark_voices/your_speaker/speaker.wav`

2. Run the script
   ```bash
   source venv/bin/activate
   python src/main.py
   ```

3. Output will be saved as `output.wav` (cloned voice) and `random_output.wav` (random speaker)

## Requirements

- Python 3.11
- Coqui TTS library
- GPU recommended for faster processing (Bark works on CPU but is very slow)

## Future Enhancements

- Integrate AI for generating rap lyrics
- Add lyrical quantizer for rhythm and flow
- Web interface for easy voice upload and generation