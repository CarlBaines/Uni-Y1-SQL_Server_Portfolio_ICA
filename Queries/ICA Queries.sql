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
WHERE TABLE_NAME = 'match';

--Demo A1 Query One
--Module 3: Writing SELECT queries with single table.
--User Story: Select all data from every column and row from the EuroLeagues.league table.
SELECT * FROM league;

--Demo A1 Query Two
--Module 3: Writing SELECT queries with single table.
--User Story: Select the total number of goals scored from the EuroLeagues.match table.
--Explanation: Simple SELECT query that creates a calculated column, calling the sum function on the home_team_goal and away_team_goal columns.
SELECT SUM(home_team_goal + away_team_goal)
FROM match;

--Demo A2 Query One
--Module 3: Eliminating Duplicates with DISTINCT
--User Story: Eliminate duplicate seasons from the EuroLeagues.match table and order them from earliest to latest.
--Explanation: This query uses a subquery and casts the season as a varchar type (it was initially stored as a text value), so that it can work directly with functions like LEFT().
--It extracts the starting years of the seasons (the first four characters), casts them to an int and orders them.
SELECT season
FROM(
	SELECT DISTINCT CAST(season AS VARCHAR(MAX)) AS season
	FROM match
) AS season
ORDER BY CAST(LEFT(season, 4) AS INT);

--Demo A2 Query Two
--Module 3: Eliminating Duplicates with DISTINCT
--User Story: Select unique player names from the EuroLeagues.player table and stores them in a column called 'AllPlayerNames'.
SELECT DISTINCT CAST(player_name AS VARCHAR(MAX)) AS AllPlayerNames
FROM player;

--Demo A3 Query One
--Module 3: Using Column and Table Aliases Lesson
--User Story: Select the total number of goals scored from the EuroLeagues.match table and assign the column the 'TotalGoalsScored' alias.
SELECT SUM(home_team_goal + away_team_goal) AS TotalGoalsScored
FROM match;

--Demo A3 Query Two
--Module 3: Using Column and Table Aliases Lesson
--User Story: Select all columns from the EuroLeagues.team table using the alias 'MiddlesbroughFCInfo', where the team_long_name is Middlesbrough.
SELECT id, team_api_id, team_fifa_api_id, team_long_name, team_short_name
FROM team AS MiddlesbroughFCInfo
WHERE CAST(team_long_name AS VARCHAR(MAX)) = 'Middlesbrough';

--Demo A4 Query One
--Module 4: Writing Simple CASE expressions
--User Story: Categorise countries by league tier.
--The name of the countries is casted as a varchar so that it can work directly with functions.
SELECT CAST(name AS VARCHAR(MAX)) AS country_names,
	CASE
		WHEN CAST(name AS VARCHAR(MAX)) IN ('England', 'Spain', 'France', 'Germany', 'Italy') THEN 'Top 5 League'
		ELSE 'Not in Top 5'
	END AS League_Tier
FROM country;

--Demo A4 Query Two
--Module 4: Writing Simple CASE expressions
--User Story: Determine the result of a match using the match table.
SELECT id AS match_id,
	CASE
		WHEN home_team_goal > away_team_goal THEN 'Home Team Won'
		WHEN home_team_goal < away_team_goal THEN 'Away Team Won'
		ELSE 'Draw'
	END AS Result
FROM match;

--Demo B1 Query One
--Module 1: How to provide data from 2 related tables with a Join.
--User Story: Select the league names associated with each country.
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
--User Story: Select all the different ratings of the best player (the best player has the highest overall and potential ratings)
--Lionel Messi.
SELECT p.player_api_id, CAST(p.player_name AS varchar(MAX)) AS player_name, pa.overall_rating, pa.potential AS potential_rating
FROM player AS p
JOIN player_attributes AS pa
ON p.player_api_id = pa.player_api_id
WHERE pa.overall_rating = (SELECT MAX(pa.overall_rating) FROM player_attributes AS pa)
ORDER BY p.player_api_id

--Demo B2 Query Two
--Module 4: How to query with inner joins
--User Story: Join the match table with the team table to get the home and away team names.
SELECT DISTINCT team_api_id, CAST(team_long_name AS varchar(MAX)) AS team_long_name
FROM team
JOIN match
ON home_team_api_id = team_api_id OR away_team_api_id = team_api_id
ORDER BY team_api_id;

--Demo B3 Query One
--Module 4: How to query with outer joins
--User Story: left join between team and team_attributes to retrieve a distinct list of all teams, including those with or without associated attribute data.
SELECT DISTINCT t.team_fifa_api_id, CAST(t.team_long_name AS varchar(MAX)) AS team_long_name, CAST(t.team_short_name AS varchar(MAX)) AS team_short_name
FROM team AS t
LEFT JOIN team_attributes AS ta
ON t.team_fifa_api_id = ta.team_fifa_api_id;

--Demo B3 Query Two
--Module 4: How to query with outer joins
--User Story: left join between match and team to retrieve a distinct list of all matches, ensuring that match data is included even if team details are duplicated or missing due to the join condition.
SELECT DISTINCT CAST(m.mdate AS varchar(MAX)) AS match_date, m.match_api_id, m.home_team_api_id, m.away_team_api_id, m.home_team_goal, m.away_team_goal
FROM match AS m
LEFT JOIN team AS t
ON m.home_team_api_id = t.team_api_id OR m.away_team_api_id = t.team_api_id;

--Demo B4 Query One
--Module 4: How to query with cross and self joins





--Unrelated Queries - I like them so will add to portfolio at some point.
--User Story: Select id and player names from the EuroLeagues.player table, ordering the id in ascending order.
--Simple SELECT query with ORDER by clause.
SELECT id, player_name
FROM player
ORDER BY id ASC;



