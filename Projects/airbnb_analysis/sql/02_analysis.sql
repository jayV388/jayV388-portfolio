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