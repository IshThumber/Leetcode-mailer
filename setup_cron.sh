#!/bin/bash

# LeetCode Mailer Cron Setup Script
# This script helps set up the cron job for automated daily emails

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAILER_SCRIPT="$SCRIPT_DIR/run_mailer.sh"

echo "🔧 LeetCode Mailer Cron Setup"
echo "=============================="
echo ""
echo "This script will help you set up a cron job to run the LeetCode mailer automatically."
echo ""

# Check if run_mailer.sh exists and is executable
if [ ! -f "$MAILER_SCRIPT" ]; then
    echo "❌ Error: run_mailer.sh not found!"
    exit 1
fi

if [ ! -x "$MAILER_SCRIPT" ]; then
    echo "❌ Error: run_mailer.sh is not executable!"
    echo "Run: chmod +x run_mailer.sh"
    exit 1
fi

echo "✅ Mailer script found and executable"

# Check if virtual environment exists
if [ -f "$SCRIPT_DIR/.venv/bin/python" ]; then
    echo "✅ Virtual environment detected"
else
    echo "⚠️  No virtual environment found - will use system Python"
fi

echo ""

# Test the mailer script
echo "🧪 Testing the mailer script..."
if "$MAILER_SCRIPT"; then
    echo "✅ Test run successful!"
else
    echo "❌ Test run failed. Please check your configuration."
    exit 1
fi

echo ""
echo "📅 Cron Job Options:"
echo "1. Daily at 9:00 AM"
echo "2. Daily at 8:00 AM" 
echo "3. Monday to Friday at 9:00 AM"
echo "4. Custom schedule"
echo ""

read -p "Choose an option (1-4): " choice

case $choice in
    1)
        CRON_SCHEDULE="0 9 * * *"
        DESCRIPTION="Daily at 9:00 AM"
        ;;
    2)
        CRON_SCHEDULE="0 8 * * *"
        DESCRIPTION="Daily at 8:00 AM"
        ;;
    3)
        CRON_SCHEDULE="0 9 * * 1-5"
        DESCRIPTION="Monday to Friday at 9:00 AM"
        ;;
    4)
        echo ""
        echo "Cron format: minute hour day month weekday"
        echo "Examples:"
        echo "  0 9 * * *     - Daily at 9:00 AM"
        echo "  30 8 * * 1-5  - Weekdays at 8:30 AM"
        echo "  0 */2 * * *   - Every 2 hours"
        echo ""
        read -p "Enter your cron schedule: " CRON_SCHEDULE
        DESCRIPTION="Custom: $CRON_SCHEDULE"
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

# Create the cron job entry
CRON_ENTRY="$CRON_SCHEDULE $MAILER_SCRIPT"

echo ""
echo "📋 Cron Job Summary:"
echo "Schedule: $DESCRIPTION"
echo "Command: $CRON_ENTRY"
echo ""

read -p "Do you want to add this cron job? (y/n): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    
    if [ $? -eq 0 ]; then
        echo "✅ Cron job added successfully!"
        echo ""
        echo "📊 Current crontab:"
        crontab -l | grep -E "(run_mailer|leetcode)" || echo "No LeetCode mailer jobs found"
        echo ""
        echo "📝 Useful commands:"
        echo "  View all cron jobs: crontab -l"
        echo "  Edit cron jobs: crontab -e"
        echo "  Remove cron jobs: crontab -r"
        echo "  Check logs: tail -f $SCRIPT_DIR/cron.log"
        echo ""
        echo "🎉 Setup complete! Your LeetCode mailer will run automatically."
    else
        echo "❌ Failed to add cron job"
        exit 1
    fi
else
    echo "❌ Cron job setup cancelled"
fi
