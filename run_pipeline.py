from api_fetch import fetch_api_data
from raw_to_df import extract_players
from clean_data import clean_players
from player_gw_fetch import (
    fetch_player_gameweek_history,
    prepare_fact_rows
)
from mysql_load import insert_facts

def run_gameweek_history_load():
    raw = fetch_api_data()
    players_df = clean_players(extract_players(raw))

    print(f"Loading gameweek history for {len(players_df)} players")

    for player_id in players_df["player_id"]:
        history_df = fetch_player_gameweek_history(player_id)
        fact_df = prepare_fact_rows(player_id, history_df)

        if not fact_df.empty:
            insert_facts(fact_df)

    print("Gameweek history load complete")


if __name__ == "__main__":
    run_gameweek_history_load()
