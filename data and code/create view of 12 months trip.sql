--create a view of previous 12 months trip 
--by union 12 tables of trip data from April 2021 to March 2022
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