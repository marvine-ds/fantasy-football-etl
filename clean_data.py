import pandas as pd


def clean_teams(df):
    """
    Clean teams DataFrame
    """
    teams = df[[
        "id",
        "name",
        "strength",
        "strength_attack_home",
        "strength_defence_home"
    ]].copy()

    teams.rename(columns={
        "id": "team_id",
        "name": "team_name",
        "strength_attack_home": "attack_strength",
        "strength_defence_home": "defence_strength"
    }, inplace=True)

    return teams


def clean_players(df):
    """
    Clean players DataFrame
    """
    players = df[[
        "id",
        "web_name",
        "team",
        "element_type",
        "now_cost",
        "status",
        "minutes",
        "total_points"
    ]].copy()

    players.rename(columns={
        "id": "player_id",
        "web_name": "player_name",
        "team": "team_id",
        "element_type": "position",
        "now_cost": "cost"
    }, inplace=True)

    players["cost"] = players["cost"] / 10

    return players

def clean_events(df):
    """
    Clean events / gameweeks
    """
    events = df[[
        "id",
        "name",
        "deadline_time",
        "finished"
    ]].copy()

    events.rename(columns={
        "id": "event_id"
    }, inplace=True)

    # Extract integer gameweek from "Gameweek X"
    events["gameweek"] = events["name"].str.extract(r"(\d+)").astype(int)

    # Convert ISO datetime string to MySQL-friendly datetime
    events["deadline_time"] = (
        pd.to_datetime(events["deadline_time"], utc=True)
          .dt.tz_convert(None)
    )

    # Drop original name column
    events.drop(columns=["name"], inplace=True)

    return events




if __name__ == "__main__":
    from api_fetch import fetch_api_data
    from raw_to_df import extract_teams, extract_players,extract_events

    raw = fetch_api_data()

    teams_df = clean_teams(extract_teams(raw))
    players_df = clean_players(extract_players(raw))
    events_df = clean_events(extract_events(raw))

    print(teams_df.head())
    print(players_df.head())
    print(events_df.head())

