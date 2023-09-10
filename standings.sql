-- This SQL query is designed to calculate and update driver standings, team standings, and create a podium table.
-- It uses a defined points system to assign points to drivers based on their race positions.

-- Create a temporary table '#points_system' to store the predefined points system for race positions.
CREATE TABLE #points_system (
	position INT,
	points INT
);

-- View the '#points_system' table to double-check the predefined point values.
SELECT *
FROM #points_system;

-- Insert the predefined point values into the '#points_system' table.
INSERT INTO #points_system (position, points)
VALUES (1, 25), (2, 18), (3, 15), (4, 12), (5, 10), (6, 8), (7, 6), (8, 4), (9, 2), (10, 1),
       (11, 0), (12, 0), (13, 0), (14, 0), (15, 0), (16, 0), (17, 0), (18, 0), (19, 0), (20, 0);

-- Create a table 'driver_standings' to store driver standings information.
CREATE TABLE driver_standings (
	position INT,
	driver VARCHAR(50),
	points INT
);

-- Insert data into the 'driver_standings' table by calculating driver points using race results and the points system.
INSERT INTO driver_standings (driver, points)
SELECT race_results.driver, COALESCE(SUM(#points_system.points), 0)
FROM race_results
LEFT JOIN #points_system ON race_results.position = #points_system.position
GROUP BY race_results.driver;

-- Utilize a common table expression (CTE) 'rankings' to update the 'driver_standings' table with driver positions.
WITH rankings AS (
  SELECT driver, DENSE_RANK() OVER (ORDER BY points DESC) AS position
  FROM driver_standings
)
UPDATE driver_standings
SET driver_standings.position = rankings.position
FROM driver_standings
JOIN rankings ON driver_standings.driver = rankings.driver;

-- View the 'driver_standings' table to see the calculated driver standings.
SELECT *
FROM driver_standings
ORDER BY points DESC;

-- Create a table 'team_standings' to store team standings information.
CREATE TABLE team_standings (
	position INT,
	team VARCHAR(50),
	points INT
);

-- Insert data into the 'team_standings' table by calculating team points using race results and the points system.
INSERT INTO team_standings (team, points)
SELECT race_results.team, COALESCE(SUM(#points_system.points), 0)
FROM race_results
LEFT JOIN #points_system ON race_results.position = #points_system.position
GROUP BY race_results.team;

-- Utilize a CTE 'rankings' to update the 'team_standings' table with team positions.
WITH rankings AS (
  SELECT team, DENSE_RANK() OVER (ORDER BY points DESC) AS position
  FROM team_standings
)
UPDATE team_standings
SET team_standings.position = rankings.position
FROM team_standings
JOIN rankings ON team_standings.team = rankings.team;

-- View the 'team_standings' table to see the calculated team standings.
SELECT *
FROM team_standings
ORDER BY points DESC;

-- Create a 'podium' table to store podium finishers for each race.
-- It uses conditional aggregation to identify the first, second, and third-place drivers.
SELECT race_name,
       MAX(CASE WHEN position = 1 THEN driver END) AS first_place,
       MAX(CASE WHEN position = 2 THEN driver END) AS second_place,
       MAX(CASE WHEN position = 3 THEN driver END) AS third_place
INTO podium
FROM race_results
GROUP BY race_name;

-- View the 'podium' table to see the podium finishers for each race.
SELECT *
FROM podium;
