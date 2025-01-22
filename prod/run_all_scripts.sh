#!/bin/bash

# Define the scripts to run
CLONE_REPO_SCRIPT="./clone_repo.sh"
CREATE_ENV_SCRIPT="./create_env.sh"
RUN_PARALLEL_SCRIPT="./run_parallel.sh"

# Define arguments for the scripts
REPO_URL="https://github.com/Ravikiran-Bhonagiri/shell_scripts.git"  # Replace with the required repo URL

# Function to run a script with arguments and check for errors
run_script() {
    SCRIPT_PATH=$1
    SCRIPT_NAME=$(basename "$SCRIPT_PATH")
    SCRIPT_ARGS=${@:2}  # Pass all additional arguments to the script

    echo "------------------------------------------------------------"
    echo "Running: $SCRIPT_NAME"
    echo "------------------------------------------------------------"

    # Check if the script exists
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "Error: $SCRIPT_NAME not found at $SCRIPT_PATH. Exiting."
        exit 1
    fi

    # Ensure the script is executable
    chmod +x "$SCRIPT_PATH"

    # Run the script with arguments
    "$SCRIPT_PATH" $SCRIPT_ARGS
    if [ $? -ne 0 ]; then
        echo "------------------------------------------------------------"
        echo "Error occurred while executing: $SCRIPT_NAME. Exiting."
        echo "------------------------------------------------------------"
        exit 1
    else
        echo "------------------------------------------------------------"
        echo "Successfully executed: $SCRIPT_NAME"
        echo "------------------------------------------------------------"
    fi
}

# Run the scripts in sequence with necessary arguments
run_script "$CLONE_REPO_SCRIPT" "$REPO_URL"
run_script "$CREATE_ENV_SCRIPT"
run_script "$RUN_PARALLEL_SCRIPT"

echo "------------------------------------------------------------"
echo "All scripts executed successfully."
echo "------------------------------------------------------------"
