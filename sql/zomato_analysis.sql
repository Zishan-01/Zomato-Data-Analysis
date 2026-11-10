-- =========================================================
-- Zomato Restaurant Data Analysis — Business SQL Queries
-- =========================================================
-- Dataset: Zomato Bangalore Restaurants (cleaned)
-- Table  : restaurants
-- Rows   : 9,937
-- =========================================================

-- Q1: Total number of restaurants
SELECT COUNT(*) AS total_restaurants FROM restaurants;

-- Q2: Overall rating statistics
SELECT ROUND(AVG(rate), 2) AS avg_rating,
       ROUND(MIN(rate), 2) AS min_rating,
       ROUND(MAX(rate), 2) AS max_rating
FROM restaurants;

-- Q3: Top 10 locations by restaurant count
SELECT location, COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY location
ORDER BY restaurant_count DESC
LIMIT 10;

-- Q4: Top 10 cuisines
SELECT cuisines, COUNT(*) AS count
FROM restaurants
GROUP BY cuisines
ORDER BY count DESC
LIMIT 10;

-- Q5: Highest-rated locations (min 50 restaurants)
SELECT location,
       COUNT(*) AS restaurant_count,
       ROUND(AVG(rate), 2) AS avg_rating
FROM restaurants
GROUP BY location
HAVING COUNT(*) >= 50
ORDER BY avg_rating DESC
LIMIT 10;

-- Q6: Online ordering vs ratings
SELECT online_order,
       COUNT(*) AS count,
       ROUND(AVG(rate), 2) AS avg_rating,
       ROUND(AVG(votes), 0) AS avg_votes
FROM restaurants
GROUP BY online_order;

-- Q7: Table booking vs rating & cost
SELECT book_table,
       COUNT(*) AS count,
       ROUND(AVG(rate), 2) AS avg_rating,
       ROUND(AVG(cost_for_two), 0) AS avg_cost
FROM restaurants
GROUP BY book_table
ORDER BY avg_rating DESC;

-- Q8: Price bands vs rating
SELECT 
    CASE 
        WHEN cost_for_two < 300  THEN 'Budget (<300)'
        WHEN cost_for_two < 700  THEN 'Mid (300-700)'
        WHEN cost_for_two < 1500 THEN 'Premium (700-1500)'
        ELSE 'Luxury (1500+)'
    END AS price_band,
    COUNT(*) AS count,
    ROUND(AVG(rate), 2) AS avg_rating,
    ROUND(AVG(votes), 0) AS avg_votes
FROM restaurants
GROUP BY price_band
ORDER BY avg_rating DESC;

-- Q9: Top 10 highest-rated restaurants (min 500 votes)
SELECT name, location, cuisines, rate, votes, cost_for_two
FROM restaurants
WHERE votes >= 500
ORDER BY rate DESC, votes DESC
LIMIT 10;

-- Q10: Hidden gems (high rating, low visibility)
SELECT name, location, cuisines, rate, votes
FROM restaurants
WHERE rate >= 4.5 AND votes BETWEEN 50 AND 200
ORDER BY rate DESC
LIMIT 10;

-- Q11: Restaurant types by top location
SELECT location, rest_type, COUNT(*) AS count
FROM restaurants
WHERE location IN ('BTM', 'Koramangala 5th Block', 'Indiranagar', 'HSR')
GROUP BY location, rest_type
HAVING COUNT(*) >= 10
ORDER BY location, count DESC;

-- Q12: Most expensive locations
SELECT location,
       COUNT(*) AS count,
       ROUND(AVG(cost_for_two), 0) AS avg_cost
FROM restaurants
GROUP BY location
HAVING COUNT(*) >= 50
ORDER BY avg_cost DESC
LIMIT 10;

-- Q13: Best-rated cuisines
SELECT cuisines,
       COUNT(*) AS count,
       ROUND(AVG(rate), 2) AS avg_rating
FROM restaurants
GROUP BY cuisines
HAVING COUNT(*) >= 50
ORDER BY avg_rating DESC
LIMIT 10;

-- Q14: Rating tier distribution
SELECT 
    CASE 
        WHEN rate >= 4.5 THEN 'Excellent (4.5+)'
        WHEN rate >= 4.0 THEN 'Good (4.0-4.5)'
        WHEN rate >= 3.5 THEN 'Average (3.5-4.0)'
        WHEN rate >= 3.0 THEN 'Below Average (3.0-3.5)'
        ELSE 'Poor (<3.0)'
    END AS rating_tier,
    COUNT(*) AS count
FROM restaurants
GROUP BY rating_tier
ORDER BY MIN(rate) DESC;

-- Q15: Full-service digitized segment
SELECT COUNT(*) AS count,
       ROUND(AVG(rate), 2) AS avg_rating,
       ROUND(AVG(cost_for_two), 0) AS avg_cost
FROM restaurants
WHERE online_order = 'Yes' AND book_table = 'Yes';

-- Q16a: Budget-heavy locations
SELECT location, COUNT(*) AS count,
       ROUND(AVG(cost_for_two), 0) AS avg_cost
FROM restaurants
WHERE cost_for_two < 400
GROUP BY location
ORDER BY count DESC
LIMIT 5;

-- Q16b: Premium-heavy locations
SELECT location, COUNT(*) AS count,
       ROUND(AVG(cost_for_two), 0) AS avg_cost
FROM restaurants
WHERE cost_for_two > 1200
GROUP BY location
ORDER BY count DESC
LIMIT 5;

-- Q17: Most-voted restaurants (engagement leaders)
SELECT name, location, rate, votes, cuisines
FROM restaurants
ORDER BY votes DESC
LIMIT 10;

-- Q18: Top 3 restaurants per location (window function)
SELECT *
FROM (
    SELECT name, location, rate, votes,
           RANK() OVER (PARTITION BY location 
                        ORDER BY rate DESC, votes DESC) AS rank_in_location
    FROM restaurants
) ranked
WHERE rank_in_location <= 3
  AND location IN ('BTM', 'Koramangala 5th Block', 'Indiranagar', 'HSR')
ORDER BY location, rank_in_location;
