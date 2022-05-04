-- Compare total ride of customer type by year month 

WITH
member as
(
	SELECT 
		YEAR(started_at) as Year,
		MONTH(started_at) as Month,
		COUNT(ride_id) as total_member_ride
	FROM 
		previous_12_months_trip
	WHERE 
		member_casual = 'member'
	GROUP BY 
		YEAR(started_at),
		MONTH(started_at)
),
casual as
(
	SELECT 
		YEAR(started_at) as Year,
		MONTH(started_at) as Month,
		COUNT(ride_id) as total_casual_ride
	FROM 
		previous_12_months_trip
	WHERE 
		member_casual = 'casual'
	GROUP BY 
		YEAR(started_at),
		MONTH(started_at)
)
SELECT
	member.Year,
	member.Month,
	member.total_member_ride,
	casual.total_casual_ride
FROM
	member
JOIN 
	casual ON member.Year = casual.Year
		AND member.Month = casual.Month
ORDER BY
	Year ASC,
	Month ASC;
