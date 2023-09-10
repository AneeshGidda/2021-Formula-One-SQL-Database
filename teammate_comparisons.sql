-- This SQL script creates a table 'teammate_comparisons' to analyze and compare the performance 
-- of teammates in Formula One based on qualifying and race results. It populates the table with 
-- information about driver performance within the same team.

-- Create the 'teammate_comparisons' table to store teammate performance comparisons.
CREATE TABLE teammate_comparisons (
	team VARCHAR(50),         -- Name of the team
	driver_one VARCHAR(50),   -- Full name of the first driver
	d1_qualifying INT,        -- Number of times the first driver outperformed in qualifying
	d1_race INT,              -- Number of times the first driver outperformed in races
	driver_two VARCHAR(50),   -- Full name of the second driver
	d2_qualifying INT,        -- Number of times the second driver outperformed in qualifying
	d2_race INT,              -- Number of times the second driver outperformed in races
	qualifying_winner VARCHAR(50), -- Driver who won more qualifying battles
	race_winner VARCHAR(50)        -- Driver who won more race battles
);

-- Insert data into the 'teammate_comparisons' table by comparing the performance of teammates
-- based on qualifying results.
INSERT INTO teammate_comparisons (team, driver_one, d1_qualifying, driver_two, d2_qualifying)
SELECT qr1.team, qr1.driver,
       (COUNT(CASE WHEN qr1.position < qr2.position THEN 1 END)),
	   qr2.driver, 
	   (COUNT(CASE WHEN qr1.position > qr2.position THEN 1 END))
FROM qualifying_results AS qr1
JOIN qualifying_results AS qr2 ON qr1.race_name = qr2.race_name AND qr1.team = qr2.team AND qr1.driver < qr2.driver
GROUP BY qr1.team, qr1.driver, qr2.driver;

-- Create a common table expression (CTE) 'race_comparions' to compare the performance of teammates
-- based on race results.
WITH race_comparions AS (
	SELECT rr1.team, rr1.driver AS driver_one,
       (COUNT(CASE WHEN rr1.position < rr2.position THEN 1 END)) AS d1_race,
	   rr2.driver AS driver_two, 
	   (COUNT(CASE WHEN rr1.position > rr2.position THEN 1 END)) AS d2_race
	FROM race_results AS rr1
	JOIN race_results AS rr2 ON rr1.race_name = rr2.race_name AND rr1.team = rr2.team AND rr1.driver < rr2.driver
	GROUP BY rr1.team, rr1.driver, rr2.driver
)

-- Update the 'teammate_comparisons' table with race comparison data from the 'race_comparions' CTE.
UPDATE teammate_comparisons
SET d1_race = race_comparions.d1_race,
	d2_race = race_comparions.d2_race
FROM teammate_comparisons
JOIN race_comparions ON teammate_comparisons.driver_one = race_comparions.driver_one AND teammate_comparisons.driver_two = race_comparions.driver_two;

-- Update the 'teammate_comparisons' table with the qualifying and race winners for each driver pair.
UPDATE teammate_comparisons
SET qualifying_winner = (CASE 
							WHEN d1_qualifying > d2_qualifying THEN driver_one 
							WHEN d1_qualifying < d2_qualifying THEN driver_two
							ELSE 'TIE'
						 END),
	race_winner = (CASE 
					  WHEN d1_race > d2_race THEN driver_one 
					  WHEN d1_race < d2_race THEN driver_two
					  ELSE 'TIE'
				   END);

-- View the 'teammate_comparisons' table to see the results of teammate performance comparisons.
SELECT *
FROM teammate_comparisons;
