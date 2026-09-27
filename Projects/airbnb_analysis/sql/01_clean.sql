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
        WHEN LOWER(TRIM(neighborhood)) IN
            ('brooklin', 'brookln', 'brooklyn')
            THEN 'Brooklyn'
        
        WHEN LOWER(TRIM(neighborhood)) IN
            ('manhatan', 'manhattan')
            THEN 'Manhattan