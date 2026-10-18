/*

AIRBNB DATA ANALYSIS 

Purpose:
Analyze the cleaned Airbnb dataset and answer exploratory question using SQL.

Source table: airbnb_clean

*/

-- 1. Preview Cleaned data

SELECT *
FROM airbnb_clean
LIMIT 30;
-- 2. Total number of cleaned listings

SELECT
    COUNT(*) AS total_listings
FROM airbnb_clean;