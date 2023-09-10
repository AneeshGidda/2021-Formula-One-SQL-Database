-- This SQL script is designed to create and populate tables related to Formula One race data,
-- including tables for storing fastest laps and average lap times for drivers in each race.
-- It also includes a step to calculate and extract the fastest laps and average lap times from
-- the existing lap_times table.

-- Create a table to store the fastest laps in Formula One races
CREATE TABLE fastest_laps (
	race_name VARCHAR(50),       -- Name of the race
	driver VARCHAR(50),          -- Full name of the driver who set the fastest lap
	fastest_lap_time VARCHAR(10) -- The time of the fastest lap
);

-- Insert data into the fastest_laps table by manipulating the lap_times table
-- to extract the fastest laps for each race.
INSERT INTO fastest_laps (race_name, driver, fastest_lap_time)
SELECT lap_times.race_name, driver, lap_time
FROM lap_times
INNER JOIN (
	SELECT race_name, MIN(lap_time) as fastest_lap
	FROM lap_times
	GROUP BY race_name
) AS fastest 
ON lap_times.race_name = fastest.race_name
WHERE lap_times.lap_time = fastest.fastest_lap;

-- View the fastest_laps table to verify the fastest lap data
SELECT *
FROM fastest_laps;

-- Create a table to store the average lap times for drivers in Formula One races
CREATE TABLE average_lap_times (
	race_name VARCHAR(50),       -- Name of the race
	driver VARCHAR(50),          -- Full name of the driver
	average_lap_time VARCHAR(10) -- The average lap time for the driver in the race
);

-- Insert data into the average_lap_times table by calculating the average lap time
-- for each driver in each race.
INSERT INTO average_lap_times (race_name, driver, average_lap_time)
SELECT race_name, driver,
	   (CAST(AVG(DATEPART(MINUTE, CONVERT(TIME(3), CONCAT('00:', lap_time)))) AS VARCHAR(2)) + ':' +
		CAST(AVG(DATEPART(SECOND, CONVERT(TIME(3), CONCAT('00:', lap_time)))) AS VARCHAR(2)) + '.' +
		CAST(AVG(DATEPART(MILLISECOND, CONVERT(TIME(3), CONCAT('00:', lap_time)))) AS VARCHAR(3))) as average
FROM lap_times
GROUP BY race_name, driver
ORDER BY race_name, average;

-- View the average_lap_times table to verify the average lap time data
SELECT *
FROM average_lap_times;

-- View the lap_times table to check the original lap time data
SELECT *
FROM lap_times;


