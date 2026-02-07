import pandas as pd


def extract_teams(raw_data):
    """
    Convert teams JSON to DataFrame
    """
    return pd.DataFrame(raw_data["teams"])


def extract_players(raw_data):
    """
    Convert players (elements) JSON to DataFrame
    """
    return pd.DataFrame(raw_data["elements"])


def extract_events(raw_data):
    """
    Convert events (gameweeks) JSON to DataFrame
    """
    return pd.DataFrame(raw_data["events"])

if __name__ == "__main__":
    from api_fetch import fetch_api_data

    raw = fetch_api_data()

    teams_df = extract_teams(raw)
    players_df = extract_players(raw)
    events_df = extract_events(raw)

    print(teams_df.shape)
    print(players_df.shape)
    print(events_df.shape)

