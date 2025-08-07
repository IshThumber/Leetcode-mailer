#!/bin/bash

# LeetCode Mailer Cron Script
# This script ensures the correct environment and runs the mailer

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory
cd "$SCRIPT_DIR"

# Log file for cron output
LOG_FILE="$SCRIPT_DIR/cron.log"

# Add timestamp to log
echo "=== LeetCode Mailer Run: $(date) ===" >> "$LOG_FILE"

# Check if virtual environment exists
VENV_PYTHON="$SCRIPT_DIR/.venv/bin/python"
if [ -f "$VENV_PYTHON" ]; then
    PYTHON_CMD="$VENV_PYTHON"
    echo "Using virtual environment Python: $PYTHON_CMD" >> "$LOG_FILE"
else
    # Fall back to system Python with PATH setup
    export PATH="/usr/local/bin:/usr/bin:/bin:/Users/$(whoami)/homebrew/bin:$PATH"
    
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &> /dev/null; then
        PYTHON_CMD="python"
    else
        echo "Error: Python not found in PATH" >> "$LOG_FILE"
        exit 1
    fi
    echo "Using system Python: $PYTHON_CMD" >> "$LOG_FILE"
    
    # Install packages if using system Python
    echo "Installing required packages..." >> "$LOG_FILE"
    $PYTHON_CMD -m pip install --user -r requirements.txt >> "$LOG_FILE" 2>&1
fi

# Run the mailer script
echo "Running LeetCode mailer..." >> "$LOG_FILE"
$PYTHON_CMD daily_question_mailer.py >> "$LOG_FILE" 2>&1

# Check exit status
if [ $? -eq 0 ]; then
    echo "LeetCode mailer completed successfully" >> "$LOG_FILE"
else
    echo "LeetCode mailer failed with exit code $?" >> "$LOG_FILE"
fi

echo "=== End of run ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
