-- Now, let's create a more accurate function using the Haversine formula
CREATE OR REPLACE FUNCTION calc_airport_distance_haversine(airport1_faa char(3), airport2_faa char(3))
RETURNS float AS $$
DECLARE
    lat1 float;
    lon1 float;
    lat2 float;
    lon2 float;
    R float := 3959; -- Earth's radius in miles (use 6371 for kilometers)
BEGIN
    -- Get coordinates for first airport
    SELECT lat, lon INTO lat1, lon1 
    FROM airports 
    WHERE faa = airport1_faa;
    
    -- Get coordinates for second airport
    SELECT lat, lon INTO lat2, lon2 
    FROM airports 
    WHERE faa = airport2_faa;
    
    -- Convert degrees to radians
    lat1 := radians(lat1);
    lon1 := radians(lon1);
    lat2 := radians(lat2);
    lon2 := radians(lon2);
    
    -- Haversine formula
    RETURN (2 * R * asin(sqrt(
        pow(sin((lat2 - lat1) / 2), 2) + 
        cos(lat1) * cos(lat2) * pow(sin((lon2 - lon1) / 2), 2)
    )));
END;
$$ LANGUAGE plpgsql;

-- Basic test between two specific airports
SELECT calc_airport_distance_haversine('04G', '06A') as distance_in_miles;


DROP VIEW IF EXISTS airport_distances;
-- Create a view that shows distances from one specific airport
CREATE OR REPLACE VIEW airport_distances AS
SELECT 
    a.faa as dest_faa,
    a.name as dest_name,
    calc_airport_distance_haversine('04G', a.faa) as distance_miles
FROM airports a
WHERE a.faa != '04G'
ORDER BY distance_miles;

-- Example queries using the view:

-- Find the 5 closest airports to Lansdowne Airport (04G)
SELECT *
FROM airport_distances
LIMIT 5;

-- Find all airports within 100 miles
SELECT *
FROM airport_distances
WHERE distance_miles < 100
ORDER BY distance_miles
LIMIT 5;

-- Find airports between 100 and 200 miles away
SELECT *
FROM airport_distances
WHERE distance_miles BETWEEN 100 AND 200
ORDER BY distance_miles;