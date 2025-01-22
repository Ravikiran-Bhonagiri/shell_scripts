import os
import time
import wave
import json
import pyaudio
from azure.storage.blob import BlobServiceClient
import librosa
import numpy as np
import pandas as pd
from scipy.signal import hilbert
from scipy.stats import skew, kurtosis
import joblib

# Constants for audio recording
CHUNK = 1024
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100
RECORD_SECONDS = 5
MODEL_PATH = "./decision_tree.joblib"

### https://www.kaggle.com/code/tanvikurade/anomaly-detection-using-isolation-forest?utm_source=chatgpt.com

# Constants for Azure Blob Storage
CONNECTION_STRING = ""
CONTAINER_NAME = ""

look_up = {0: 'bolt_case', 1: 'normal_case', 2: 'off_state', 3: 'on_state', 4: 'paper_case', 5: 'solid_case'}

import librosa
import numpy as np
from scipy.stats import skew, kurtosis

def extract_audio_features(audio_file):
    """
    Extract audio features from the input audio file.
    """
    y, sr = librosa.load(audio_file, sr=None)
    features = {}

    # Audio feature extraction
    features["zcr_mean"] = np.mean(librosa.feature.zero_crossing_rate(y))
    features["spectral_centroid_mean"] = np.mean(librosa.feature.spectral_centroid(y=y, sr=sr))
    features["spectral_rolloff_mean"] = np.mean(librosa.feature.spectral_rolloff(y=y, sr=sr))
    features["spectral_bandwidth_mean"] = np.mean(librosa.feature.spectral_bandwidth(y=y, sr=sr))
    features["rms_mean"] = np.mean(librosa.feature.rms(y=y))

    # MFCC features
    mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=13)
    for i in range(13):
        features[f"mfcc_{i+1}_mean"] = np.mean(mfccs[i])

    features["chroma_mean"] = np.mean(librosa.feature.chroma_stft(y=y, sr=sr))
    features["spectral_contrast_mean"] = np.mean(librosa.feature.spectral_contrast(y=y, sr=sr))
    features["tonnetz_mean"] = np.mean(librosa.feature.tonnetz(y=y, sr=sr))
    features["onset_strength_mean"] = np.mean(librosa.onset.onset_strength(y=y, sr=sr))

    # Harmonic and percussive RMS
    harmonic, percussive = librosa.effects.hpss(y)
    features["harmonic_rms"] = np.mean(librosa.feature.rms(y=harmonic))
    features["percussive_rms"] = np.mean(librosa.feature.rms(y=percussive))

    # Pitch and tempo
    pitches, _ = librosa.piptrack(y=y, sr=sr)
    features["mean_pitch"] = np.mean(pitches[pitches > 0])
    features["tempo"] = librosa.beat.tempo(y=y, sr=sr)[0]

    # Chroma CQT and spectral flatness
    features["chroma_cqt_mean"] = np.mean(librosa.feature.chroma_cqt(y=y, sr=sr))
    features["spectral_flatness_mean"] = np.mean(librosa.feature.spectral_flatness(y=y))

    # Spectral entropy
    spectral_energy = y ** 2
    spectral_probs = spectral_energy / np.sum(spectral_energy + 1e-7)
    features["spectral_entropy"] = -np.sum(spectral_probs * np.log(spectral_probs + 1e-7))

    # Crest factor
    features["crest_factor"] = np.max(np.abs(y)) / np.mean(np.abs(y))

    # Attack and decay time (based on onset envelope)
    envelope = librosa.onset.onset_strength(y=y, sr=sr)
    features["attack_time"] = np.argmax(envelope) / sr
    features["decay_time"] = (len(envelope) - np.argmax(envelope[::-1])) / sr

    # Skewness and kurtosis
    features["skewness"] = skew(y)
    features["kurtosis"] = kurtosis(y)

    return features


def record_audio(filename):
    """
    Record audio and save to a file.
    """
    audio = pyaudio.PyAudio()
    stream = audio.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)
    frames = [stream.read(CHUNK) for _ in range(int(RATE / CHUNK * RECORD_SECONDS))]
    stream.stop_stream()
    stream.close()
    audio.terminate()

    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(audio.get_sample_size(FORMAT))
        wf.setframerate(RATE)
        wf.writeframes(b''.join(frames))

def upload_to_blob_storage(local_file_path, blob_name):
    """
    Upload a file to Azure Blob Storage.
    """
    blob_service_client = BlobServiceClient.from_connection_string(CONNECTION_STRING)
    container_client = blob_service_client.get_container_client(CONTAINER_NAME)
    with open(local_file_path, "rb") as data:
        container_client.upload_blob(name=blob_name, data=data)
    os.remove(local_file_path)

def save_to_json(data, filename):
    """
    Save data to a JSON file.
    """
    with open(filename, 'w') as json_file:
        json.dump(data, json_file, indent=4)


if __name__ == "__main__":
    loaded_clf = joblib.load(MODEL_PATH)
    json_filename = f"Device1_prediction_data.json"
    data = []

    while True:
        timestamp = time.strftime("%Y-%m-%d_%H-%M-%S")
        audio_filename = f"Device1_{timestamp}.wav"
        #json_filename = f"Device1_{timestamp}.json"

        # Record audio
        record_audio(audio_filename)

        # Extract features
        features = extract_audio_features(audio_filename)

        # Predict using the model
        input_df = pd.DataFrame([features])
        predictions = loaded_clf.predict(input_df)

        # Prepare data to append to JSON
        result = {
            "features": features,
            "predictions": look_up[predictions[0]]  # Already serializable
        }

        # Append the new result to the data
        data.append(result)

        # Write the updated data back to the JSON file
        with open(json_filename, 'w') as json_file:
            json.dump(data, json_file, indent=4)

        print(f"Predictions saved to {json_filename}")
        time.sleep(5)  # Wait 5 seconds before the next recording
