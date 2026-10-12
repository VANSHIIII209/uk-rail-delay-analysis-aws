-- Query 1: Journey Status Breakdown
SELECT 
    "journey status",
    COUNT(*) AS total_journeys
FROM vanshika_uk_rail_data
GROUP BY "journey status"
ORDER BY total_journeys DESC;


-- Query 2: Delay Reasons (Cleaned - handles case-sensitivity duplicates in raw data)
SELECT 
    CASE 
        WHEN LOWER("reason for delay") LIKE '%signal%' THEN 'Signal Failure'
        WHEN LOWER("reason for delay") LIKE '%weather%' THEN 'Weather'
        WHEN LOWER("reason for delay") LIKE '%staff%' THEN 'Staffing Issue'
        ELSE "reason for delay"
    END AS delay_category,
    COUNT(*) AS total_incidents
FROM vanshika_uk_rail_data
WHERE "journey status" != 'On Time'
GROUP BY 
    CASE 
        WHEN LOWER("reason for delay") LIKE '%signal%' THEN 'Signal Failure'
        WHEN LOWER("reason for delay") LIKE '%weather%' THEN 'Weather'
        WHEN LOWER("reason for delay") LIKE '%staff%' THEN 'Staffing Issue'
        ELSE "reason for delay"
    END
ORDER BY total_incidents DESC;


-- Query 3: Station-wise Delay Rate (with sample-size caution via high volume stations)
SELECT 
    "departure station",
    COUNT(*) AS total_journeys,
    SUM(CASE WHEN "journey status" = 'Delayed' THEN 1 ELSE 0 END) AS delayed_count,
    ROUND(100.0 * SUM(CASE WHEN "journey status" = 'Delayed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_percentage
FROM vanshika_uk_rail_data
GROUP BY "departure station"
ORDER BY delay_percentage DESC
LIMIT 10;


-- Query 4: Ticket Class Delay Rate (HAVING clause filters low sample-size groups)
SELECT 
    "ticket class",
    COUNT(*) AS total_journeys,
    SUM(CASE WHEN "journey status" = 'Delayed' THEN 1 ELSE 0 END) AS delayed_journeys,
    ROUND(100.0 * SUM(CASE WHEN "journey status" = 'Delayed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct,
    ROUND(AVG(price), 2) AS avg_price
FROM vanshika_uk_rail_data
GROUP BY "ticket class"
HAVING COUNT(*) > 50
ORDER BY delay_rate_pct DESC;


-- Query 5: Refund Request Rate by Journey Status
SELECT 
    "journey status",
    COUNT(*) AS total_journeys,
    SUM(CASE WHEN "refund request" = 'Yes' THEN 1 ELSE 0 END) AS refund_requests,
    ROUND(100.0 * SUM(CASE WHEN "refund request" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS refund_rate_pct
FROM vanshika_uk_rail_data
GROUP BY "journey status"
ORDER BY refund_rate_pct DESC;


-- Query 6: Railcard Type vs Delay Pattern
SELECT 
    railcard,
    COUNT(*) AS total_journeys,
    ROUND(100.0 * SUM(CASE WHEN "journey status" = 'Delayed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delay_rate_pct,
    ROUND(AVG(price), 2) AS avg_price
FROM vanshika_uk_rail_data
GROUP BY railcard
HAVING COUNT(*) > 50
ORDER BY delay_rate_pct DESC;