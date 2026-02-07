import requests
from config import API_URL


def fetch_api_data():
    response = requests.get(API_URL)
    response.raise_for_status()
    return response.json()


if __name__ == "__main__":
    data = fetch_api_data()
    print(data.keys())
