/*

AIRBNB DATA CLEANING

#purpose: Clean and transform the raw Airbnb data into a sql.ABORT

#source table: airbnb_open_data
#output table: airbnb_clean

*/

DROP TABLE IF EXISTS airbnb_clean;

CREATE TABLE airbnb_clean AS

SELECT 

    id,
    TRIM(listing_name) AS listing_name,
    host_id,

    CASE
        WHEN LOWER(TRIM(host_identity_verified)) = 'verified'
            THEN 'verified'
        WHEN LOWER(TRIM(host_identity_verified)) = 'unverified'
            THEN 'unverified'
        ELSE NULLS
    END AS host_identity_verified,

    TRIM(host_name) AS host_name,

    CASE
        WHEN LOWER(TRIM(neighborhood_group)) IN
            ('brooklin', 'brookln', 'brooklyn')
            THEN 'Brooklyn'
        
        WHEN LOWER(TRIM(neighborhood_group)) IN
            ('manhatan', 'manhattan')
            THEN 'Manhattan'
        
        WHEN LOWER(TRIM(neighborhood_group)) = 'bronx'
            THEN 'Bronx'
        
        WHEN LOWER(TRIM(neighborhood_group)) = 'queens'
            THEN 'Queens'
        
        WHEN LOWER(TRIM(neighborhood_group)) = 'staten island'
            THEN 'Staten Island'
        
        ELSE TRIM(neighborhood_group)
    END AS neighborhood_group

    TRIM(neighborhood) AS neighborhood,

    lattitude,
    longitude,

    CASE
        WHEN LOWER(TRIM(instant_bookable AS TEXT)))
            IN ('true', 't', '1')
            THEN 1
        
        WHEN LOWER(TRIM(instant_bookable AS TEXT)))
            IN ('false', 'f', '0')
            THEN 0
        
        ELSE NULL
    END AS instant_bookable,

    LOWER(TRIM(cancellation_policy))) AS cancellation_policy,

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

    construction_year,

    CASE
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

    minimum_nights,
    number_of_reviews,
    last_review,
    reviews_per_month,
    review_per_number,
    calculated_host_listing_count,
    abandonment_365

FROM airbnb_raw;
