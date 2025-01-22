#!/bin/bash
# This script runs two Python scripts in the background and ensures they keep running
# until they complete execution. This is useful for Docker containers or automated tasks.

# Define the paths to the Python scripts
AUDIO_DATA_COLLECTOR="audio_data_collector.py"
IOT_RELAY_CONTROL="iot_relay_control.py"

# Run the audio data collector script in the background
# This script is responsible for collecting audio data (e.g., sound signals, recordings).
echo "Starting audio data collector script..."
python "$AUDIO_DATA_COLLECTOR" &
AUDIO_PID=$! # Capture the Process ID (PID) of the audio script

# Run the IoT relay control script in the background
# This script manages IoT relay devices, such as controlling hardware or sensors.
echo "Starting IoT relay control script..."
python "$IOT_RELAY_CONTROL" &
IOT_PID=$! # Capture the Process ID (PID) of the IoT script

# Log the PIDs of the scripts
echo "Audio data collector running with PID: $AUDIO_PID"
echo "IoT relay control running with PID: $IOT_PID"

# Wait for both scripts to finish
# The `wait` command ensures the shell script doesn't terminate until both background
# processes (Python scripts) have completed execution.
echo "Waiting for both scripts to finish..."
wait

# Final message to indicate the script has completed
echo "Both scripts have completed. Exiting."
