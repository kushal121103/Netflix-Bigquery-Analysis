# Netflix-Bigquery-Analysis

![Netflix Logo - Netflix Data Analysis](https://upload.wikimedia.org/wikipedia/commons/0/08/Netflix_2015_logo.svg)



This project analyzes the Netflix dataset using Google BigQuery and SQL. It covers content trends by type, genre, country, and actors, offering real-world business insights.The goal is to explore and analyze Netflix's Movies and TV Shows dataset using SQL in BigQuery, uncovering content trends, audience preferences, and platform insights to support data-driven decisions.

##  **Objective**:

Compare Movies and TV Shows – Find out how much of Netflix’s content is movies vs. TV shows.

Identify Most Common Ratings – Discover which ratings are most frequently given to movies and TV shows.

Top Countries Producing Content – Determine which countries contribute the most to Netflix’s library.

Find the Longest Movie – Identify the movie with the highest duration available on Netflix.

Analyze Recently Added Content – Retrieve and study content added to Netflix in the last 5 years.

##  **BigQuery Table Schema**

| Column Name | Data Type | Mode | Description                  |
| --------------- | ------------- | -------- | -------------------------------- |
| `show_id`       | STRING        | NULLABLE | Unique ID for each show          |
| `type`          | STRING        | NULLABLE | Either "Movie" or "TV Show"      |
| `title`         | STRING        | NULLABLE | Name of the show                 |
| `director`      | STRING        | NULLABLE | Director of the show/movie       |
| `cast`          | STRING        | NULLABLE | List of main actors              |
| `country`       | STRING        | NULLABLE | Country of origin                |
| `date_added`    | STRING        | NULLABLE | Date when added to Netflix       |
| `release_year`  | INTEGER       | NULLABLE | Year when it was released        |
| `rating`        | STRING        | NULLABLE | Content rating (e.g., PG, TV-MA) |
| `duration`      | STRING        | NULLABLE | Length of the show or episodes   |
| `listed_in`     | STRING        | NULLABLE | Genre/categories                 |
| `description`   | STRING        | NULLABLE | Summary of the content           |

##  **Business Problems and Solutions**
##  **1. Count the Number of Movies vs TV Shows**
```sql
SELECT type,COUNT(type) AS TOTAL_CONTENT 
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
GROUP BY type
```
Objective: Determine the distribution of content types on Netflix.

##  **2. Find the Most Common Rating for Movies and TV Shows**
```sql
SELECT type,rating FROM (
  SELECT type,rating,COUNT(*) AS counting,RANK()OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title` 
  GROUP BY type,rating
)
WHERE ranking=1
```
Objective: Identify the most frequently occurring rating for each type of content.

##  **3. List All Movies Released in a Specific Year (e.g., 2020)**
```sql
SELECT * FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE type='movie'AND release_year=2020
```
Objective: Retrieve all movies released in a specific year.

##  **4. Find the Top 5 Countries with the Most Content on Netflix**
```sql
SELECT TRIM(country_part) AS country,COUNT(*) AS total_content 
FROM( 
  SELECT show_id,SPLIT(country,',') AS countries 
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`),
  UNNEST(countries) AS country_part
  GROUP BY country
  ORDER BY total_content DESC
  LIMIT 5
```
Objective: Identify the top 5 countries with the highest number of content items.

##  **5. Identify the Longest Movie**
```sql
SELECT type
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
  WHERE type='movie'
  ORDER BY SAFE_CAST(SPLIT(duration,'')[OFFSET(0)] AS INT64) DESC
```
Objective: Find the movie with the longest duration.

##  **6. Find Content Added in the Last 5 Years**
```sql
SELECT * 
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
  WHERE SAFE.PARSE_DATE('%B %e,%Y',TRIM(date_added))>=DATE_SUB(current_date(),interval 5 year)
```
Objective: Retrieve content added to Netflix in the last 5 years.

##  **7. Find All Movies/TV Shows by Director 'joe Camp'**
```sql
SELECT * 
 FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
 WHERE director LIKE '%Joe Camp%'
```
Objective: List all content directed by 'jeo camp'.

##  **8. List All TV Shows with More Than 5 Seasons**
```sql
SELECT *
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE type='TV Show' AND SAFE_CAST(SPLIT(duration,'')[OFFSET(0)] AS INT64 )>5
```
Objective: Identify TV shows with more than 5 seasons.

##  **9. Count the Number of Content Items in Each Genre**
```sql
SELECT genre ,COUNT(*) AS total_count 
 FROM(
  SELECT TRIM(Genre) AS genre
 FROM `netflix-analysis-466609.metflix_dataset.netflix_title`,
 UNNEST(SPLIT(listed_in,',')) AS genre
 )
 GROUP BY genre
 ORDER BY total_count DESC
```
Objective: Count the number of content items in each genre.

##  **10. Find Each Year and the Average Number of Content Releases in India on Netflix**
```sql
 SELECT 
  release_year,
  COUNT(show_id) AS total_release,
  ROUND(
    COUNT(show_id) / (
      SELECT COUNT(*) FROM `netflix-analysis-466609.metflix_dataset.netflix_title` WHERE country = 'India'
    ) * 100, 2
  ) AS avg_release
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE country = 'India'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;
```
Objective: Calculate and rank years by the average number of content releases in India.

##  **11. List All Movies that are Documentaries**
```sql
SELECT * 
 FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
 WHERE listed_in LIKE '%Documentaries%'
```
Objective: Retrieve all movies classified as documentaries.

##  **12. Find All Content Without a Director**
```sql
SELECT *
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE director IS NULL OR director=''
```
Objective: List content that does not have a director.

##  **13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years**
```sql
SELECT title
FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
WHERE LOWER(`cast`) LIKE '%salman khan%'
  AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE()) - 10;
```
Objective: Count the number of movies featuring 'Salman Khan' in the last 10 years.

##  **14. Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India**
```sql
SELECT 
  TRIM(actor) AS actor,
  COUNT(*) AS appearances
FROM (
  SELECT 
    SPLIT(`cast`, ',') AS actor_list
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
  WHERE country LIKE '%India%'  
    AND `cast` IS NOT NULL       
), UNNEST(actor_list) AS actor
WHERE TRIM(actor) != ''         
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;
```
Objective: Identify the top 10 actors with the most appearances in Indian-produced movies.

##  **15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords**
```sql
SELECT category, COUNT(*) AS content_count
FROM (
  SELECT 
    CASE 
      WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
      ELSE 'Good'
    END AS category
  FROM `netflix-analysis-466609.metflix_dataset.netflix_title`
)
GROUP BY category;
```
Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

##  **Conclusion**
The analysis provided valuable insights into the distribution of content types, popular ratings, and content trends across different years and countries.

Key patterns were identified, such as the most active countries in content production, popular genres, and the frequency of new additions to the Netflix platform.

These findings can support data-driven decisions for content planning, marketing strategies, and improving user engagement based on audience preferences.
