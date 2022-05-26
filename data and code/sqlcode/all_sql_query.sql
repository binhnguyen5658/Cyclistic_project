/**create a view of previous 12 months trip 
by union 12 tables of trip data from April 2021 to March 2022**/
CREATE VIEW previous_12_months_trip AS
SELECT * FROM trip_2021_04
UNION
SELECT * FROM trip_2021_05
UNION
SELECT * FROM trip_2021_06
UNION
SELECT * FROM trip_2021_07
UNION
SELECT * FROM trip_2021_08
UNION
SELECT * FROM trip_2021_09
UNION
SELECT * FROM trip_2021_10
UNION
SELECT * FROM trip_2021_11
UNION
SELECT * FROM trip_2021_12
UNION
SELECT * FROM trip_2022_01
UNION
SELECT * FROM trip_2022_02
UNION
SELECT * FROM trip_2022_03;

/** Compare total ride of customer type by year month  **/
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


/** Compare ride amount by use time (hour) of casual riders vs members **/
WITH
-- create formular use time by hour
use_hour AS 
(
	SELECT
		ride_id,
		datediff(mi, started_at, ended_at)/60 as use_hour,
		member_casual
	FROM 
		previous_12_months_trip
), 
-- use time of member_type
member as 
(
	SELECT
		use_hour,
		count(use_hour) as total_member
	FROM use_hour
	WHERE member_casual = 'member'
	GROUP BY use_hour
), 
-- use time of casual_type
casual AS 
(
	SELECT
		use_hour,
		count(use_hour) as total_casual
	FROM use_hour
	WHERE member_casual = 'casual'
	GROUP BY use_hour
)
SELECT
	CASE
		WHEN member.use_hour is not null THEN member.use_hour
		ELSE casual.use_hour
		END as hour_use,
	member.total_member,
	casual.total_casual
FROM member
FULL OUTER JOIN casual ON member.use_hour = casual.use_hour
ORDER BY hour_use ASC;


/** COMPARE THE CUSTOMER AMOUNT BY CUSTOMER TYPE AND STARTED TIME OF DAY (use time below 1 hour)**/
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


/** with use time below 1 hour, compare total ride by customer type and day of week **/

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


/**compare 5 total ride by minute range and time of day **/
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


/**compare 6 total ride of customer type and rideable type **/
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
	casual ON member.rideable_type = casual.rideable_type;