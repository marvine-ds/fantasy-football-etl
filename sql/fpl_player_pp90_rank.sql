CREATE OR REPLACE VIEW fpl_player_pp90_rank AS
SELECT
    player_name,
    team_name,
    position,
    cost,
    total_points,
    minutes,
    points_per_90,
    value_category,
    impact_category,
        RANK() OVER (
        PARTITION BY position
        ORDER BY points_per_90 DESC
    ) AS position_pp90_rank
FROM fpl_player_value
WHERE minutes >= 1000;
