-- Create a view that analyzes various types of delays by day of week
CREATE OR REPLACE VIEW flight_delays_by_day AS
WITH day_stats AS (
    SELECT 
        -- Extract day of week (0=Sunday, 6=Saturday)
        EXTRACT(DOW FROM MAKE_DATE(year, month, day)) AS day_of_week,
        -- Convert to day name for readability
        TO_CHAR(MAKE_DATE(year, month, day), 'Day') AS day_name,
        -- Different types of delays
        dep_delay AS departure_delay,
        arr_delay AS arrival_delay,
        
        -- Calculate delay categories
        CASE 
            WHEN dep_delay <= 0 THEN 'On Time'
            WHEN dep_delay < 15 THEN 'Minor Delay'
            WHEN dep_delay < 30 THEN 'Moderate Delay'
            ELSE 'Significant Delay'
        END AS delay_category,
        
        -- Count flight
        1 AS flight_count
        
    FROM flights
)
SELECT 
    day_of_week,
    day_name,
    COUNT(*) AS total_flights,
    
    -- Departure delay statistics
    ROUND(AVG(departure_delay)::numeric, 2) AS avg_departure_delay,
    ROUND(MAX(departure_delay)::numeric, 2) AS max_departure_delay,
    
    -- Arrival delay statistics
    ROUND(AVG(arrival_delay)::numeric, 2) AS avg_arrival_delay,
    ROUND(MAX(arrival_delay)::numeric, 2) AS max_arrival_delay,
    
    -- Delay categories distribution
    ROUND(100.0 * COUNT(CASE WHEN delay_category = 'On Time' THEN 1 END) / COUNT(*), 2) AS pct_on_time,
    ROUND(100.0 * COUNT(CASE WHEN delay_category = 'Minor Delay' THEN 1 END) / COUNT(*), 2) AS pct_minor_delay,
    ROUND(100.0 * COUNT(CASE WHEN delay_category = 'Moderate Delay' THEN 1 END) / COUNT(*), 2) AS pct_moderate_delay,
    ROUND(100.0 * COUNT(CASE WHEN delay_category = 'Significant Delay' THEN 1 END) / COUNT(*), 2) AS pct_significant_delay

FROM day_stats
GROUP BY day_of_week, day_name
ORDER BY day_of_week;


-- Example usage:


-- Get complete analysis for all days
SELECT * FROM flight_delays_by_day;

-- Look at specific days
SELECT * FROM flight_delays_by_day WHERE day_name LIKE 'Mon%';

-- Focus on days with highest delays
SELECT day_name, avg_departure_delay 
FROM flight_delays_by_day 
ORDER BY avg_departure_delay DESC;