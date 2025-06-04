import requests

data = {
    "name": "Mete",
    "birth_date": "2024-02-14",
    "feeding_preferences": "Breastfeeding",
    "allergies": "Peanut",
    "notes": "Çok tatlı bir bebek"
}

res = requests.post("http://127.0.0.1:8000/api/baby", json=data)

print("Status Code:", res.status_code)
print("Response:", res.json())
