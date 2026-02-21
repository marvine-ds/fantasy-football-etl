print("mysql_load.py started")

import mysql.connector
from config import DB_CONFIG


def get_connection():
    print("Connecting to MySQL...")
    return mysql.connector.connect(**DB_CONFIG)


def insert_dataframe(df, table_name):
    """
    Generic upsert loader for dimension tables.
    Uses ON DUPLICATE KEY UPDATE for idempotent re-runs.
    """
    print(f"Inserting into {table_name}")

    if df.empty:
        print(f"No data to insert into {table_name}")
        return

    conn = get_connection()
    cursor = conn.cursor()

    columns = list(df.columns)
    columns_str = ", ".join(columns)
    placeholders = ", ".join(["%s"] * len(columns))

    update_clause = ", ".join(
        [f"{col}=VALUES({col})" for col in columns]
    )

    sql = f"""
        INSERT INTO {table_name} ({columns_str})
        VALUES ({placeholders})
        ON DUPLICATE KEY UPDATE {update_clause}
    """

    data = df.values.tolist()

    cursor.executemany(sql, data)
    conn.commit()

    print(f"{cursor.rowcount} rows affected in {table_name}")

    cursor.close()
    conn.close()


def insert_facts(df):
    """
    Insert fact table using INSERT IGNORE
    to avoid duplicate gameweek entries.
    """
    print("Inserting player gameweek facts")

    if df.empty:
        print("No fact data to insert")
        return

    conn = get_connection()
    cursor = conn.cursor()

    sql = """
        INSERT IGNORE INTO player_gameweek_stats
        (player_id, event_id, points, minutes)
        VALUES (%s, %s, %s, %s)
    """

    data = df.values.tolist()

    cursor.executemany(sql, data)
    conn.commit()

    print(f"{cursor.rowcount} fact rows inserted")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    print("MAIN BLOCK RUNNING")

    from api_fetch import fetch_api_data
    from raw_to_df import extract_teams, extract_events, extract_players
    from clean_data import clean_teams, clean_events, clean_players

    raw = fetch_api_data()
    print("API data fetched")

    # Load dimension tables
    teams_df = clean_teams(extract_teams(raw))
    insert_dataframe(teams_df, "teams")
    print("Teams loaded")

    events_df = clean_events(extract_events(raw))
    insert_dataframe(events_df, "events")
    print("Events loaded")

    players_df = clean_players(extract_players(raw))
    insert_dataframe(players_df, "players")
    print("Players loaded")