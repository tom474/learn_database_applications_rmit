-- Exercise 1: Partition based on birth year

-- 5 partitions are required
-- We need to distribute data to those 5 partitions as equally as possible
-- Because the script generates random data
-- We can assume that birth_date is uniformly distributed
-- The birth year is from 1920 to 2020: total of 100 years
-- So, use the range partitioning where each range is 20 years

-- Extend the primary key of the 'people' table to include birth_date
ALTER TABLE people
DROP PRIMARY KEY,
ADD PRIMARY KEY (id, birth_date);

-- Update the 'people' table to have 5 partitions
ALTER TABLE people
PARTITION BY RANGE (YEAR(birth_date)) (
	PARTITION p0 VALUES LESS THAN (1940),
	PARTITION p1 VALUES LESS THAN (1960),
    PARTITION p2 VALUES LESS THAN (1980),
    PARTITION p3 VALUES LESS THAN (2000),
    PARTITION p4 VALUES LESS THAN MAXVALUE
);

-- View partition data distribution
USE information_schema;
SHOW TABLES;
SELECT *
FROM partitions;
SELECT partition_name, table_rows
FROM partitions
WHERE table_name = 'people';

-- Count people whose ages are from 20 to 30

-- This query does not use partition information
SELECT COUNT(*)
FROM people
WHERE YEAR(CURDATE()) - YEAR(birth_date) BETWEEN 20 AND 30;

-- This query specifies partitions explicitly
SELECT COUNT(*)
FROM people PARTITION (p3, p4)
WHERE YEAR(CURDATE()) - YEAR(birth_date) BETWEEN 20 AND 30;

-- This query can use the partition information
SELECT COUNT(*) FROM people
WHERE birth_date >= '1994-01-01'
AND birth_date <= '2004-12-31';

-- Conclusion:
-- 1. Make your queries as simple as possible
-- 2. Add partition information explicitly to help the database engine

-------------------------------------------------

-- Exercise 2: Partition based on latitude and longitude

-- We always got zero for the two partitions: SE and NE
-- And the reason is because the database stops looking for further partitions
-- to insert data as soon as a comparison is final
-- So, if we have 2 partitions like this:
--     PARTITION pSW VALUES LESS THAN (-337000, 1455000),
--     PARTITION pSE VALUES LESS THAN (-337000, MAXVALUE)
-- You can see that the partition pSW will get all records whose lat < -337000
-- For records whose lat value > -337000, they cannot be stored in the
-- partition pSE either!
-- So, the only records that can be stored in pSE are those whose lat = -337000
-- and lng >= 1455000
-- However, due to the large amount of lat (and lng) values, the records whose
-- lat values are exactly -337000 may not exist at all

-- Solution: There are some solutions proposed by students 
-- that use some kind of mapping from (lat, lng) to partitions 
-- All are very good. However, we have to do the actual mapping,
-- not the database engine. That means using partitioning in this
-- case is not transparent to the application developers.
-- In other words, the applications are structured to use them efficiently.
-- That will make the database and the application are not separated well.

-- Another solution is to use only one coordinate, lat OR lng
-- But not both. Then, you can use RANGE PARTITIONING along that
-- coordinate similarly to the way we did to birth_date

ALTER TABLE cities
CHANGE lat lat DECIMAL(20, 4),
CHANGE lng lng DECIMAL(20, 4);

UPDATE cities
SET lat = lat * 10000, lng = lng * 10000;

ALTER TABLE cities
CHANGE lat lat INT,
CHANGE lng lng INT;

ALTER TABLE cities
DROP PRIMARY KEY,
ADD PRIMARY KEY (id, lat, lng);

ALTER TABLE cities
PARTITION BY RANGE COLUMNS (lat, lng) (
    PARTITION pSW VALUES LESS THAN (-335000, 1470000),
    PARTITION pSE VALUES LESS THAN (-335000, MAXVALUE),
    PARTITION pNW VALUES LESS THAN (-105789, 1470000),
    PARTITION pNE VALUES LESS THAN (MAXVALUE, MAXVALUE)
);

USE information_schema;
SHOW TABLES;
SELECT *
FROM partitions;
SELECT partition_name, table_rows
FROM partitions
WHERE table_name = 'cities';

SELECT *
FROM cities
WHERE lat < -335000 AND lng < 1470000;

-- Exercise 3: Vietnamese Provinces database

-- We can use LIST PARTITIONING for this exercise
-- First, expand the primary key
-- Then, add the list partitioning

ALTER TABLE provinces
DROP PRIMARY KEY,
ADD PRIMARY KEY (code, administrative_region_id);

ALTER TABLE provinces
PARTITION BY LIST(administrative_region_id) (
    PARTITION Northeast VALUES IN (1),
    PARTITION Northwest VALUES IN (2),
    PARTITION RedRiverDelta VALUES IN (3),
    PARTITION NorthCentralCoast VALUES IN (4),
    PARTITION SouthCentralCoast VALUES IN (5),
    PARTITION CentralHighlands VALUES IN (6),
    PARTITION Southeast VALUES IN (7),
    PARTITION MekongRiverDelta VALUES IN (8)
);

SELECT *
FROM provinces
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

SELECT *
FROM provinces PARTITION (Northeast)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

SELECT *
FROM provinces PARTITION (Northwest)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

-- 'Ha Noi' is here
SELECT *
FROM provinces PARTITION (RedRiverDelta)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

SELECT *
FROM provinces PARTITION (NorthCentralCoast)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

SELECT *
FROM provinces PARTITION (SouthCentralCoast)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

SELECT *
FROM provinces PARTITION (CentralHighlands)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

-- 'Ho Chi Minh' is here
SELECT *
FROM provinces PARTITION (Southeast)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');

SELECT *
FROM provinces PARTITION (MekongRiverDelta)
WHERE name IN ('Ha Noi', 'Ho Chi Minh');
