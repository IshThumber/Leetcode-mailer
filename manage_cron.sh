#!/bin/bash

# LeetCode Mailer Cron Management Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 LeetCode Mailer Cron Management"
echo "=================================="
echo ""
echo "1. View current cron jobs"
echo "2. View cron log"
echo "3. Test mailer manually"
echo "4. Remove LeetCode mailer cron jobs"
echo "5. Setup new cron job"
echo ""

read -p "Choose an option (1-5): " choice

case $choice in
    1)
        echo ""
        echo "📋 Current cron jobs:"
        crontab -l 2>/dev/null || echo "No cron jobs found"
        ;;
    2)
        echo ""
        echo "📄 Recent cron log entries:"
        if [ -f "$SCRIPT_DIR/cron.log" ]; then
            tail -20 "$SCRIPT_DIR/cron.log"
        else
            echo "No log file found. Cron job hasn't run yet."
        fi
        ;;
    3)
        echo ""
        echo "🧪 Running mailer manually..."
        "$SCRIPT_DIR/run_mailer.sh"
        ;;
    4)
        echo ""
        echo "🗑️  Removing LeetCode mailer cron jobs..."
        crontab -l 2>/dev/null | grep -v "run_mailer.sh" | crontab -
        echo "✅ LeetCode mailer cron jobs removed"
        ;;
    5)
        echo ""
        echo "🔧 Running cron setup..."
        "$SCRIPT_DIR/setup_cron.sh"
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac
