import requests

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
    'authorization': "LoyxFDqUBuRn2IVhfAN4HWpPgkibO3KcrlsdJeQTGm790z8CtvmlYVW6voSe7bpKuLJ31RZdhIfH5MyF",
    'Content-Type': "application/json"
}

response = requests.request("POST", url, json=payload, headers=headers)

print(response.text)
