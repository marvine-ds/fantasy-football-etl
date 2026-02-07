import requests
import pandas as pd

BASE_URL = "https://fantasy.premierleague.com/api/element-summary/"


def fetch_player_gameweek_history(player_id):
    url = f"{BASE_URL}{player_id}/"
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()

    history = data.get("history", [])
    return pd.DataFrame(history)


def prepare_fact_rows(player_id, history_df):
    if history_df.empty:
        return pd.DataFrame()

    facts = history_df[[
        "round",
        "total_points",
        "minutes"
    ]].copy()

    facts.rename(columns={
        "round": "event_id",
        "total_points": "points"
    }, inplace=True)

    facts["player_id"] = player_id

    return facts[[
        "player_id",
        "event_id",
        "points",
        "minutes"
    ]]
