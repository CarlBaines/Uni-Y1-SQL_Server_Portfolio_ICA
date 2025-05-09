USE EuroLeagues
ALTER AUTHORIZATION ON DATABASE:: EuroLeagues TO sa
GO

--SELECT * queries from the different tables in the EuroLeagues database.
--Explanation: Used to select all data from every column and row from a specific table in the EuroLeagues database.
SELECT * FROM country;
SELECT * FROM league;
SELECT * FROM match;
SELECT * FROM player;
SELECT * FROM player_attributes;
SELECT * FROM team;
SELECT * FROM team_attributes;

--Check the data types of all columns in the different tables stored in the EuroLeagues database.
--Explanation: Replace the TABLE_NAME string with the table that is needed for check.
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'player';

--Demo A1 Query One
--Module 3: Writing SELECT queries with single table.
--Description: Select all data from every column and row from the EuroLeagues.league table.
SELECT * FROM league;

--Demo A1 Query Two
--Module 3: Writing SELECT queries with single table.
--Description: Select the total number of goals scored from the EuroLeagues.match table.
--Explanation: Simple SELECT query that creates a calculated column, calling the sum function on the home_team_goal and away_team_goal columns.
SELECT SUM(home_team_goal + away_team_goal)
FROM match;

--Demo A2 Query One
--Module 3: Eliminating Duplicates with DISTINCT
--Description: Eliminate duplicate seasons from the EuroLeagues.match table and order them from earliest to latest.
--Explanation: This query uses a subquery and casts the season as a varchar type (it was initially stored as a text value), so that it can work directly with functions like LEFT().
--It extracts the starting years of the seasons (the first four characters), casts them to an int and orders them.
SELECT season
--Selects season from the result of the subquery
FROM(
	--Selects distinct seasons from the match table.
	SELECT DISTINCT CAST(season AS VARCHAR(MAX)) AS season
	FROM match
) AS season
--Orders the result set by the starting year of the seasons.
--The LEFT() function extracts the first four characters from the season string.
ORDER BY CAST(LEFT(season, 4) AS INT);

--Demo A2 Query Two
--Module 3: Eliminating Duplicates with DISTINCT
--Description: Select unique player names from the EuroLeagues.player table and stores them in a column called 'AllPlayerNames'.
SELECT DISTINCT CAST(player_name AS VARCHAR(MAX)) AS AllPlayerNames
FROM player;

--Demo A3 Query One
--Module 3: Using Column and Table Aliases Lesson
--Description: Select the total number of goals scored from the EuroLeagues.match table and assign the column the 'TotalGoalsScored' alias.
SELECT SUM(home_team_goal + away_team_goal) AS TotalGoalsScored
FROM match;

--Demo A3 Query Two
--Module 3: Using Column and Table Aliases Lesson
--Description: Select all columns from the EuroLeagues.team table using the alias 'MiddlesbroughFCInfo', where the team_long_name is Middlesbrough.
SELECT id, team_api_id, team_fifa_api_id, team_long_name, team_short_name
FROM team AS MiddlesbroughFCInfo
WHERE CAST(team_long_name AS VARCHAR(MAX)) = 'Middlesbrough';

--Demo A4 Query One
--Module 4: Writing Simple CASE expressions
--Description: Categorise countries by league tier.
--The name of the countries is casted as a varchar so that it can work directly with functions.
SELECT CAST(name AS VARCHAR(MAX)) AS country_names,
	CASE
		--If the country name is in the when clause, the 'Top 5 League' string is written to the league_tier column,
		--for the associated country name.
		WHEN CAST(name AS VARCHAR(MAX)) IN ('England', 'Spain', 'France', 'Germany', 'Italy') THEN 'Top 5 League'
		--Else, the 'Not in Top 5' string is written to the league_tier column for the associated country name.
		ELSE 'Not in Top 5'
	END AS League_Tier
FROM country;

--Demo A4 Query Two
--Module 4: Writing Simple CASE expressions
--Description: Determine the result of a match using the match table.
SELECT id AS match_id,
	CASE
		WHEN home_team_goal > away_team_goal THEN 'Home Team Won'
		WHEN home_team_goal < away_team_goal THEN 'Away Team Won'
		ELSE 'Draw'
	END AS Result
FROM match;

--Demo B1 Query One
--Module 1: How to provide data from 2 related tables with a Join.
--Description: Select the league names associated with each country.
SELECT c.name AS country_name, l.name AS league_name
FROM country AS c
JOIN league AS l
ON c.id = l.country_id;

--Demo B1 Query Two
--Module 1: How to provide data from 2 related tables with a Join.
SELECT DISTINCT p.player_api_id, CAST(p.player_name AS varchar(MAX)) AS player_name, pa.overall_rating, pa.potential AS potential_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
ORDER BY p.player_api_id;
--Notice how there are many duplicate player names and ratings, this is because each player has had multiple ratings assigned to them across many career dates.


--Demo B2 Query One
--Module 4: How to query with inner joins.
--Description: Select all the different ratings of the best player (the best player has the highest overall and potential ratings)
--Lionel Messi.
SELECT p.player_api_id, CAST(p.player_name AS varchar(MAX)) AS player_name, pa.overall_rating, pa.potential AS potential_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
--The overall rating from the player_attributes table must be equal to the result of the subquery.
--The subquery selects the max overall rating from the player_attributes table.
WHERE pa.overall_rating = (SELECT MAX(pa.overall_rating) FROM player_attributes AS pa)
ORDER BY p.player_api_id

--Demo B2 Query Two
--Module 4: How to query with inner joins
--Description: Join the match table with the team table to get the home and away team names.
SELECT DISTINCT team_api_id, CAST(team_long_name AS varchar(MAX)) AS team_long_name
FROM team
JOIN match
ON home_team_api_id = team_api_id OR away_team_api_id = team_api_id
ORDER BY team_api_id;

--Demo B3 Query One
--Module 4: How to query with outer joins
--Description: full outer join between team and team_attributes to retrieve a distinct list of all teams, including those with or without associated attribute data.
SELECT DISTINCT t.team_fifa_api_id, CAST(t.team_long_name AS varchar(MAX)) AS team_long_name, CAST(t.team_short_name AS varchar(MAX)) AS team_short_name
FROM team AS t
--Returns all records when there is a match in both the team and team_attributes table.
FULL OUTER JOIN team_attributes AS ta
ON t.team_fifa_api_id = ta.team_fifa_api_id;

--Demo B3 Query Two
--Module 4: How to query with outer joins
--Description: full outer join between match and team to retrieve a distinct list of all matches, ensuring that match data is included even if team details are duplicated or missing due to the join condition.
SELECT DISTINCT CAST(m.mdate AS varchar(MAX)) AS match_date, m.match_api_id, m.home_team_api_id, m.away_team_api_id, m.home_team_goal, m.away_team_goal
FROM match AS m
FULL OUTER JOIN team AS t
ON m.home_team_api_id = t.team_api_id OR m.away_team_api_id = t.team_api_id;

--Demo B4 Query One
--Module 4: How to query with cross and self joins
--Description: Retrieves distinct player names, their fifa API ids, overall ratings, and preferred foot by cross joining the player and player_attributes tables together.
SELECT DISTINCT CAST(p.player_name AS varchar(MAX)) AS player_name, p.player_fifa_api_id, pa.overall_rating, CAST(pa.preferred_foot AS varchar(MAX)) AS preferred_foot
FROM player AS p
CROSS JOIN player_attributes AS pa
WHERE p.player_api_id = pa.player_api_id;

--Demo B4 Query Two
--Module 4: How to query with cross and self joins 
--Description: Retrieves top 100 distinct player comparisons between a specific player and other players based on their finishing and shot power attributes.
--The player for comparison is Patryk Rachwal.
SELECT DISTINCT TOP 100 
	   p1.player_api_id AS p1_api_id,
	   CAST(p1_player.player_name AS varchar(MAX)) AS player_for_comparison,
	   p1.finishing,
	   p1.shot_power,
	   p2.player_api_id AS p2_api_id,
	   CAST(p2_player.player_name AS varchar(MAX)) AS p2_name,
	   p2.finishing,
	   p2.shot_power
FROM player_attributes p1
JOIN player_attributes p2
	ON p1.player_api_id = 2625 AND p1.player_api_id <> p2.player_api_id
JOIN player p1_player ON p1.player_api_id = p1_player.player_api_id
JOIN player p2_player ON p2.player_api_id = p2_player.player_api_id
ORDER BY p2.player_api_id;

--Demo C1 Query One
--Module 5: How to Sort Data
--Description: Select id and player names from the EuroLeagues.player table, ordering the id in ascending order.
--Simple SELECT query with ORDER by clause.
SELECT id, player_name
FROM player
ORDER BY id ASC;

--Demo C1 Query Two
--Module 5: How to Sort Data
--Description: Selects the player_api_id, name and height from the EuroLeagues.player table, ordering the players by height in descending order.
SELECT player_api_id, player_name, height
FROM player
ORDER BY height DESC;

--Demo C2 Query One
--Module 5: How to filter data with predicates.
--Description: Retrieves a list of distinct players that have an overall rating greater than 80. Each player only appears once with their highest rating.
SELECT DISTINCT pa.player_fifa_api_id, CAST(p.player_name AS varchar(MAX)) AS player_name, MAX(pa.overall_rating) AS overall_rating
FROM player_attributes AS pa
JOIN player AS p
ON p.player_fifa_api_id = pa.player_fifa_api_id
WHERE overall_rating > 80
GROUP BY pa.player_fifa_api_id, CAST(p.player_name AS varchar(MAX));

--Demo C2 Query Two
--Module 5: How to filter data with predicates.
--Description: The query retrieves all match details involving Middlesbrough, including the teams they played, the season (as well as its stage), the matchID and the goals scored.
SELECT
	home_team.team_api_id AS home_team_api_id,
	CAST(home_team.team_long_name AS VARCHAR(MAX)) AS home_team,
	away_team.team_api_id AS away_team_api_id,
	CAST(away_team.team_long_name AS VARCHAR(MAX)) AS away_team,
	CAST(m.season AS VARCHAR(MAX)) AS season,
	m.stage,
	m.match_api_id,
	m.home_team_goal,
	m.away_team_goal
FROM match AS m
JOIN team AS home_team ON home_team.team_api_id = m.home_team_api_id
JOIN team AS away_team ON away_team.team_api_id = m.away_team_api_id
WHERE 
	CAST(home_team.team_long_name AS varchar(MAX)) = 'Middlesbrough'
	OR CAST(away_team.team_long_name AS varchar(MAX)) = 'Middlesbrough';

--Demo C3 Query One
--Module 5: How to filter data with TOP and OFFSET-FETCH.
--Description: Selects top 100 players and their api ids from the players table, joining with the player attributes table to get their overall ratings.
--Their overall ratings are ordered in descending order.
SELECT DISTINCT TOP 100 CAST(p.player_name AS nvarchar(MAX)) AS player_name, p.player_api_id, ISNULL(pa.overall_rating, '0') AS overall_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
GROUP BY CAST(p.player_name AS nvarchar(MAX)), p.player_api_id, pa.overall_rating
ORDER BY overall_rating DESC

--Demo C3 Query Two
--Module 5: How to filter data with TOP and OFFSET-FETCH
--Description: Selects the bottom 10 of the top 100 players with their api ids from the players table, joining with the players attributes table to get their overall ratings.
SELECT DISTINCT CAST(p.player_name AS nvarchar(MAX)) AS player_name, p.player_api_id, ISNULL(pa.overall_rating, '0') AS overall_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
GROUP BY CAST(p.player_name AS nvarchar(MAX)), p.player_api_id, pa.overall_rating
ORDER BY overall_rating DESC
OFFSET 90 ROWS
FETCH NEXT 10 ROWS ONLY;

--Demo C4 Query One
--Module 5: How to work with unknown values
--Description: Selects the team_fifa_api_id, the long name and short name of teams from the teams table. 
--If the team_fifa_api_id is null, the string 'No FIFA API ID' is replaced in place of the null value.
SELECT ISNULL(CAST(TRY_CAST(team_fifa_api_id AS INT) AS VARCHAR(255)), 'No FIFA API ID') AS fifa_api_id, team_long_name, team_short_name
FROM team;

--Demo C4 Query Two
--Module 5: How to work with unknown values
--Description: Returns a list of player names with missing overall ratings.
SELECT p.player_name, pa.overall_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
WHERE pa.overall_rating IS NULL;

--Demo D1 Query One
--Module 6: Working with data types examples
--Description: This query demonstrates working with data types by casting numeric and text fields using CAST and handling null values with ISNULL.
--The query selects distinct player names and their overall ratings, ordered in ascending order. If a rating is null, it displays 'N/A'.
SELECT DISTINCT 
	   CAST(p.player_name AS VARCHAR) AS player_name,
	   ISNULL(CAST(pa.overall_rating AS VARCHAR), 'N/A') + ' OVR' AS Overall_Rating
FROM player_attributes pa
JOIN player p ON pa.player_api_id = p.player_api_id
ORDER BY Overall_Rating ASC;

--Demo D1 Query Two
--Module 6: Working with data types examples
--Description: This query demonstrates working with data types as it selects all columns in the database, ordered by table_name 
--and displays the data type and max character length of each.
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME;

--Demo D2 Query One
--Module 6: Working with Character Data
--Original query I wanted to concatenate.
SELECT DISTINCT 
	CAST(p.player_name AS varchar(MAX)) AS player_name,
	MAX(pa.overall_rating) AS overall_rating
FROM player AS p
JOIN player_attributes AS pa
	ON p.player_api_id = pa.player_api_id
GROUP BY CAST(p.player_name AS varchar(MAX));

--Description: This query returns a list of unique players from the player table alongside their highest overall rating
--from the player_attributes table, formatted as a single string.
SELECT DISTINCT
	CONCAT(
		CAST(p.player_name AS varchar(MAX)),
		N' (overall_rating: ', 
		CAST(MAX(pa.overall_rating) AS NVARCHAR),
		N')'
	) AS playerWithRating
FROM player AS p
JOIN player_attributes AS pa
	ON p.player_api_id = pa.player_api_id
GROUP BY CAST(p.player_name AS varchar(MAX));

--Demo D2 Query Two
--Module 6: Working with Character Data
--Original Query I wanted to concatenate.
SELECT team_long_name, team_short_name
FROM team;

--Description: This query returns a list of team short and long names, formatted as a single string.
SELECT
	CONCAT(
		team_long_name,
		N' (short_name: ',
		team_short_name,
		N')'
	) AS teamShortAndLongNames
FROM team;

--Demo D3 Query One
--Module 6: Working with Date and Time Data
--Description: This query returns the difference between the first match date and the last match date stored in the match table.
SELECT DATEDIFF(
	DAY,
	(SELECT TOP 1 CAST(mdate AS varchar(MAX)) AS mdate FROM match ORDER BY mdate ASC),
	(SELECT TOP 1 CAST(mdate AS varchar(MAX)) AS mdate FROM match ORDER BY mdate DESC)
) AS daysBetween

--Demo D3 Query Two
--Module 6: Working with Date and Time Data
--Description: This query returns all player names and their birthdays from the player table along with their age. The query results are ordered by the oldest birthday.
--The age is calculated from the birthday datetime values by using the DATEDIFF function.
--The birthday column is converted from a text type and is first casted to a varchar, so that it can then be casted to a date type, since SQL server
--does not allow for text types to be converted straight to a date/datetime type.
SELECT player_name, 
	CAST(CAST(birthday AS varchar(MAX)) AS DATE) AS birthday,
	DATEDIFF(YEAR, CAST(CAST(birthday AS varchar(MAX)) AS DATE), '2025-04-16') as Age
FROM player
ORDER BY birthday;

--Demo D4 Query One
--Module 7: Adding data to tables using DML.
--Description: Add the country San Marino to the countries table with a designated ID.
INSERT INTO country (id, name)
VALUES('26518','San Marino');

DELETE FROM country WHERE CONVERT(VARCHAR, name) = 'San Marino';
--Using the * wildcard to return all rows and values from the country table.
SELECT * FROM country;

--Demo D4 Query Two
--Module 7: Adding data to tables using DML.
--Description: Adding the second tier leagues of each country into the league table.
INSERT INTO league(id, country_id, name)
VALUES
('101','1','Challanger Pro League'),
('102','1729','EFL Championship'),
('103','4769','Ligue 2'),
('104','7809','Bundesliga 2'),
('105','10257','Serie B'),
('106','13274','Eerste Divisie'),
('107','15722','Betclic l liga'),
('108','17642','Liga Portugal 2'),
('109','19694','Scottish Championship'),
('110','21518','La Liga 2'),
('111','24558','Swiss Challenge League');

SELECT * FROM league;

--Demo E1 Query One
--Module 7: Modifying and Removing Data
--The query which returns a result I want to update.
--It selects the best player based on highest overall_rating, returning the name, api id, overall_rating, with their dribbling and ball control statistics.
SELECT DISTINCT TOP 1 CAST(p.player_name AS nvarchar(MAX)) AS player_name, p.player_api_id, pa.overall_rating AS overall_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
GROUP BY CAST(p.player_name AS nvarchar(MAX)), p.player_api_id, pa.overall_rating
ORDER BY overall_rating DESC

--Description: This is the query I used to update the ball control statistic of the best player (Lionel Messi), based on highest overall_rating.
--It finds Messi and increases his ball_control stat by 3.
WITH TopPlayer AS (
    SELECT TOP 1 pa.player_api_id AS player_attribute_id
    FROM player AS p
    JOIN player_attributes AS pa ON p.player_api_id = pa.player_api_id
    ORDER BY pa.overall_rating DESC
)
UPDATE player_attributes
SET overall_rating = overall_rating + 2
WHERE id IN (SELECT player_attribute_id FROM TopPlayer);

--Demo E1 Query Two
--Module 7: Modifying and Removing Data
--The query which returns a result I want to update.
SELECT TOP 10 * FROM team
ORDER BY team_api_id

--Description: Deletes the team 'Ruch Chorz�w' from the team table.
DELETE FROM team WHERE CAST(team_long_name AS varchar(MAX)) = 'Ruch Chorz�w';

--Demo E2 Query One
--Module 7: Generating Automatic Column Values
--Description: Adds a new column to the player_attributes table. The values within the column are automatically generated by performing addition on the dribbling
--and ball control statistics of each player.
ALTER TABLE player_attributes
ADD skill_score AS (dribbling + ball_control);
--Query which selects the api ids, overall ratings, potential ratings and skill scores of each player from the player_attributes table. It is ordered by skill_score in descending order.
SELECT player_api_id, overall_rating, potential, ISNULL(skill_score, '0') AS skill_score FROM player_attributes
ORDER BY skill_score DESC;

--Demo E2 Query Two
--Module 7: Generating Automatic Column Values
--Description: Adds two new columns to the match table. One column calculates the home team goal difference whereas the other calculates the away team goal difference.
--The values are automatically generated by performing subtraction each way on the number of home team and away team goals scored within a match.
ALTER TABLE match
ADD home_team_goal_difference AS (home_team_goal - away_team_goal),
	away_team_goal_difference AS (away_team_goal - home_team_goal);
--Query which selects the home team and away team goals scored in each match with the calculated goal difference for each team in said match.
SELECT home_team_goal, away_team_goal, home_team_goal_difference, away_team_goal_difference
FROM match;

--Demo E3 Query One
--Module 8: Writing Queries with Built-In Functions
--Description: The query calculates the total number of matches each team has played, regardless of whether they are home or away.
--It uses the count built-in function.
WITH teams AS (
    SELECT DISTINCT t.team_api_id, CAST(t.team_long_name AS varchar(MAX)) AS team_long_name
    FROM team AS t
    JOIN match AS m
    ON t.team_api_id = m.home_team_api_id OR t.team_api_id = m.away_team_api_id
)
SELECT 
    t.team_long_name,
    COUNT(m.match_api_id) AS total_matches
FROM teams AS t
JOIN match AS m
	ON t.team_api_id = m.home_team_api_id OR t.team_api_id = m.away_team_api_id
GROUP BY t.team_long_name
ORDER BY total_matches DESC;

--Demo E3 Query Two
--Module 8: Writing Queries with Built-In Functions
--Description: This query selects the player with the highest average overall and potential ratings, using the built-in AVG function.
SELECT TOP 1 CAST(p.player_name AS nvarchar(MAX)) AS player_name, p.player_api_id, AVG(pa.overall_rating) AS average_overall_rating, AVG(pa.potential) AS average_potential_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
GROUP BY CAST(p.player_name AS nvarchar(MAX)), p.player_api_id
ORDER BY average_overall_rating DESC

--Demo E4 Query One
--Module 8: Using Conversion Functions
--Description: Counts the total matches played per year in the match table.
--The query extracts just the year part of the mdate and the count function is used to count all the number of matches for each year.
--The result is grouped and ordered by the myear.
SELECT YEAR(CAST(CAST(mdate AS varchar(MAX)) AS datetime)) AS myear, COUNT(*) AS total_matches
FROM match
GROUP BY YEAR(CAST(CAST(mdate AS varchar(MAX)) AS datetime))
ORDER BY myear;

--Demo E4 Query Two
--Module 8: Using Conversion Functions
--Description: This query selects distinct player names and their overall ratings by joining onto the player_attributes table.
--It uses a case statement to classify the players into rating tiers based on their overall ratings.
--The query uses a conversion function as it converts the data type of the player name from text to varchar, so that it can be selected as distinct.
SELECT DISTINCT CAST(p.player_name AS varchar(MAX)) AS player_name, pa.overall_rating,
	CASE
		WHEN pa.overall_rating >= 90 THEN 'Goats (OVR 90+'
		WHEN pa.overall_rating >= 85 THEN 'Professionals (OVR 85-89)'
		WHEN pa.overall_rating >= 75 THEN 'Rising Stars (OVR 75-84)'
		WHEN pa.overall_rating >= 65 THEN 'Average (OVR 65-74)'
		ELSE 'Flops (OVR UNDER 65)'
	END AS player_rating
FROM player AS p
JOIN player_attributes AS pa ON p.player_api_id = pa.player_api_id;

--Demo F1 Query One
--Module 8: Using Logical Functions
--Description: The query selects a list of matches from the match table displaying the ids of the home and away teams,
--the matchIds; creates a result row based on the final score using IIF() logic.
SELECT home_team_api_id, away_team_api_id, id AS match_id,
	IIF(home_team_goal > away_team_goal, 'Home Team Won',
		IIF(home_team_goal < away_team_goal, 'Away Team Won', 'Draw')
	) AS Result
FROM match;

--Demo F1 Query Two
--Module 8: Using Logical Functions
--Description: The query selects the player names from the player table and splits them into first and last names using string functions.
SELECT SUBSTRING(CAST(player_name AS varchar(MAX)), 1, CHARINDEX(' ', CAST(player_name AS varchar(MAX))) - 1) AS first_name,
	SUBSTRING(
		CAST(player_name AS varchar(MAX)),
		CHARINDEX(' ', CAST(player_name AS varchar(MAX))) + 1,
		LEN(CAST(player_name AS varchar(MAX))) - CHARINDEX(' ', CAST(player_name AS varchar(MAX)))
	) AS last_name
FROM player
WHERE CHARINDEX(' ', CAST(player_name AS varchar(MAX))) > 0;

--Demo F2 Query One
--Module 8: Using Functions to work with NULL.
--Description: The query selects distinct player names with a rating value.
--The rating value is assigned by using the COALESCE function. It works with nulls by checking if overall_rating or if both overall_rating and potential are null.
--If overall_rating is NULL, it falls back to the potential rating, and if both are NULL, it defaults to 0.
--The results are ordered by the rating.
SELECT DISTINCT 
	CAST(p.player_name AS varchar(MAX)) AS player_name, 
	COALESCE(pa.overall_rating, pa.potential, 0) AS rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
ORDER BY rating;

--Demo F2 Query Two
--Module 8: Using Functions to work with NULL.
--Description: The query selects distinct player names and their overall ratings by joining the player table with the player_attributes table, based on api id.
--The query also labels each player based on whether they have an assigned rating or whether it is null.
--To do this, it makes use of a case statement inside the select statement which creates an 'isRating' column.
--It checks if the overall rating of a player is null and assigns an 'unrated' label to be outputted. Else, a 'rated' label is outputted.
--The result query is ordered by overall rating.
SELECT DISTINCT 
	CAST(p.player_name AS varchar(MAX)) AS player_name,
	pa.overall_rating,
	CASE
		WHEN overall_rating IS NULL THEN 'Unrated'
		ELSE 'Rated'
	END AS isRating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
ORDER BY overall_rating;