import requests
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get API key from environment variables
FAST2SMS_API_URL = os.getenv('FAST2SMS_API_URL', 'https://www.fast2sms.com/dev/bulkV2')
FAST2SMS_API_KEY = os.getenv('FAST2SMS_API_KEY')

if not FAST2SMS_API_KEY:
    raise ValueError("FAST2SMS_API_KEY not found in environment variables")

url = FAST2SMS_API_URL

payload = {
    "route": "dlt",
    "requests": [
        {
            "sender_id": "VMOVEF",
            "message": "160723",
            "variables_values": "1234",
            "flash": 0,
            "numbers": "9162233666"
        }
    ]
}

headers = {
    'authorization': FAST2SMS_API_KEY,
    'Content-Type': "application/json"
}

response = requests.request("POST", url, json=payload, headers=headers)

print(response.text)
