import os
import random
import yagmail
from openai import OpenAI
import gspread
from dotenv import load_dotenv
from oauth2client.service_account import ServiceAccountCredentials
from typing import List, Dict, Set
import sys

# Load env vars
load_dotenv()

# Constants
SENT_LOG = "sent_questions.txt"
DIFFICULTY_COLORS = {"Easy": "#28a745", "Medium": "#ffc107", "Hard": "#dc3545"}

def setup_openai_client() -> OpenAI:
  """Initialize OpenAI client with error handling."""
  token = os.environ.get("GITHUB_TOKEN")
  if not token:
    print("Error: GITHUB_TOKEN not found")
    raise ValueError("GITHUB_TOKEN environment variable is not set")
  
  return OpenAI(
    base_url="https://models.github.ai/inference",
    api_key=token,
  )

def get_google_sheets_data() -> List[Dict]:
  """Fetch data from Google Sheets with comprehensive error handling."""
  try:
    scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
    creds = ServiceAccountCredentials.from_json_keyfile_name("credentials.json", scope)
    client = gspread.authorize(creds)
    
    sheet_name = os.getenv("SHEET_NAME")
    if not sheet_name:
      raise ValueError("SHEET_NAME environment variable is not set")
    
    spreadsheet = client.open(sheet_name)
    data = spreadsheet.sheet1.get_all_records()
    print(f"Successfully loaded {len(data)} records from Google Sheets")
    return data
    
  except FileNotFoundError:
    print("Error: credentials.json file not found!")
    sys.exit(1)
  except gspread.exceptions.SpreadsheetNotFound:
    print(f"Error: Spreadsheet '{sheet_name}' not found!")
    sys.exit(1)
  except Exception as e:
    print(f"Error accessing Google Sheets: {e}")
    sys.exit(1)

def load_sent_questions() -> Set[str]:
  """Load previously sent questions from log file."""
  if not os.path.exists(SENT_LOG):
    with open(SENT_LOG, 'w') as f:
      pass
    return set()
  
  with open(SENT_LOG, 'r') as f:
    sent_questions = set(line.strip() for line in f if line.strip())
  return sent_questions

def categorize_questions(data: List[Dict], sent_titles: Set[str]) -> Dict[str, List[Dict]]:
  """Categorize unsent questions by difficulty."""
  categories = {"Easy": [], "Medium": [], "Hard": []}
  
  for row in data:
    title = row.get("Title", "")
    difficulty = row.get("Difficulty", "").capitalize()
    
    if title and title not in sent_titles and difficulty in categories:
      categories[difficulty].append(row)
  
  return categories

def select_questions(categories: Dict[str, List[Dict]], counts: Dict[str, int]) -> List[Dict]:
  """Select random questions based on difficulty counts."""
  selected = []
  
  for difficulty, count in counts.items():
    if count > 0 and categories[difficulty]:
      random.shuffle(categories[difficulty])
      selected_from_difficulty = categories[difficulty][:count]
      selected.extend(selected_from_difficulty)
  
  return selected

def get_ai_hints(client: OpenAI, title: str, topics: str) -> str:
  """Get AI-generated hints for a LeetCode problem."""
  prompt = f"""
Given a LeetCode problem titled: "{title}" with topics: {topics}, provide in cpp:

1. Brute-force approach
2. A better approach (if any)
3. Optimal approach

Reply in this format:
Brute: ...
Better: ...
Optimal: ...
"""
  
  try:
    response = client.chat.completions.create(
      temperature=1.0,
      top_p=1.0,
      model="openai/gpt-4.1",
      messages=[{"role": "user", "content": prompt}]
    )
    hints = response.choices[0].message.content.strip()
    return hints
  except Exception as e:
    print(f"Error getting AI hints for {title}: {str(e)}")
    return f"Error getting AI hints: {str(e)}"

def generate_email_body(selected_questions: List[Dict], openai_client: OpenAI) -> str:
  """Generate HTML email body with question details and hints."""
  email_body = """
<html>
<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
<h1 style="color: #4a90e2;">🧠 Your Daily 5 LeetCode Questions</h1>
"""
  
  for i, q in enumerate(selected_questions, 1):
    title = q.get('Title', 'Unknown')
    link = q.get('Link', '#')
    topics = q.get('Topics', 'N/A')
    difficulty = q.get('Difficulty', 'Unknown')
    
    hints = get_ai_hints(openai_client, title, topics)
    difficulty_color = DIFFICULTY_COLORS.get(difficulty, "#6c757d")
    
    email_body += f"""
<div style="margin-bottom: 15px; padding: 15px; border-left: 4px solid {difficulty_color}; background-color: #f8f9fa;">
  <h3 style="margin-top: 0; color: #2c3e50;">🔹 {title} 
  <span style="color: {difficulty_color}; font-weight: bold;">({difficulty})</span>
  </h3>
  
  <p><strong>🔗 Link:</strong> <a href="{link}" style="color: #4a90e2; text-decoration: none;">{link}</a></p>
  
  <p><strong>🧩 Topics:</strong> <span style="background-color: #e9ecef; border-radius: 3px;">{topics}</span></p>
  
  <div style="margin-top: 5px;">
  <strong>💡 Hints:</strong>
  <div style="background-color: #fff; padding: 10px; margin-top: 1px; border-radius: 5px; white-space: pre-line;">
{hints}
  </div>
  </div>
</div>
"""
  
  email_body += "</body></html>"
  return email_body

def send_email(email_body: str) -> None:
  """Send email with question details."""
  sender = os.getenv("SENDER_EMAIL")
  receiver = os.getenv("RECEIVER_EMAIL") 
  password = os.getenv("EMAIL_PASSWORD")
  
  if not all([sender, receiver, password]):
    print("Error: Missing email credentials")
    raise ValueError("Email credentials not properly configured in environment variables")
  
  yag = yagmail.SMTP(user=sender, password=password)
  yag.send(to=receiver, subject="📬 Your Daily LeetCode Set", contents=email_body)
  print("Email sent successfully!")

def log_sent_questions(selected_questions: List[Dict]) -> None:
  """Log sent questions to prevent re-sending."""
  with open(SENT_LOG, 'a') as f:
    for q in selected_questions:
      title = q.get("Title", "")
      if title:
        f.write(title + "\n")

def main():
  """Main execution function."""
  try:
    # Setup
    openai_client = setup_openai_client()
    data = get_google_sheets_data()
    sent_titles = load_sent_questions()
    
    # Process questions
    categories = categorize_questions(data, sent_titles)
    question_counts = {"Easy": 5, "Medium": 0, "Hard": 0}  # Configurable
    selected = select_questions(categories, question_counts)
    
    if not selected:
      print("No new questions available to send.")
      return
    
    # Generate and send email
    email_body = generate_email_body(selected, openai_client)
    send_email(email_body)
    
    # Log sent questions
    log_sent_questions(selected)
    
    print(f"Email sent successfully with {len(selected)} LeetCode questions!")
    
  except Exception as e:
    print(f"Error in main execution: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

if __name__ == "__main__":
  main()
