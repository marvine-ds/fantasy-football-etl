CREATE OR REPLACE VIEW fpl_elite_value_impact_players AS
SELECT
    player_name,
    team_name,
    position,
    cost,
    total_points,
    minutes,
    points_per_dollar,
    points_per_90
FROM fpl_player_value
WHERE value_category = 'High Value'
  AND impact_category = 'High Impact'
  AND minutes >= 1000
ORDER BY points_per_dollar DESC;