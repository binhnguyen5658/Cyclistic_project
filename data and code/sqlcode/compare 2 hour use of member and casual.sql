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