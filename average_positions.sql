-- This SQL query is focused on generating insights from Formula One race and qualifying data.
-- It creates intermediate tables to calculate position changes between race and qualifying,
-- as well as average positions for each driver across races.

-- Create a new table called 'positions' to store calculated position data.
SELECT race_results.race_name, 
       race_results.driver, 
       qualifying_results.position AS qualifying_position, 
	   race_results.position AS race_position,
	   qualifying_results.position - race_results.position AS position_change
INTO positions
FROM race_results
INNER JOIN qualifying_results ON race_results.driver = qualifying_results.driver AND race_results.race_name = qualifying_results.race_name;

-- View the 'positions' table to verify the calculated position data.
SELECT *
FROM positions;

-- Create a new table called 'average_positions' to calculate and store average position data for each driver.
SELECT driver, 
       AVG(qualifying_position) AS average_race_position,
	   AVG(race_position) AS average_qualifying_position,
	   AVG(position_change) AS average_position_change
INTO average_positions
FROM positions
GROUP BY driver;

-- View the 'average_positions' table to see the calculated average position data.
SELECT *
FROM average_positions;
