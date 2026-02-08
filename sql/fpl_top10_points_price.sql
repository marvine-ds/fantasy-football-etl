CREATE OR REPLACE VIEW fpl_top10_points_price AS
SELECT
    P.player_name,
    t.team_name,
    p.position,
    p.cost,
    p.total_points,
    p.minutes
FROM players p
JOIN teams AS t
ON p.team_id = t.team_id
WHERE minutes > 0
ORDER BY total_points DESC
LIMIT 10;