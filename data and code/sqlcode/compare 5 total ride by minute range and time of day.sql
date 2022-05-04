-- below 1 hour
--- use minute by time of day
WITH
-- create 4 minute range of use minute below 1 hour
minute_range AS
(
	SELECT
		ride_id,
		member_casual,
		datepart(hour, started_at) as started_at,
		CASE	
			WHEN datediff(minute, started_at, ended_at) BETWEEN 0 AND 15 THEN '0-15'
			WHEN datediff(minute, started_at, ended_at) BETWEEN 16 AND 30 THEN '16-30'
			WHEN datediff(minute, started_at, ended_at) BETWEEN 31 AND 45 THEN '31-45'
			WHEN datediff(minute, started_at, ended_at) BETWEEN 46 AND 60 THEN '46-60'
		END AS minute_range
	FROM
		previous_12_months_trip
	WHERE
		datediff(minute, started_at, ended_at) <= 60
),
-- total member ride of 4 minute range
member AS
(
	SELECT 
		started_at,
		minute_range,
		COUNT(ride_id) as total_member_ride
	FROM
		minute_range
	WHERE
		member_casual = 'member'
	GROUP BY
		started_at,
		minute_range
),
-- total casual rider ride of 4 minute range
casual AS
(
	SELECT 
		started_at,
		minute_range,
		COUNT(ride_id) as total_casual_ride
	FROM
		minute_range
	WHERE
		member_casual = 'casual'
	GROUP BY
		started_at,
		minute_range
) 
-- join total ride of member and casual of 4 minute range
SELECT
	member.started_at,
	member.minute_range,
	member.total_member_ride,
	casual.total_casual_ride
FROM
	member
JOIN 
	casual ON member.started_at = casual.started_at 
			AND member.minute_range = casual.minute_range
ORDER BY
	started_at ASC,
	minute_range ASC;
