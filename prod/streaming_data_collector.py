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

# Constants for Azure Blob Storage
CONNECTION_STRING = ""
CONTAINER_NAME = ""


def record_audio_and_extract_features():
    """
    Record audio in real-time and extract features during the recording process.
    """
    audio = pyaudio.PyAudio()
    stream = audio.open(format=FORMAT, channels=CHANNELS, rate=RATE, input=True, frames_per_buffer=CHUNK)

    feature_aggregates = {
        "zcr": [],
        "spectral_centroid": [],
        "spectral_rolloff": [],
        "spectral_bandwidth": [],
        "rms": [],
        "mfcc": [[] for _ in range(13)],
        "chroma": [],
        "spectral_flatness": []
    }

    print("Recording and processing audio...")
    for _ in range(int(RATE / CHUNK * RECORD_SECONDS)):
        data = stream.read(CHUNK)
        y = np.frombuffer(data, dtype=np.int16).astype(np.float32)
        y /= np.max(np.abs(y))  # Normalize audio signal

        # Extract features for the current chunk
        feature_aggregates["zcr"].append(np.mean(librosa.feature.zero_crossing_rate(y)))
        feature_aggregates["spectral_centroid"].append(np.mean(librosa.feature.spectral_centroid(y=y, sr=RATE)))
        feature_aggregates["spectral_rolloff"].append(np.mean(librosa.feature.spectral_rolloff(y=y, sr=RATE)))
        feature_aggregates["spectral_bandwidth"].append(np.mean(librosa.feature.spectral_bandwidth(y=y, sr=RATE)))
        feature_aggregates["rms"].append(np.mean(librosa.feature.rms(y=y)))

        mfccs = librosa.feature.mfcc(y=y, sr=RATE, n_mfcc=13)
        for i in range(13):
            feature_aggregates["mfcc"][i].append(np.mean(mfccs[i]))

        feature_aggregates["chroma"].append(np.mean(librosa.feature.chroma_stft(y=y, sr=RATE)))
        feature_aggregates["spectral_flatness"].append(np.mean(librosa.feature.spectral_flatness(y=y)))

    # Aggregate features over the entire recording
    features = {
        "zcr_mean": np.mean(feature_aggregates["zcr"]),
        "spectral_centroid_mean": np.mean(feature_aggregates["spectral_centroid"]),
        "spectral_rolloff_mean": np.mean(feature_aggregates["spectral_rolloff"]),
        "spectral_bandwidth_mean": np.mean(feature_aggregates["spectral_bandwidth"]),
        "rms_mean": np.mean(feature_aggregates["rms"]),
        "chroma_mean": np.mean(feature_aggregates["chroma"]),
        "spectral_flatness_mean": np.mean(feature_aggregates["spectral_flatness"]),
    }

    for i in range(13):
        features[f"mfcc_{i+1}_mean"] = np.mean(feature_aggregates["mfcc"][i])

    # Close the audio stream
    stream.stop_stream()
    stream.close()
    audio.terminate()

    return features

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

    while True:
        timestamp = time.strftime("%Y-%m-%d_%H-%M-%S")
        #json_filename = f"Device1_{timestamp}.json"

        # Record and extract features in real-time
        features = record_audio_and_extract_features()


        # Predict using the model
        input_df = pd.DataFrame([features])
        predictions = loaded_clf.predict(input_df)

        # Prepare data to append to JSON
        result = {
            "features": features,
            "predictions": predictions  # Already serializable
        }

        # Append the predictions to the JSON file
        try:
            # If the JSON file exists, load existing data
            with open(json_filename, 'r') as json_file:
                data = json.load(json_file)
        except FileNotFoundError:
            # If the file doesn't exist, initialize an empty list
            data = []

        # Append the new result to the data
        data.append(result)

        # Write the updated data back to the JSON file
        with open(json_filename, 'w') as json_file:
            json.dump(data, json_file, indent=4)

        print(f"Predictions saved to {json_filename}")
        time.sleep(5)  # Wait 5 seconds before the next recording