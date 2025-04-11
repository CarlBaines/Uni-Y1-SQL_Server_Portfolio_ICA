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
FROM(
	SELECT DISTINCT CAST(season AS VARCHAR(MAX)) AS season
	FROM match
) AS season
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
		WHEN CAST(name AS VARCHAR(MAX)) IN ('England', 'Spain', 'France', 'Germany', 'Italy') THEN 'Top 5 League'
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


