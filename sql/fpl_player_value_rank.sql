CREATE OR REPLACE VIEW fpl_player_value_rank AS
SELECT *
FROM (
    SELECT
        player_name,
        team_name,
        position,
        cost,
        total_points,
        minutes,
        points_per_dollar,
        value_category,
        impact_category,
        RANK() OVER (
            PARTITION BY position
            ORDER BY points_per_dollar DESC
        ) AS position_value_rank
 FROM fpl_player_value
) ranked_players;