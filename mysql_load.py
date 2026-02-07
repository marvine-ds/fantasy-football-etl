print("mysql_load.py started")

import mysql.connector
from config import DB_CONFIG


def get_connection():
    print("Connecting to MySQL...")
    return mysql.connector.connect(**DB_CONFIG)


def insert_dataframe(df, table_name):
    print(f"Inserting into {table_name}")
    conn = get_connection()
    cursor = conn.cursor()

    columns = ", ".join(df.columns)
    placeholders = ", ".join(["%s"] * len(df.columns))
    sql = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"

    for _, row in df.iterrows():
        cursor.execute(sql, tuple(row))

    conn.commit()
    cursor.close()
    conn.close()


if __name__ == "__main__":
    print("MAIN BLOCK RUNNING")

    from api_fetch import fetch_api_data
    from raw_to_df import extract_teams,extract_events, extract_players
    from clean_data import clean_teams,clean_events, clean_players

    raw = fetch_api_data()
    print("API data fetched")

    teams_df = clean_teams(extract_teams(raw))
    insert_dataframe(teams_df,"teams")
    print("Teams loaded")

    events_df = clean_events(extract_events(raw))
    insert_dataframe(events_df, "events")
    print("Events loaded")

    players_df = clean_players(extract_players(raw))
    insert_dataframe(players_df, "players")
    print("Players loaded")

def insert_facts(df):
    print("Inserting player gameweek facts")
    conn = get_connection()
    cursor = conn.cursor()

    sql = """
    INSERT IGNORE INTO player_gameweek_stats
    (player_id, event_id, points, minutes)
    VALUES (%s, %s, %s, %s)
    """

    for _, row in df.iterrows():
        cursor.execute(sql, tuple(row))

    conn.commit()
    cursor.close()
    conn.close()
    
