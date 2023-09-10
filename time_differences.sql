-- This SQL script is used to calculate and update time differences in Formula One qualifying results
-- and then apply these differences to the 'qualifying_results' table.

-- Create a temporary table called '#time_values' to store intermediate values.
-- The table includes columns for position, race name, and three qualifying times (Q1, Q2, Q3) and their differences.
CREATE TABLE #time_values (
	position INT,
	race_name VARCHAR(50),
	Q1 TIME(3) NULL,
	Q1_DIFF VARCHAR(10),
	Q2 TIME(3) NULL,
	Q2_DIFF VARCHAR(10),
	Q3 TIME(3) NULL,
	Q3_DIFF VARCHAR(10)
);

-- Insert data into the '#time_values' table by converting and formatting qualifying times and calculating differences.
INSERT INTO #time_values (position, race_name, Q1, Q2, Q3)
SELECT position, race_name,
       (CASE WHEN Q1 <> '' THEN (CONVERT (TIME(3), CONCAT('00:', Q1))) END),
	   (CASE WHEN Q2 <> '' THEN (CONVERT (TIME(3), CONCAT('00:', Q2))) END),  
	   (CASE WHEN Q3 <> '' THEN (CONVERT (TIME(3), CONCAT('00:', Q3))) END)
FROM qualifying_results;

-- Create a common table expression (CTE) called 'time_diff' to calculate time differences between qualifying sessions.
WITH time_diff AS (
    SELECT *,
	       (CONVERT(FLOAT, DATEDIFF(MILLISECOND, lag(Q1) OVER (ORDER BY (SELECT NULL)), Q1)) / 1000) AS diff_1,
           (CONVERT(FLOAT, DATEDIFF(MILLISECOND, lag(Q2) OVER (ORDER BY (SELECT NULL)), Q2)) / 1000) AS diff_2,
           (CONVERT(FLOAT, DATEDIFF(MILLISECOND, lag(Q3) OVER (ORDER BY (SELECT NULL)), Q3)) / 1000) AS diff_3
    FROM #time_values
)

-- Update the '#time_values' table with calculated time differences, considering whether they are positive or negative.
UPDATE #time_values
SET Q1_DIFF = (CASE WHEN time_diff.diff_1 >= 0 THEN CONCAT('+', CONVERT(VARCHAR(10), time_diff.diff_1)) ELSE CONVERT(VARCHAR(10), time_diff.diff_1) END),
    Q2_DIFF = (CASE WHEN time_diff.diff_2 >= 0 THEN CONCAT('+', CONVERT(VARCHAR(10), time_diff.diff_2)) ELSE CONVERT(VARCHAR(10), time_diff.diff_2) END),
    Q3_DIFF = (CASE WHEN time_diff.diff_3 >= 0 THEN CONCAT('+', CONVERT(VARCHAR(10), time_diff.diff_3)) ELSE CONVERT(VARCHAR(10), time_diff.diff_3) END)
FROM #time_values
JOIN time_diff ON time_diff.Q1 = #time_values.Q1;

-- View the '#time_values' table to verify the calculated time differences.
SELECT *
FROM #time_values;

-- Update the 'qualifying_results' table with the calculated time differences from the '#time_values' table.
UPDATE qualifying_results
SET Q1_time_difference = #time_values.Q1_DIFF,
    Q2_time_difference = #time_values.Q2_DIFF,
	Q3_time_difference = #time_values.Q3_DIFF
FROM qualifying_results
JOIN #time_values ON #time_values.position = qualifying_results.position AND #time_values.race_name = qualifying_results.race_name;

-- View the 'qualifying_results' table to see the updated qualifying time differences.
SELECT *
FROM qualifying_results;
