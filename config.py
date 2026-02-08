# config.py
# Central configuration for the fantasy football data pipeline

API_URL = "https://fantasy.premierleague.com/api/bootstrap-static/"

# Database configuration
DB_CONFIG = {
    "host": "127.0.0.1",
    "port": 3307,
    "user": "root",
    "password": "rootpass",
    "database": "fantasy_football"
}

