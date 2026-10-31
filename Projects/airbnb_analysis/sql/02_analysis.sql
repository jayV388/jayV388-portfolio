/*

AIRBNB DATA ANALYSIS 

Purpose:
Analyze the cleaned Airbnb dataset and answer business questions using SQL.

Source table: airbnb_clean

*/

-- Preview Cleaned data
SELECT *
FROM airbnb_clean
LIMIT 30;

-- Total number of cleaned listings
SELECT
    COUNT(*) AS total_listings
FROM airbnb_clean;

/*
Q1. Host Portfolio Size Analysis

What is the distribution of Airbnb supply among stated host portfolio sizes, 
and what are the the differences in average price and review ratings between those groups?

*/

SELECT
    CASE
        WHEN calculated_host_listings_count = 1 THEN '1 listing'
        WHEN calculated_host_listings_count BETWEEN 2 AND 5 THEN '2-5 listings'
        WHEN calculated_host_listings_count BETWEEN 6 AND 20 THEN '6-20 listings'
        WHEN calculated_host_listings_count > 20 THEN '21+ listings'
    END AS portfolio_size,

    COUNT(*) AS listings,
    ROUND(
        100.0 * COUNT(*) /
        (
            SELECT COUNT(*)
            FROM airbnb_clean
            WHERE calculated_host_listings_count IS NOT NULL
        ),
        1
    ) AS pct_of_listings,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(review_rate_number), 1) AS avg_rating

FROM airbnb_clean
WHERE calculated_host_listings_count IS NOT NULL
GROUP BY portfolio_size
ORDER BY MIN(calculated_host_listings_count);

/*
Findings: While average rates are about the same across the same portfolio sizes ($621-$627), the supply of Airbnb
is concentrated among smaller hosts, with 1 listing (57.5%) and 2-5 listings (30.3%) making up 88% of the total.
*/


/*
Q2. Price by Borough and Room Type

Which boroughs and room types combinations have the highest average price, and which have the lowest?
*/

SELECT
    neighbourhood_group,
    room_type,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) AS listings
FROM airbnb_clean
WHERE neighbourhood_group IS NOT NULL 
    AND price IS NOT NULL
    AND room_type IS NOT NULL
GROUP BY neighbourhood_group, 
    room_type
HAVING COUNT(*) >= 50
ORDER BY avg_price DESC;

/*
Findings: Once groups with fewer than 50 listings are removed, average prices fall in a
narrow range ($620 - $645) across all boroughs and room types. Manhattem
*/


/*
Q3. Guest Activity by Neighborhood

Which neighborhoods have the highest average reviews per month among neighborhoods with atleast 50 listings?
*/

SELECT
    neighbourhood_group,
    neighbourhood,
    COUNT(*) AS listings,
    ROUND(AVG(reviews_per_month), 2) AS avg_review_per_month
FROM airbnb_clean
WHERE neighbourhood IS NOT NULL
    AND neighbourhood_group IS NOT NULL
    AND reviews_per_month IS NOT NULL
GROUP BY neighbourhood_group,
    neighbourhood
HAVING COUNT(*) >= 50
ORDER BY avg_review_per_month DESC
LIMIT 10;

/*
Findings: East Elmhurst in Queens had the highest average review activity at 4.06 reviews per month across 483
litings, and Queens neighborhoods dominated most of the top positions.
*/


/*
Q4. Stay length in high-demand neighbourhood

Do the highest-demand neighbourhoods (top 10 by reviews per month) allow shorter minimum stays than all other neighbourhoods?
*/

WITH top_demand AS (
SELECT
    neighbourhood_g roup,
    neighbourhood,
    COUNT(*) AS listings,
    ROUND(AVG(reviews_per_month), 2) AS avg_review_per_month
FROM airbnb_clean
WHERE neighbourhood IS NOT NULL
    AND neighbourhood_group IS NOT NULL
    AND reviews_per_month IS NOT NULL
GROUP BY neighbourhood_group,
    neighbourhood
HAVING COUNT(*) >= 50
ORDER BY avg_review_per_month DESC
LIMIT 10
)
SELECT
    CASE
    
        WHEN neighbourhood IN (SELECT neighbourhood FROM top_demand)
            THEN 'Top 10 demand'
        ELSE 'All other'
    END AS demand_group,
    COUNT(*) AS listings,
    ROUND(AVG(minimum_nights), 2) AS avg_min_nights,
    ROUND(100.0 * AVG(CASE WHEN minimum_nights <= 2 THEN 1.0 ELSE 0 END), 1) AS pct_short_stay
FROM airbnb_clean
WHERE minimum_nights IS NOT NULL
    AND neighbourhood IS NOT NULL
    AND neighbourhood_group IS NOT NULL
GROUP BY demand_group;