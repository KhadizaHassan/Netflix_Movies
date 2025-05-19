select * from khadizadb.imdbshows;

		--  1. Get Top-Rated Movies or Shows?
SELECT title, type, release_year, imdb_score, imdb_votes
FROM khadizadb.imdbshows
WHERE type = 'Movie'
ORDER BY imdb_score DESC
LIMIT 10;
------------------------------------------------------------
------------------------------------------------------------
		-- 2. Find Movies Released in a Specific Decade?
SELECT title, release_year, genres
FROM khadizadb.imdbshows
WHERE release_year BETWEEN 1970 AND 1980;
-------------------------------------------------
-------------------------------------------------
		-- 3. Count the Number of Movies and Shows Per Production Country? 
SELECT production_countries, COUNT(*) AS total_count
FROM khadizadb.imdbshows
GROUP BY production_countries
ORDER BY total_count DESC;
------------------------------------------------
------------------------------------------------
		-- 4. Get the Average IMDb Score Per Genre?
SELECT genres, AVG(imdb_score) AS avg_score
FROM khadizadb.imdbshows
GROUP BY genres
ORDER BY avg_score DESC;
-------------------------------------------------
-------------------------------------------------
		-- 5. What are the highest-rated movies from the 1980s?
SELECT title, release_year, imdb_score
FROM khadizadb.imdbshows
WHERE type = 'Movie' AND release_year BETWEEN 1980 AND 1989
ORDER BY imdb_score DESC
LIMIT 10;
---------------------------------------------------------
---------------------------------------------------------
		-- 6. Which country has the most entries in the dataset?  
SELECT production_countries, COUNT(*) AS total_entries
FROM khadizadb.imdbshows
GROUP BY production_countries
ORDER BY total_entries DESC
LIMIT 10;
---------------------------------------------------------
---------------------------------------------------------
		-- 7. What is the most common age certification among TV shows?
SELECT age_certification, COUNT(*) AS total_count
FROM khadizadb.imdbshows
WHERE type = 'TV Show'
GROUP BY age_certification
ORDER BY total_count DESC
LIMIT 5;

		-- By Movie Shows? 
SELECT age_certification, COUNT(*) AS total_count
FROM khadizadb.imdbshows
WHERE type = 'Movie'
GROUP BY age_certification
ORDER BY total_count DESC
LIMIT 5;

		-- By Age? 
SELECT age_certification, COUNT(*) AS total_count
FROM khadizadb.imdbshows
GROUP BY age_certification
ORDER BY total_count DESC
LIMIT 5;
-------------------------------------------------------
-------------------------------------------------------
		-- 8. How many unique genres are represented, 
        -- and which genre is the most common? (window Functions)
     
				-- Total Genres 
SELECT COUNT(DISTINCT genres) AS total_unique_genres
FROM khadizadb.imdbshows;

				-- Total Genres including names 
WITH GenreCounts AS (
    SELECT genres, COUNT(*) AS genre_count,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS mostcommon
    FROM khadizadb.imdbshows
    GROUP BY genres
)
SELECT DISTINCT COUNT(genres) OVER () AS unique_genres, 
       genres AS most_common_genre
FROM GenreCounts;
---------------------------------------------------------------
---------------------------------------------------------------
		-- 9. What is the distribution of movies vs. shows in the dataset?
SELECT type, COUNT(*) AS total_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM khadizadb.imdbshows
GROUP BY type
ORDER BY total_count DESC;
-------------------------------------------------------------------------
-------------------------------------------------------------------------
		-- 10. Duration by Genre over the countery?
SELECT production_countries, genres,
       SUM(runtime) AS total_runtime,
       RANK() OVER (PARTITION BY production_countries ORDER BY SUM(runtime) DESC) AS genre_rank
FROM khadizadb.imdbshows
GROUP BY production_countries, genres
ORDER BY production_countries, genre_rank;
----------------------------------------------------------------------------
------------------------------------------------------------------------------
		-- 11. Duration by genre over the release year
SELECT release_year, genres,
       SUM(runtime) AS total_runtime,
       RANK() OVER (PARTITION BY release_year ORDER BY SUM(runtime) DESC) AS genre_rank
FROM khadizadb.imdbshows
GROUP BY release_year, genres
ORDER BY release_year, genre_rank;
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
			-- 12. Average IMDb score and votes for each genre? 
SELECT genres, 
       AVG(imdb_score) AS avg_imdb_score, 
       SUM(imdb_votes) AS avg_votes
FROM khadizadb.imdbshows
GROUP BY genres
ORDER BY avg_imdb_score DESC limit 10;
		-- Average IMDb score and votes for each country? 
SELECT production_countries, 
       AVG(imdb_score) AS avg_score, 
       AVG(imdb_votes) AS avg_votes
FROM khadizadb.imdbshows
GROUP BY production_countries
ORDER BY avg_score DESC;
		--  Average IMDb score and votes on age?
SELECT age_certification AS Rating, 
       AVG(imdb_score) AS avg_imdb_score, 
       SUM(imdb_votes) AS avg_votes
FROM khadizadb.imdbshows
GROUP BY age_certification
ORDER BY avg_imdb_score DESC;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
		-- 13. Genre duration over the year?
SELECT release_year, genres,
       SUM(runtime) AS total_runtime,
       RANK() OVER (PARTITION BY release_year ORDER BY SUM(runtime) DESC) AS genre_rank
FROM khadizadb.imdbshows
GROUP BY release_year, genres
ORDER BY release_year, genre_rank;
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
		-- 14. Genre score over the years? 
SELECT release_year, genres, 
       AVG(imdb_score) AS avg_imdb_score
FROM khadizadb.imdbshows
GROUP BY release_year, genres
ORDER BY release_year, avg_imdb_score asc;
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
		-- 15. How does the number of IMDb votes influence IMDb scores?? 
SELECT 
    (sum(imdb_votes * imdb_score) - COUNT(*) * AVG(imdb_votes) * AVG(imdb_score)) /
    (SQRT((SUM(imdb_votes * imdb_votes) - COUNT(*) * AVG(imdb_votes) * AVG(imdb_votes)) * 
          (SUM(imdb_score * imdb_score) - COUNT(*) * AVG(imdb_score) * AVG(imdb_score))))
    AS Relation FROM khadizadb.imdbshows;
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
-- 16. Do movies with higher IMDb votes tend to have higher scores?
SELECT 
    CASE 
        WHEN imdb_votes < 1000 THEN 'Low Votes (<1K)'
        WHEN imdb_votes BETWEEN 1000 AND 10000 THEN 'Medium Votes (1K-10K)'
        WHEN imdb_votes BETWEEN 10000 AND 100000 THEN 'High Votes (10K-100K)'
        ELSE 'Very High Votes (>100K)'
    END AS vote_category,
    AVG(imdb_score) AS avg_imdb_score
FROM khadizadb.imdbshows
GROUP BY vote_category
ORDER BY avg_imdb_score DESC;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
		-- 17. Which show has the highest number of seasons?
SELECT type, title, seasons
FROM khadizadb.imdbshows
ORDER BY seasons DESC
LIMIT 5;
 ------------------------------------------------------------------------
 -------------------------------------------------------------------------
		-- 18. Do shows with more seasons tend to have higher IMDb scores? 
SELECT 
    CASE 
        WHEN seasons = 1 THEN 'Single Season'
        WHEN seasons BETWEEN 2 AND 5 THEN 'Few Seasons (2-5)'
        WHEN seasons BETWEEN 6 AND 10 THEN 'Moderate Seasons (6-10)'
        ELSE 'Many Seasons (>10)'
    END AS season_category,
    AVG(imdb_score) AS avg_imdb_score
FROM khadizadb.imdbshows
GROUP BY season_category
ORDER BY avg_imdb_score DESC;
------------------------------------------------------------------
-----------------------------------------------------------------
		-- 19. Are shows with more seasons generally older or newer?
 SELECT 
    CASE 
        WHEN seasons = 1 THEN 'Single Season'
        WHEN seasons BETWEEN 2 AND 5 THEN 'Few Seasons (2-5)'
        WHEN seasons BETWEEN 6 AND 10 THEN 'Moderate Seasons (6-10)'
        ELSE 'Many Seasons (>10)'
    END AS season_category,
    AVG(release_year) AS avg_release_year
FROM khadizadb.imdbshows
GROUP BY season_category
ORDER BY release_year ASC;
   -------------------------------------------------------------------------
   --------------------------------------------------------------------------

		-- 20. What are the top-rated shows with only 1 season?
SELECT title, imdb_score, imdb_votes
FROM khadizadb.imdbshows
WHERE seasons = 1
ORDER BY genres DESC
LIMIT 10;
----------------------------------------------------------------------
------------------------------------------------------------------------
-- 21. which genre has more Rating?
SELECT age_certification AS rating, COUNT(*) AS rating_count
FROM khadizadb.imdbshows
GROUP BY age_certification
ORDER BY rating_count DESC;
 -------------------------------------------------------------------
 -------------------------------------------------------------------








