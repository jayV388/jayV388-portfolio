/*

AIRBNB DATA CLEANING

#purpose: Clean and transform the raw Airbnb data into a SQL table.

#source table: airbnb_raw
#output table: airbnb_clean

*/

-- rebuild the clean table from scratch on each run
DROP TABLE IF EXISTS airbnb_clean;

CREATE TABLE airbnb_clean AS

-- duplicate removal: drop rows that are exact copies across all columns
WITH deduped_raw AS (
    SELECT DISTINCT *
    FROM airbnb_raw
)
SELECT 

    id,

    --text cleaning: strip leading whitespace
    TRIM(listing_name) AS listing_name,

    host_id,

    --catrgorical standardization: keep only valid verification values; others become NULL
    CASE
        WHEN LOWER(TRIM(host_identity_verified)) = 'verified'
            THEN 'verified'

        WHEN LOWER(TRIM(host_identity_verified)) = 'unconfirmed'
            THEN 'unconfirmed'

        ELSE NULL
    END AS host_identity_verified,

    TRIM(host_name) AS host_name,

    -- categorical standardization: fix borough misspellings and apply consistent capitalization
    CASE
        WHEN LOWER(TRIM(neighbourhood_group)) IN
            ('brooklin', 'brookln', 'brooklyn')
            THEN 'Brooklyn'
        
        WHEN LOWER(TRIM(neighbourhood_group)) IN
            ('manhatan', 'manhattan')
            THEN 'Manhattan'
        
        WHEN LOWER(TRIM(neighbourhood_group)) = 'bronx'
            THEN 'Bronx'
        
        WHEN LOWER(TRIM(neighbourhood_group)) = 'queens'
            THEN 'Queens'
        
        WHEN LOWER(TRIM(neighbourhood_group)) = 'staten island'
            THEN 'Staten Island'
        
        ELSE TRIM(neighbourhood_group)
    END AS neighbourhood_group,

    TRIM(neighbourhood) AS neighbourhood,

    -- coordinate validation: NULL out coordinates that fall outside the NYC
    CASE
        WHEN latitude IS NOT NULL
            AND longitude IS NOT NULL
            AND (
                latitude NOT BETWEEN 40.4 AND 41.0
                OR longitude NOT BETWEEN -74.3 AND -73.6
            )
            THEN NULL
        ELSE latitude
    END AS latitude,

    CASE
        WHEN latitude IS NOT NULL
            AND longitude IS NOT NULL
            AND (
                latitude NOT BETWEEN 40.4 AND 41.0
                OR longitude NOT BETWEEN -74.3 AND -73.6
            )
            THEN NULL
        ELSE longitude
    END AS longitude,

    -- categorical standardization: convert boolean-like text to 1/10; unrecognized values become NULL
    CASE
        WHEN LOWER(TRIM(CAST(instant_bookable AS TEXT)))
            IN ('true', 't', 'yes', '1')
            THEN 1

        WHEN LOWER(TRIM(CAST(instant_bookable AS TEXT)))
            IN ('false', 'f', 'no', '0')
            THEN 0

        ELSE NULL
    END AS instant_bookable,

    LOWER(TRIM(cancellation_policy)) AS cancellation_policy,

    -- categorical standarization: apply consistent capitalization to room types
    CASE
        WHEN LOWER(TRIM(room_type)) = 'entire home/apt'
            THEN 'Entire Home/Apt'

        WHEN LOWER(TRIM(room_type)) = 'private room'
            THEN 'Private Room'

        WHEN LOWER(TRIM(room_type)) = 'shared room'
            THEN 'Shared Room'
        
        WHEN LOWER(TRIM(room_type)) = 'hotel room'
            THEN 'Hotel Room'
        
        ELSE TRIM(room_type)
    END AS room_type,

    -- numerical validation: keep construction years betweem 1800 and the current year
    CASE
        WHEN construction_year BETWEEN 1800
            AND CAST(strftime('%Y', 'now') AS INTEGER)
            THEN construction_year
        ELSE NULL
    END AS construction_year,

    -- price cleaning: remove '$' and commas, convert to numner, keep only positive values
    CASE
        WHEN price IS NULL OR TRIM(price) = ''
            THEN NULL
        
        WHEN CAST(
            REPLACE(
                REPLACE(TRIM(price), '$', ''),
                ',', ''
            ) AS REAL
        ) > 0
            THEN CAST(
                REPLACE(
                    REPLACE(TRIM(price), '$', ''),
                    ',', ''
                ) AS REAL
            )
        ELSE NULL
    END AS price,

    -- service fee cleaning: same as price, but zero is allowed
    CASE
        WHEN service_fee IS NULL OR TRIM(service_fee) = ''
            THEN NULL
        
        WHEN CAST(
            REPLACE(
                REPLACE(TRIM(service_fee), '$', ''),
                ',', ''
            ) AS REAL
        ) >= 0
            THEN CAST(
                REPLACE(
                    REPLACE(TRIM(service_fee), '$', ''),
                    ',', ''
                ) AS REAL
            )
        ELSE NULL
    END AS service_fee,

    -- numeric validation: keep values within realistic ranges; out-of-range values become NULL
    CASE
        WHEN minimum_nights BETWEEN 1 AND 365
            THEN minimum_nights
        ELSE NULL
    END AS minimum_nights,

        CASE
        WHEN number_of_reviews >= 0
            THEN number_of_reviews
        ELSE NULL
    END AS number_of_reviews,

    last_review,

    -- missing value handling: listings with zero reviews get 0 reviews per month instead of NULL
    CASE
        WHEN reviews_per_month IS NULL
            AND number_of_reviews = 0
            THEN 0
        
        WHEN reviews_per_month >= 0
            THEN reviews_per_month
        ELSE NULL
    END AS reviews_per_month,

    --numerical validation: ratings must be between 1-5, host listing counts at least 1, availability 0-365 days
    CASE
        WHEN review_rate_number BETWEEN 1 AND 5
            THEN review_rate_number
        ELSE NULL
    END AS review_rate_number,

    CASE
        WHEN calculated_host_listings_count >= 1
            THEN calculated_host_listings_count
        ELSE NULL
    END AS calculated_host_listings_count,

    CASE
        WHEN availability_365 BETWEEN 0 AND 365
            THEN availability_365
        ELSE NULL
    END AS availability_365


FROM deduped_raw;