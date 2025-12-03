--1. Import Your Data

--2. Explore Your Data
--View Top Rows
SELECT * FROM Divvy_Trips_2019_Q1 LIMIT 10;
SELECT * FROM Divvy_Trips_2020_Q1 LIMIT 10;

--Total Number of Rows 
SELECT COUNT(*) FROM Divvy_Trips_2019_Q1; --365069
SELECT COUNT(*) FROM Divvy_Trips_2020_Q1; --426887
--Count usertype in 2 quarters
SELECT usertype, COUNT(*) AS total_2019_q1 
FROM Divvy_Trips_2019_Q1
GROUP by usertype; --casual:23163, member: 341906

SELECT member_casual AS usertype, COUNT(*) AS total_2020_q1
FROM Divvy_Trips_2020_Q1
GROUP by member_casual; --casual: 485480, member:378407

--Select distinct
SELECT DISTINCT from_station_name,to_station_name FROM Divvy_Trips_2019_Q1;
SELECT DISTINCT start_station_name,end_station_name FROM Divvy_Trips_2020_Q1;

--Min,max
SELECT MIN(ride_length), MAX(ride_length) FROM Divvy_Trips_2019_Q1; --00:00:35 , 23:57:54
SELECT MIN(ride_length), MAX(ride_length) FROM Divvy_Trips_2020_Q1; --0:00:00 , 9:59:00

--Average
SELECT AVG(ride_length) FROM Divvy_Trips_2019_Q1; --0.02875894693879787
SELECT AVG(ride_length) FROM Divvy_Trips_2020_Q1; --0.045386718265020956

--3. Use JOIN or UNION Statements (Combine Data)
--Create a combine table
create TABLE all_trips as
SELECT
    trip_id AS ride_id,
    start_time AS started_at,
    usertype,
    -- 1. Split date
    SUBSTR(start_time,1,
        INSTR(start_time, ' ') - 1
    ) AS trip_date,
    -- 2. Split time
    SUBSTR(
        start_time,
        INSTR(start_time, ' ') + 1
    ) AS trip_time,
    ride_length,
    day_of_week
FROM
    Divvy_Trips_2019_Q1
UNION ALL
SELECT
    ride_id,
    started_at,
    member_casual as usertype,
    -- 1. Split date
    SUBSTR(started_at,1,
        INSTR(started_at, ' ') - 1
    ) AS trip_date,
    -- 2. Split time
    SUBSTR(
        started_at,
        INSTR(started_at, ' ') + 1
    ) AS trip_time,
    ride_length,
    day_of_week
FROM
    Divvy_Trips_2020_Q1;

--View, member, start time and ride length of each trip
SELECT trip_id AS ride_id, start_time, usertype, ride_length
FROM Divvy_Trips_2019_Q1
UNION ALL
SELECT ride_id, started_at as start_time, member_casual as usertype, ride_length
FROM Divvy_Trips_2020_Q1;

--4. Create Summary Statistics
--Summary total trip placed by usertype in each year
SELECT
    SUBSTR(trip_date, -4) AS trip_year, 
    usertype,
    COUNT(ride_id) AS total_trip      
FROM
    all_trips
GROUP BY
    trip_year, usertype
ORDER BY
    trip_year, usertype;
/*-- 2019: casual - 23163, member - 341906
2019: casual - 48480, member - 378407
--*/

--Summary total rides, average time length, longest time length of member usertype and casual usertype
SELECT
    usertype,
    COUNT(ride_id) AS total_rides,
    AVG(ride_length) AS avg_ride_length,
    MAX(ride_length) AS longest_trip
FROM
    all_trips
GROUP BY
    usertype;
--casual: 71643 total_rides, 0.2966235361444942 avg_ride_length, 9:59:00 longest_trip
--member: 720313 total_rides, 0.0.011971184748852235 avg_ride_length, 9:54:00 longest_trip

--Summary total trip in each day of week of member usertype and casual usertype
SELECT
   usertype,
	day_of_week,
	COUNT(ride_id) AS total_trips
FROM
    all_trips
GROUP BY
    usertype, day_of_week
ORDER BY
    usertype, day_of_week;
--Numbers 1 (Sunday) through 7 (Saturday)
/*--casual: Sunday - 18652, Monday - 6747, Tuesday - 7992, Wednesday - 8422, Thursday - 7815, Friday - 8542, Saturday - 13473
member: Sunday - 60197, Monday - 110430, Tuesday - 127974, Wednesday - 121903, Thursday - 125228, Friday - 115168, Saturday - 59413
--*/

--Summary total trip in each month of member usertype and casual usertype
SELECT usertype, 
		SUBSTR(
        trip_date,
        INSTR(trip_date, '/') + 1,
        INSTR(SUBSTR(trip_date, INSTR(trip_date, '/') + 1), '/') - 1
    ) AS trip_month,
    COUNT(ride_id) AS total_rides
FROM
    all_trips
GROUP BY
    usertype,trip_month
ORDER BY
    usertype,trip_month;
/*--casual: January - 12387, February - 15508, March - 43748
casual: January - 234769, February - 220263, March - 265281
--*/
