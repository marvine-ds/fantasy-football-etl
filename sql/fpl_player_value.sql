CREATE OR REPLACE VIEW fpl_player_value AS
SELECT 
    p.player_name,
    t.team_name,
    p.Position AS position_code,
    CASE 
	   WHEN position="1" THEN "GK"
       WHEN position="2" THEN "DF"
       WHEN position="3" THEN "MID"
       WHEN position="4" THEN "ST"
       ELSE "UKNOWN"
    END AS  position,
    p.cost,
    p.total_points,
    p.minutes,
    p.total_points/p.cost AS points_per_dollar,
    (p.total_points*90)/ p.minutes AS points_per_90,
    CASE
        WHEN (p.total_points / p.cost) >= 
             1.2 * (SELECT AVG(total_points / cost) FROM players WHERE minutes > 0)
            THEN 'High Value'
        WHEN (p.total_points / p.cost) >= 
             0.8 * (SELECT AVG(total_points / cost) FROM players WHERE minutes > 0)
            THEN 'Mid Value'
        ELSE 'Low Value'
    END AS value_category,
CASE
    WHEN p.minutes < 1000 THEN 'Low Minutes'
    WHEN ((p.total_points * 90.0) / p.minutes) >= 
         1.2 * (
             SELECT AVG((p2.total_points * 90.0) / p2.minutes)
             FROM players p2
             WHERE p2.position = p.position
               AND p2.minutes >= 1000
         )
        THEN 'High Impact'
    WHEN ((p.total_points * 90.0) / p.minutes) <= 
         0.8 * (
             SELECT AVG((p2.total_points * 90.0) / p2.minutes)
             FROM players p2
             WHERE p2.position = p.position
               AND p2.minutes >= 1000
         )
        THEN 'Low Impact'
    ELSE 'Mid Impact'
END AS impact_category
   
FROM players as p
JOIN teams as t
	 ON  p.team_id =t.team_id
WHERE minutes >0 ;  