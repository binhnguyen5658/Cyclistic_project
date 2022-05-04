-- COMPARE THE CUSTOMER AMOUNT BY CUSTOMER TYPE AND STARTED TIME OF DAY (use time below 1 hour)

WITH
-- subtable of quarter, time, ride id and customer type, filter use hour < 1
time as
(
	SELECT
		DATEPART(qq, started_at) as quarter,
		DATEPART(hh, started_at) as time,
		ride_id,
		member_casual
	FROM 
		previous_12_months_trip
	WHERE
		DATEDIFF(mi, started_at, ended_at)/60 < 1
),
-- group total ride by member type
member AS
(
	SELECT 
		quarter,
		time,
		COUNT(ride_id)/3 as total_member
	FROM
		time
	WHERE 
		member_casual = 'member'
	GROUP BY
		quarter,
		time
),
-- group total ride by casual type
casual AS
(
	SELECT 
		quarter,
		time,
		COUNT(ride_id)/3 as total_casual
	FROM
		time
	WHERE 
		member_casual = 'casual'
	GROUP BY
		quarter,
		time
)
-- table of total member and casual ride by join casual and member CTE above
SELECT 
	member.quarter,
	member.time,
	member.total_member,
	casual.total_casual
FROM
	member
JOIN 
	casual 
		ON member.quarter = casual.quarter
			AND member.time = casual.time
ORDER BY 
	quarter ASC,
	time ASC;