# LeetCode Daily Mailer

Automatically sends daily LeetCode questions via email using Google Sheets and GitHub Models (OpenAI-compatible) for AI hints.

## 📁 Project Structure

```
leetcode_mailer/
├── .env                      # Environment variables
├── .venv/                    # Python virtual environment
├── credentials.json          # Google Sheets API credentials
├── daily_question_mailer.py  # Main Python script
├── sent_questions.txt        # Tracks sent questions
├── run_mailer.sh            # Shell script for cron execution
├── setup_cron.sh            # Interactive cron setup
├── manage_cron.sh           # Cron management utilities
├── requirements.txt         # Python dependencies
├── cron.log                 # Cron execution logs
├── index.html               # Web interface (if applicable)
└── README.md               # This file
```

## 🚀 Setup Instructions

### 1. Install Dependencies

The project automatically creates a virtual environment with all dependencies:

```bash
# Automatic setup (recommended)
./setup_cron.sh  # Detects and uses virtual environment

# Manual virtual environment setup (if needed)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure Environment Variables

Edit `.env` file with your credentials:

```env
SHEET_NAME="Your Google Sheet Name"
SENDER_EMAIL=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
RECEIVER_EMAIL=recipient@gmail.com
GITHUB_TOKEN=ghp_your_github_token  # For AI hints via GitHub Models
```

**Note**: This project uses GitHub Models API (OpenAI-compatible) instead of direct OpenAI API for cost-effective AI hints.

### 3. Google Sheets Setup

1. **Create a Google Service Account**:

   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable Google Sheets API
   - Create service account credentials

2. **Download credentials**:

   - Download the JSON credentials file
   - Save as `credentials.json` in the project root

3. **Prepare your spreadsheet**:
   - Create a Google Sheet with LeetCode questions
   - Required columns: `Title`, `Difficulty`, `Link`, `Topics`
   - Share the sheet with your service account email (found in credentials.json)

### 4. GitHub Models Setup (for AI Hints)

1. **Get GitHub Token**:

   - Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
   - Generate a new token with appropriate permissions
   - Add it to your `.env` file as `GITHUB_TOKEN`

2. **AI Models Available**:
   - Uses GitHub Models API (OpenAI-compatible)
   - Supports GPT-4 and other models
   - More cost-effective than direct OpenAI API

### 5. Test Manual Run

```bash
# Using virtual environment (recommended)
.venv/bin/python daily_question_mailer.py

# Or with system Python
python3 daily_question_mailer.py
```

### 6. Setup Automated Cron Job

```bash
./setup_cron.sh
```

## 🕐 Cron Schedule Options

- **Daily at 9:00 AM**: `0 9 * * *`
- **Weekdays at 8:00 AM**: `0 8 * * 1-5`
- **Every 2 hours**: `0 */2 * * *`

## 🛠️ Management Commands

### Setup Cron Job

```bash
./setup_cron.sh
```

### Manage Existing Cron Jobs

```bash
./manage_cron.sh
```

### Manual Test Run

```bash
./run_mailer.sh
```

### View Cron Logs

```bash
tail -f cron.log
```

### View Current Cron Jobs

```bash
crontab -l
```

### Remove Cron Jobs

```bash
crontab -e  # Edit and remove lines
# or
./manage_cron.sh  # Option 4
```

## 📊 Features

- ✅ Fetches questions from Google Sheets
- ✅ Tracks previously sent questions automatically
- ✅ Selects balanced difficulty mix (configurable)
- ✅ Generates AI hints using GitHub Models API
- ✅ Sends formatted HTML emails with rich styling
- ✅ Automated cron scheduling with robust error handling
- ✅ Virtual environment support for isolated dependencies
- ✅ Comprehensive logging and monitoring
- ✅ Graceful fallbacks for API failures

## 🔧 Troubleshooting

### Check System Status

```bash
# View recent cron logs
tail -f cron.log

# Test manual run with verbose output
./run_mailer.sh

# Check virtual environment
ls -la .venv/bin/python

# Verify cron jobs
crontab -l | grep leetcode
```

### Common Issues

1. **Python/Packages not found**:

   - Ensure virtual environment exists: `ls -la .venv/`
   - Recreate if needed: `python3 -m venv .venv`
   - Install packages: `.venv/bin/pip install -r requirements.txt`

2. **Google Sheets access denied**:

   - Verify service account email has sheet access
   - Check credentials.json file exists and is valid
   - Ensure SHEET_NAME in .env matches exactly

3. **Email authentication fails**:

   - Use app-specific passwords for Gmail (not regular password)
   - Verify SENDER_EMAIL and EMAIL_PASSWORD in .env
   - Check email provider SMTP settings

4. **GitHub Models API errors**:

   - Verify GITHUB_TOKEN is valid and not expired
   - Check GitHub Models API availability
   - Ensure token has correct permissions

5. **Cron job not running**:

   - Check cron service status
   - Verify file permissions: `chmod +x *.sh`
   - Check cron entry: `crontab -l`
   - Review cron.log for error messages

6. **Virtual environment issues**:
   - Delete and recreate: `rm -rf .venv && python3 -m venv .venv`
   - Reinstall packages: `.venv/bin/pip install -r requirements.txt`

### Debug Mode

Set debug mode in the Python script for verbose logging.

## 📧 Email Format

The mailer sends HTML emails with:

- Question title and difficulty
- Direct LeetCode links
- Topic tags
- AI-generated hints (if configured)
- Clean, readable formatting

## 🔒 Security Notes

- Keep `.env` and `credentials.json` secure
- Use app passwords for email authentication
- Limit Google Service Account permissions
- Regular credential rotation recommended

## 📝 Logs

- `cron.log`: Automated run logs with timestamps
- `sent_questions.txt`: Tracks sent question titles to avoid duplicates
- Virtual environment logs: `.venv/` directory
- System cron logs: `/var/log/cron` (Linux) or Console.app (macOS)

## 🎛️ Configuration Options

### Question Selection

Modify `daily_question_mailer.py` to adjust:

- Number of questions per difficulty (default: 4 Easy, 1 Medium, 0 Hard)
- Selection criteria and filtering
- Email content and formatting

### Cron Scheduling

Common schedule patterns:

- `0 9 * * *` - Daily at 9:00 AM
- `0 8 * * 1-5` - Weekdays at 8:00 AM
- `0 */6 * * *` - Every 6 hours
- `30 7 * * 1,3,5` - Mon/Wed/Fri at 7:30 AM

## 🔄 Maintenance

### Regular Tasks

```bash
# Update package dependencies
.venv/bin/pip install --upgrade -r requirements.txt

# Clean up old logs
tail -1000 cron.log > cron.log.tmp && mv cron.log.tmp cron.log

# Backup sent questions history
cp sent_questions.txt sent_questions_backup_$(date +%Y%m%d).txt
```

### Monitoring

- Check `cron.log` regularly for errors
- Monitor email delivery success rates
- Verify Google Sheets access periodically
- Update GitHub token when expired
