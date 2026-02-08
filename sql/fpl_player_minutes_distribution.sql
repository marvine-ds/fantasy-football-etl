CREATE OR REPLACE VIEW fpl_player_minutes_distribution AS
SELECT
    CASE
        WHEN minutes = 0 THEN '0 Min'
        WHEN minutes < 1000 THEN '< 1000 Min'
        ELSE '1000+ Min'
    END AS minutes_group,
    COUNT(*) AS total_players
FROM players
GROUP BY minutes_group
ORDER BY
    CASE minutes_group
        WHEN '1000+ Min' THEN 1
        WHEN '< 1000 Min' THEN 2
        WHEN '0 Min' THEN 3
    END;