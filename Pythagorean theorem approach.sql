-- First, let's create a function using the Pythagorean theorem 
CREATE OR REPLACE FUNCTION calc_airport_distance_simple(airport1_faa char(3), airport2_faa char(3))
RETURNS float AS $$
DECLARE
    lat1 float;
    lon1 float;
    lat2 float;
    lon2 float;
BEGIN
    -- Get coordinates for first airport
    SELECT lat, lon INTO lat1, lon1 
    FROM airports 
    WHERE faa = airport1_faa;
    
    -- Get coordinates for second airport
    SELECT lat, lon INTO lat2, lon2 
    FROM airports 
    WHERE faa = airport2_faa;
    
    -- Calculate distance using Pythagorean theorem
    
    RETURN SQRT(POW(lat2 - lat1, 2) + POW(lon2 - lon1, 2));
END;
$$ LANGUAGE plpgsql;




--
--Example usage
--between two airports
SELECT calc_airport_distance_simple('04G', '06A') as simple_distance;

-- Compare distances from one airport to several others
SELECT 
    a.faa as destination_faa,
    a.name as destination_name,
    ROUND(calc_airport_distance_simple('04G', a.faa)::numeric, 4) as distance
FROM airports a
WHERE a.faa != '04G'
ORDER BY distance
LIMIT 5;

-- Find all airports within a certain "distance" of Lansdowne Airport (04G)

SELECT 
    faa,
    name,
    ROUND(calc_airport_distance_simple('04G', faa)::numeric, 4) as distance
FROM airports
WHERE faa != '04G'
    AND calc_airport_distance_simple('04G', faa) < 5
ORDER BY distance;




-- Create a view that only calculates distances from one specific airport when queried
CREATE OR REPLACE VIEW airport_distances AS
SELECT 
    '04G' as origin_faa,  -- Replace with any airport code you want as reference
    (SELECT name FROM airports WHERE faa = '04G') as origin_name,
    a2.faa as dest_faa,
    a2.name as dest_name,
    calc_airport_distance_simple('04G', a2.faa) as distance
FROM airports a2
WHERE a2.faa != '04G'
ORDER BY distance;

-- Example queries:
SELECT * FROM airport_distances LIMIT 5;