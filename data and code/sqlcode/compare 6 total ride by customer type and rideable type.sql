WITH 
below_1_hour as
(
	SELECT 
		rideable_type,
		ride_id,
		member_casual
	from
		previous_12_months_trip
	WHERE
		DATEDIFF(hour, started_at, ended_at) < 1
		AND DATEPART(hh, started_at) IN(5,6,7,8,9)
),
member as
(
	SELECT 
		rideable_type,
		COUNT(ride_id)/12 as total_member_ride
	FROM
		below_1_hour
	WHERE
		member_casual = 'member'
	GROUP BY
		rideable_type
),
casual as
(
	SELECT 
		rideable_type,
		COUNT(ride_id)/12 as total_casual_ride
	FROM
		below_1_hour
	WHERE
		member_casual = 'casual'
	GROUP BY
		rideable_type
)
SELECT 
	casual.rideable_type,
	member.total_member_ride,
	casual.total_casual_ride
FROM
	member
FULL OUTER JOIN 
	casual ON member.rideable_type = casual.rideable_type
