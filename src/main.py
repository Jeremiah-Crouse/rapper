#!/usr/bin/env python3
"""
Voice Cloning and Rapping Project using Coqui TTS Bark Model

This script demonstrates voice cloning using the Bark TTS model.
It can clone a voice from an audio file and generate speech with that voice.
Future enhancements: Integrate AI-generated lyrics and lyrical quantizer.
"""

from TTS.api import TTS
import random

def main():
    # Load the YourTTS model (using CPU since GPU not available)
    print("Loading YourTTS model...")
    tts = TTS("tts_models/multilingual/multi-dataset/your_tts", gpu=False)

    # Get available speakers
    speakers = tts.speakers
    print(f"Available speakers: {speakers}")

    # Example text
    text = """
        I am a potato.
    """

    # Voice cloning example
    # Assumes you have a speaker file in bark_voices/your_speaker/speaker.wav
    print("Cloning voice and generating speech...")
    tts.tts_to_file(text=text,
                    file_path="output.wav",
                    speaker_wav="bark_voices/your_speaker/speaker.wav",
                    language="en")

    print("Voice cloned speech saved to output.wav")

    # Random speaker example
    print("Generating speech with random speaker...")
    if speakers:
        random_speaker = random.choice(speakers)
        print(f"Using speaker: {random_speaker}")
        tts.tts_to_file("Hello world", file_path="random_output.wav", language="en", speaker=random_speaker)
    else:
        print("No speakers available, skipping random speaker generation.")

    print("Random speaker speech saved to random_output.wav")

if __name__ == "__main__":
    main()