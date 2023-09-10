-- This SQL script is used to create tables for storing Formula One race data, including race results,
-- qualifying results, and lap times. The script also includes a step to update driver names in the
-- lap_times table to match the format in the race_results table for consistency.

-- Create a table to store Formula One race results
CREATE TABLE race_results (
    race_name VARCHAR(50),     -- Name of the race
    position INT,              -- Finishing position of the driver
    driver VARCHAR(50),        -- Full name of the driver
    team VARCHAR(50),          -- Name of the driver's team
    "status" VARCHAR(50)       -- Status or result of the race (e.g., Finished, Retired)
);

-- View the race results table to verify its structure
SELECT *
FROM race_results;

-- Create a table to store Formula One qualifying results
CREATE TABLE qualifying_results (
    race_name VARCHAR(50),     -- Name of the race
    position INT,              -- Qualifying position of the driver
    driver VARCHAR(50),        -- Full name of the driver
    team VARCHAR(50),          -- Name of the driver's team
    Q1 VARCHAR(10),            -- Qualifying time in Q1 session
    Q1_time_difference VARCHAR(10), -- Time difference in Q1 session (if applicable)
    Q2 VARCHAR(10),            -- Qualifying time in Q2 session
    Q2_time_difference VARCHAR(10), -- Time difference in Q2 session (if applicable)
    Q3 VARCHAR(10),            -- Qualifying time in Q3 session (if applicable)
    Q3_time_difference VARCHAR(10)  -- Time difference in Q3 session (if applicable)
);

-- View the qualifying results table to verify its structure
SELECT *
FROM qualifying_results;

-- Create a table to store Formula One race lap times
CREATE TABLE lap_times (
    race_name VARCHAR(50),     -- Name of the race
    lap_number INT,            -- Lap number in the race
    position INT,              -- Position of the driver at the end of the lap
    driver VARCHAR(50),        -- Full name of the driver
    lap_time VARCHAR(10)       -- Lap time taken by the driver
);

-- View the lap times table to verify its structure

-- The following section is used to update driver names in the lap_times table
-- to match the format in the race_results table.
-- This ensures consistency in driver names across tables.

-- Create a common table expression (CTE) to match driver names between lap_times and race_results
WITH match_names AS (
    SELECT lap_times.race_name, 
           lap_times.driver AS wrong_format, 
           race_results.driver AS correct_format
    FROM lap_times
    JOIN race_results ON UPPER(SUBSTRING(lap_times.driver, CHARINDEX('_', lap_times.driver) + 1, LEN(lap_times.driver) - CHARINDEX('_', lap_times.driver))) = 
                         UPPER(SUBSTRING(race_results.driver, CHARINDEX(' ', race_results.driver) + 1, LEN(race_results.driver) - CHARINDEX(' ', race_results.driver)))
)

-- Update driver names in lap_times to match the correct format from race_results
UPDATE lap_times
SET lap_times.driver = match_names.correct_format
FROM lap_times
JOIN match_names ON lap_times.driver = match_names.wrong_format;

-- View the lap times table to verify that driver names have been updated
SELECT *
FROM lap_times;
