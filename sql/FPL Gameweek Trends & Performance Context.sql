CREATE OR REPLACE VIEW fpl_total_points_by_gameweek AS
SELECT
    e.event_id AS gameweek,
    SUM(pgs.points) AS total_points
FROM player_gameweek_stats pgs
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND pgs.minutes > 0
GROUP BY
    e.event_id
ORDER BY
    e.event_id;
############################################################## 
SELECT * FROM  fpl_total_points_by_gameweek;   
##########################################################*
CREATE OR REPLACE VIEW fpl_position_avg_points_trend AS
SELECT
    e.event_id AS gameweek,
    CASE
        WHEN p.position = '1' THEN 'GK'
        WHEN p.position = '2' THEN 'DF'
        WHEN p.position = '3' THEN 'MID'
        WHEN p.position = '4' THEN 'FWD'
    END AS position,
    ROUND(AVG(pgs.points), 2) AS avg_points_per_player
FROM player_gameweek_stats pgs
JOIN players p
    ON pgs.player_id = p.player_id
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND pgs.minutes > 0
GROUP BY
    e.event_id,
    CASE
        WHEN p.position = '1' THEN 'GK'
        WHEN p.position = '2' THEN 'DF'
        WHEN p.position = '3' THEN 'MID'
        WHEN p.position = '4' THEN 'FWD'
    END
ORDER BY
    e.event_id;
######################################################
SELECT * FROM fpl_position_avg_points_trend;
#########################################################
CREATE OR REPLACE VIEW fpl_position_pp90_trend AS
SELECT
    e.event_id AS gameweek,

    p.player_id,
    p.player_name,

    t.team_name,

    CASE
        WHEN p.position = '1' THEN 'GK'
        WHEN p.position = '2' THEN 'DF'
        WHEN p.position = '3' THEN 'MID'
        WHEN p.position = '4' THEN 'FWD'
    END AS position,

    SUM(pgs.points) AS gameweek_points,
    SUM(pgs.minutes) AS gameweek_minutes
FROM player_gameweek_stats pgs
JOIN players p
    ON pgs.player_id = p.player_id
JOIN teams t
    ON p.team_id = t.team_id
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND pgs.minutes > 0
GROUP BY
    e.event_id,
    p.player_id,
    p.player_name,
    t.team_name,
    CASE
        WHEN p.position = '1' THEN 'GK'
        WHEN p.position = '2' THEN 'DF'
        WHEN p.position = '3' THEN 'MID'
        WHEN p.position = '4' THEN 'FWD'
    END
ORDER BY
    e.event_id,
    p.player_name;
###############################################################   
SELECT * FROM fpl_position_pp90_trend;
#####################################################################
CREATE OR REPLACE VIEW fpl_players_played_per_gameweek AS
SELECT
    e.event_id AS gameweek,
    COUNT(DISTINCT pgs.player_id) AS players_played
FROM player_gameweek_stats pgs
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND pgs.minutes > 0
GROUP BY
    e.event_id
ORDER BY
    e.event_id;
SELECT * FROM fpl_players_played_per_gameweek ;
##########################################################################
CREATE OR REPLACE VIEW fpl_latest_gameweek_total_points AS
SELECT
    e.event_id AS gameweek,
    SUM(pgs.points) AS total_points
FROM player_gameweek_stats pgs
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND pgs.minutes > 0
    AND e.event_id = (
        SELECT MAX(event_id)
        FROM events
        WHERE finished = TRUE
    )
GROUP BY
    e.event_id;
############################################
CREATE OR REPLACE VIEW fpl_latest_gw_top3_players_by_position AS
SELECT
    gameweek,
    player_name,
    team_name,
    position,
    gameweek_points
FROM (
    SELECT
        e.event_id AS gameweek,
        p.player_name,
        t.team_name,
        CASE
            WHEN p.position = '1' THEN 'GK'
            WHEN p.position = '2' THEN 'DF'
            WHEN p.position = '3' THEN 'MID'
            WHEN p.position = '4' THEN 'FWD'
        END AS position,
        pgs.points AS gameweek_points,
        RANK() OVER (
            PARTITION BY p.position
            ORDER BY pgs.points DESC
        ) AS position_rank
    FROM player_gameweek_stats pgs
    JOIN players p
        ON pgs.player_id = p.player_id
    JOIN teams t
        ON p.team_id = t.team_id
    JOIN events e
        ON pgs.event_id = e.event_id
    WHERE
        e.finished = TRUE
        AND e.event_id = (
            SELECT MAX(event_id)
            FROM events
            WHERE finished = TRUE
        )
        AND pgs.minutes > 0
) ranked_players
WHERE position_rank <= 3
ORDER BY
    position,
    position_rank;
#######################################
CREATE OR REPLACE VIEW fpl_top5_high_value_last5_gws AS
WITH last_5_gws AS (
    SELECT event_id
    FROM events
    WHERE finished = TRUE
    ORDER BY event_id DESC
    LIMIT 5
),

player_last5 AS (
    SELECT
        p.player_id,
        p.player_name,
        t.team_name,
        CASE
            WHEN p.position = '1' THEN 'GK'
            WHEN p.position = '2' THEN 'DF'
            WHEN p.position = '3' THEN 'MID'
            WHEN p.position = '4' THEN 'FWD'
        END AS position,
        p.cost,
        SUM(pgs.points) AS total_points_last5,
        SUM(pgs.minutes) AS total_minutes_last5,
        COUNT(DISTINCT pgs.event_id) AS games_played_last5,
        SUM(pgs.points) / p.cost AS points_per_pound_last5
    FROM player_gameweek_stats pgs
    JOIN players p
        ON pgs.player_id = p.player_id
    JOIN teams t
        ON p.team_id = t.team_id
    JOIN last_5_gws gws
        ON pgs.event_id = gws.event_id
    WHERE
        pgs.minutes >= 45
    GROUP BY
        p.player_id,
        p.player_name,
        t.team_name,
        CASE
            WHEN p.position = '1' THEN 'GK'
            WHEN p.position = '2' THEN 'DF'
            WHEN p.position = '3' THEN 'MID'
            WHEN p.position = '4' THEN 'FWD'
        END,
        p.cost
),

league_avg_value AS (
    SELECT
        AVG(points_per_pound_last5) AS avg_points_per_pound
    FROM player_last5
)

SELECT
    player_name,
    team_name,
    position,
    total_points_last5,
    points_per_pound_last5
FROM player_last5
WHERE
    games_played_last5 = 5
    AND points_per_pound_last5 >= (
        SELECT avg_points_per_pound
        FROM league_avg_value
    )
ORDER BY
    total_points_last5 DESC
LIMIT 5;
#######################
CREATE OR REPLACE VIEW fpl_latest_gw_avg_points_by_position AS
SELECT
    CASE
        WHEN p.position = '1' THEN 'GK'
        WHEN p.position = '2' THEN 'DF'
        WHEN p.position = '3' THEN 'MID'
        WHEN p.position = '4' THEN 'FWD'
    END AS position,
    ROUND(AVG(pgs.points), 2) AS avg_points_per_player
FROM player_gameweek_stats pgs
JOIN players p
    ON pgs.player_id = p.player_id
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND e.event_id = (
        SELECT MAX(event_id)
        FROM events
        WHERE finished = TRUE
    )
    AND pgs.minutes > 0
GROUP BY
    CASE
        WHEN p.position = '1' THEN 'GK'
        WHEN p.position = '2' THEN 'DF'
        WHEN p.position = '3' THEN 'MID'
        WHEN p.position = '4' THEN 'FWD'
    END;
#############################################################
CREATE OR REPLACE VIEW fpl_team_avg_points_per_gameweek AS
SELECT
    e.event_id AS gameweek,
    t.team_name,
    ROUND(AVG(pgs.points), 2) AS avg_points_per_player
FROM player_gameweek_stats pgs
JOIN players p
    ON pgs.player_id = p.player_id
JOIN teams t
    ON p.team_id = t.team_id
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND pgs.minutes > 0
GROUP BY
    e.event_id,
    t.team_name
ORDER BY
    e.event_id,
    avg_points_per_player DESC;
SELECT * FROM fpl_team_avg_points_per_gameweek;    
###############
CREATE OR REPLACE VIEW fpl_last2_gw_total_points AS
SELECT
    e.event_id AS gameweek,
    SUM(pgs.points) AS total_points
FROM player_gameweek_stats pgs
JOIN events e
    ON pgs.event_id = e.event_id
WHERE
    e.finished = TRUE
    AND pgs.minutes > 0
    AND e.event_id IN (
        SELECT event_id
        FROM (
            SELECT event_id
            FROM events
            WHERE finished = TRUE
            ORDER BY event_id DESC
            LIMIT 2
        ) latest_gws
    )
GROUP BY
    e.event_id
ORDER BY
    e.event_id DESC;
#######################################################
CREATE OR REPLACE VIEW fpl_last2_gw_total_points AS
SELECT
    e.event_id AS gameweek,
    SUM(pgs.points) AS total_points
FROM player_gameweek_stats pgs
JOIN events e
    ON pgs.event_id = e.event_id
JOIN (
    SELECT event_id
    FROM events
    WHERE finished = TRUE
    ORDER BY event_id DESC
    LIMIT 2
) last_two_gws
    ON e.event_id = last_two_gws.event_id
WHERE
    pgs.minutes > 0
GROUP BY
    e.event_id
ORDER BY
    e.event_id DESC;