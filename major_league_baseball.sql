CREATE DATABASE major_league_baseball;
USE major_league_baseball;

-- School analysis

SELECT * FROM SCHOOLS;
SELECT * FROM SCHOOL_DETAILS;

-- In each decade , How many shcools were there that produced players 
SELECT 		ROUND(yearID, -1) AS Decade,COUNT(DISTINCT schoolID)AS Num_schools
FROM 		schoolS
GROUP BY 	Decade
ORDER BY	Decade;

-- Names of the top 5 schools that produced the most playrers (JOINS)

SELECT * FROM SCHOOLS;
SELECT * FROM SCHOOL_DETAILS;

SELECT 		sd.name_full, COUNT(DISTINCT s.playerID) AS num_player
FROM 		schools s LEFT JOIN school_details sd
			ON s.schoolID = sd.schoolID
GROUP BY 	s.schoolID
ORDER BY	num_player DESC
LIMIT 		5;

-- For each decade, what were the names of the top 3 schools that produced the most players [ Windows functions]

SELECT * FROM SCHOOLS;
SELECT * FROM SCHOOL_DETAILS;

WITH sd AS (
		SELECT		sd.name_full,ROUND(s.yearID,-1)AS Decade, COUNT(DISTINCT s.playerID) AS Num_players
		FROM 		schools s LEFT JOIN school_details sd
					ON s.schoolID = sd.schoolID
		GROUP BY 	Decade, s.schoolID
		ORDER BY	Decade
) ,
rn AS ( SELECT Decade,name_full,Num_players,
		ROW_NUMBER()OVER(PARTITION BY Decade ORDER BY Num_players desc) AS Row_num
FROM SD)
SELECT 	Decade,name_full,Num_players
FROM  	rn
WHERE 	Row_num <= 3
ORDER BY 	Decade DESC, Row_num
;

# Player career Analaysis
SELECT * FROM SCHOOLS;
SELECT * FROM SCHOOL_DETAILS;
SELECT * FROM players;

/* Calculate the career length of each player, their age at their first game, 
and their age at their last game (all in years). Sort from longest career.*/

SELECT	nameGiven,debut,finalGame,
		CAST(CONCAT(birthYear,'-',birthMonth,'-', birthDay)AS DATE)AS Birthday,
        TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear,'-',birthMonth,'-', birthDay)AS DATE),debut)AS Starting_age,
        TIMESTAMPDIFF(YEAR, CAST(CONCAT(birthYear,'-',birthMonth,'-', birthDay)AS DATE),finalGame) AS End_age,
        TIMESTAMPDIFF (YEAR, debut,finalGame) AS Career_length
FROM	PLAYERS
ORDER BY Career_length DESC;

-- What team did each player play on for their starting and ending years?
SELECT * FROM players;
SELECT * FROM salaries;

SELECT 	p.nameGiven,
		s.yearID AS Starting_year , s.teamID AS Starting_team,
        e.yearID AS Ending_year , e.teamID AS Ending_team
FROM 	players p INNER JOIN salaries s
		ON p.playerID = s.playerID
        AND YEAR(p.debut) = s.yearID
	INNER JOIN salaries e
    ON p.playerID = e.playerID
    AND YEAR(p.finalGame) = e.yearID;

-- Players have same birthday.

WITH bn as (SELECT 	
		CAST(CONCAT(birthYear, '-',birthMonth,'-', birthDay)AS DATE)AS Birthdate,
		nameGiven
FROM 	players)

SELECT birthdate, GROUP_CONCAT(nameGiven SEPARATOR', '),COUNT(nameGiven)
FROM bn
WHERE birthdate IS NOT NULL AND YEAR (birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
HAVING COUNT(nameGiven) > 2
ORDER BY birthdate
;

-- summary table that shows for each team, what percent of players bat right, left and both [Pivoting]
SELECT	s.teamID,
		ROUND(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_right,
        ROUND(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_left,
        ROUND(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) / COUNT(s.playerID) * 100, 1) AS bats_both
FROM	salaries s LEFT JOIN players p
		ON s.playerID = p.playerID
GROUP BY s.teamID;

-- average height and weight at debut game changed over the years, and what's the decade-over-decade difference? [Window Functions]
WITH hw AS (SELECT	FLOOR(YEAR(debut) / 10) * 10 AS decade,
					AVG(height) AS avg_height, AVG(weight) AS avg_weight
			FROM	players
			GROUP BY decade)
            
SELECT	decade,
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff,
        avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS weight_diff
FROM	hw
WHERE	decade IS NOT NULL;

