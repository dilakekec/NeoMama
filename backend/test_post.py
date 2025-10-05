import requests

url = "http://127.0.0.1:8000/api/baby"

data = {
    "name": "Mete",
    "birth_date": "2024-02-14",
    "feeding_preferences": "Breastfeeding",
    "allergies": "Peanut",
    "notes": "Çok tatlı bir bebek"
}

try:
    res = requests.post(url, json=data)
    res.raise_for_status()  # HTTP error fırlatır (örn. 400, 500)

    print("Status Code:", res.status_code)
    try:
        print("Response JSON:", res.json())
    except ValueError:
        print("Response Text:", res.text)

except requests.exceptions.RequestException as e:
    print("Request failed:", e)