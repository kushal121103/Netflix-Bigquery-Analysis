-- View sample data
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title` 
LIMIT 1000;

-- 1. Count the Number of Movies vs TV Shows
SELECT 
  type, 
  COUNT(type) AS TOTAL_CONTENT 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
GROUP BY type;

-- 2. Most Common Rating for Movies and TV Shows
SELECT 
  type, 
  rating 
FROM (
  SELECT 
    type,
    rating,
    COUNT(*) AS counting,
    RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title` 
  GROUP BY type, rating
)
WHERE ranking = 1;

-- 3. List All Movies Released in 2020
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE 
  LOWER(type) = 'movie' 
  AND release_year = 2020;

-- 4. Top 5 Countries with Most Content
SELECT 
  TRIM(country_part) AS country,
  COUNT(*) AS total_content 
FROM (
  SELECT 
    show_id, 
    SPLIT(country, ',') AS countries 
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
), UNNEST(countries) AS country_part
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the Longest Movie
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE 
  LOWER(type) = 'movie'
ORDER BY SAFE_CAST(SPLIT(duration, ' ')[OFFSET(0)] AS INT64) DESC
LIMIT 1;

-- 6. Content Added in Last 5 Years
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE SAFE.PARSE_DATE('%B %e, %Y', TRIM(date_added)) >= DATE_SUB(CURRENT_DATE(), INTERVAL 5 YEAR);

-- 7. Content by Director Joe Camp
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE director LIKE '%Joe Camp%';

-- 8. TV Shows with More Than 5 Seasons
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE 
  LOWER(type) = 'tv show' 
  AND SAFE_CAST(SPLIT(duration, ' ')[OFFSET(0)] AS INT64) > 5;

-- 9. Number of Items in Each Genre
SELECT 
  genre,
  COUNT(*) AS total_count 
FROM (
  SELECT 
    TRIM(genre) AS genre
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`,
       UNNEST(SPLIT(listed_in, ',')) AS genre
)
GROUP BY genre
ORDER BY total_count DESC;

-- 10. Avg % of Indian Content per Year
SELECT 
  release_year,
  COUNT(show_id) AS total_release,
  ROUND(
    COUNT(show_id) / (
      SELECT COUNT(*) 
      FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
      WHERE country = 'India'
    ) * 100, 2
  ) AS avg_release
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. All Documentaries
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE listed_in LIKE '%Documentaries%';

-- 12. Content Without a Director
SELECT * 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE director IS NULL OR director = '';

-- 13. Salman Khan Movies in the Last 10 Years
SELECT title 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE 
  LOWER(`cast`) LIKE '%salman khan%' 
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE()) - 10;

-- 14. Top 10 Actors in Indian Movies
SELECT 
  TRIM(actor) AS actor,
  COUNT(*) AS appearances
FROM (
  SELECT SPLIT(`cast`, ',') AS actor_list
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
  WHERE country LIKE '%India%'
    AND `cast` IS NOT NULL
), UNNEST(actor_list) AS actor
WHERE TRIM(actor) != ''
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

-- 15. Categorize Content Based on Keywords
SELECT 
  category,
  COUNT(*) AS content_count
FROM (
  SELECT 
    CASE 
      WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
      ELSE 'Good'
    END AS category
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
)
GROUP BY category;
