import requests
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get API key from environment variables
fast2sms_api_key = os.getenv('FAST2SMS_API_KEY')

if not fast2sms_api_key:
    raise ValueError("FAST2SMS_API_KEY not found in environment variables")

url = "https://www.fast2sms.com/dev/custom"

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
    'authorization': fast2sms_api_key,
    'Content-Type': "application/json"
}

response = requests.request("POST", url, json=payload, headers=headers)

print(response.text)
