--- with use time below 1 hour, compare total ride by customer type and day of week

WITH
-- cte of quarter, time, ride id and customer type, filter use hour < 1
day_of_week AS
(
	SELECT 
		day_of_week,
		ride_id,
		member_casual
	FROM
		previous_12_months_trip
	WHERE
		DATEDIFF(mi, started_at, ended_at)/60 < 1
		AND DATEPART(hour, started_at) between 16 and 18
),
member AS
(
	SELECT 
		day_of_week,
		COUNT(ride_id)/12 as total_member_ride
	FROM 
		day_of_week
	WHERE
		member_casual = 'member'
	GROUP BY 
		day_of_week
),
casual AS
(
SELECT 
		day_of_week,
		COUNT(ride_id)/12 as total_casual_ride
	FROM 
		day_of_week
	WHERE
		member_casual = 'casual'
	GROUP BY 
		day_of_week
)
SELECT 
	member.day_of_week,
	member.total_member_ride,
	casual.total_casual_ride
FROM 
	member
JOIN
	casual ON member.day_of_week = casual.day_of_week
ORDER BY 
	day_of_week ASC;