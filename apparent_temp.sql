CREATE OR REPLACE FUNCTION calculate_apparent_temp(temp DOUBLE PRECISION, wind_speed DOUBLE PRECISION, humid DOUBLE PRECISION)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
AS $$
DECLARE
    wind_chill DOUBLE PRECISION;
    heat_index DOUBLE PRECISION;
BEGIN
    -- Calculate Wind Chill if temperature <= 50°F and wind speed > 3 mph
    IF temp <= 50 AND wind_speed > 3 THEN
        wind_chill := 35.74 + (0.6215 * temp) - (35.75 * POWER(wind_speed, 0.16)) + (0.4275 * temp * POWER(wind_speed, 0.16));
    ELSE
        wind_chill := temp;
    END IF;

    -- Calculate Heat Index if temperature >= 80°F and humidity >= 40%
    IF temp >= 80 AND humid >= 40 THEN
        heat_index := -42.379
                      + (2.04901523 * temp)
                      + (10.14333127 * humid)
                      - (0.22475541 * temp * humid)
                      - (0.00683783 * POWER(temp, 2))
                      - (0.05481717 * POWER(humid, 2))
                      + (0.00122874 * POWER(temp, 2) * humid)
                      + (0.00085282 * temp * POWER(humid, 2))
                      - (0.00000199 * POWER(temp, 2) * POWER(humid, 2));
    ELSE
        heat_index := temp;
    END IF;

    -- Return apparent temperature based on conditions
    IF temp <= 50 AND wind_speed > 3 THEN
        RETURN wind_chill;
    ELSIF temp >= 80 AND humid >= 40 THEN
        RETURN heat_index;
    ELSE
        RETURN temp;
    END IF;
END;
$$;


--Create a View to Include Apparent Temperature
 drop view flights_with_apparent_temp
CREATE OR REPLACE VIEW flights_with_apparent_temp AS
SELECT
    f.*,
    w.temp AS actual_temp,
    calculate_apparent_temp(w.temp, w.wind_speed, w.humid) AS apparent_temp
FROM flights f
JOIN weather w
    ON f.origin = w.origin
    AND f.year = w.year
    AND f.month = w.month
    AND f.day = w.day
    AND f.hour = w.hour;
	
--test to fetch all flights with the calculated apparent_temp
SELECT *
FROM flights_with_apparent_temp
LIMIT 10;
