/*

AIRBNB DATA CLEANING

#purpose: Clean and transform the raw Airbnb data into a SQL table.

#source table: airbnb_raw
#output table: airbnb_clean

*/

DROP TABLE IF EXISTS airbnb_clean;

CREATE TABLE airbnb_clean AS

WITH deduped_raw AS (
    SELECT DISTINCT *
    FROM airbnb_raw
)
SELECT 

    id,

    TRIM(listing_name) AS listing_name,

    host_id,

    CASE
        WHEN LOWER(TRIM(host_identity_verified)) = 'verified'
            THEN 'verified'

        WHEN LOWER(TRIM(host_identity_verified)) = 'unconfirmed'
            THEN 'unconfirmed'

        ELSE NULL
    END AS host_identity_verified,

    TRIM(host_name) AS host_name,

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

    CASE
        WHEN construction_year BETWEEN 1800
            AND CAST(strftime('%Y', 'now') AS INTEGER)
            THEN construction_year
        ELSE NULL
    END AS construction_year,

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
        
    CASE
        WHEN reviews_per_month IS NULL
            AND number_of_reviews = 0
            THEN 0
        
        WHEN reviews_per_month >= 0
            THEN reviews_per_month
        ELSE NULL
    END AS reviews_per_month,

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
