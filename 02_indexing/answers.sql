-- Exercise 1: Indexing
-- 1. Find a person by his/her id
SELECT *
FROM people
WHERE id = 12345;

-- No need to do anything because the `id` field has a primary index on it already
-- (It was defined as the primary key of the people table)

-- 2. Find people whose first_names start with 'Ab' 
SELECT *
FROM people
WHERE first_name LIKE "Ab%";

-- We should create an index on the first_name field
ALTER TABLE people
ADD INDEX idx_first_name (first_name);

-- But if we want to find people whose first_name ends with a string
-- SELECT * FROM people WHERE first_name LIKE (%Ab);
-- Creating an index on first_name will not help

-- 3. Display the first and last names of people whose current city is 'Melbourne'
SELECT first_name, last_name
FROM people
JOIN cities ON current_location = cities.id
WHERE name = 'Melbourne';

-- We should create an index on the 'name' column of the cities table for the WHERE condition
-- And another index on the current_location of the people table for the JOIN condition
ALTER TABLE cities
ADD INDEX idx_name (name);

ALTER TABLE people
ADD INDEX idx_current_location (current_location);

-------------------------------------------------

-- Exercise 2: More Indexing
-- 1. Find all people whose birth_location and current_location are the same
SELECT *
FROM people
WHERE birth_location = current_location;

-- We must examine every record to answer this query
-- Without index, the operation is "table scan"
-- If we create an index on the combination of (birth_location, current_location)
-- We still have to scan every index, but it is "index scan"
-- In general, index entries are smaller than data records
-- Less number of disk block reading => faster
CREATE INDEX idx_birth_current
ON people(birth_location, current_location);

-- 2. Calculate the number of people in a city whose age is in a range
SELECT *
FROM people
WHERE birth_date >= '1990-01-01'
AND birth_date <= '2000-02-02';

-- Create an index on birth_date column will help
CREATE INDEX idx_birth_date
ON people(birth_date);

-- 3. Find the 10 cities nearest to Sydney.
SELECT *
FROM cities
WHERE lat >= sydney_lat - deltaY
AND lat <= sydney_lat + deltaY
AND lng >= sydney_lng - deltaX
AND lng <= sydney_lng + deltaX;
-- deltaX and deltaY: how big you want the bounding rectangle is

SELECT name, lat, lng, (POW((lat - (-33.8650)), 2) + POW((lng - 151.2094), 2)) AS distance
FROM cities
WHERE NOT (lat = -33.8650 AND lng = 151.2094)
ORDER BY distance
LIMIT 10;

-- Creating an index on (lat, lng) will help improve the search for cities in a bounding rectangle. But that's all.
-- The cities in the result are not necessarily nearer to Sydney than the cities not in the results (why?).
CREATE INDEX idx_lat_lng
ON cities(lat, lng);

-- Exercise 3: FULLTEXT Index
CREATE TABLE articles (
	`category` VARCHAR(50),
    `text` TEXT
) ENGINE = InnoDB;

CREATE FULLTEXT INDEX idx_text
ON articles(text);

-- Perform searches in natural language mode
SELECT *
FROM articles
WHERE MATCH(`text`) AGAINST ('Artificial Intelligence' IN NATURAL LANGUAGE MODE);

SELECT *, MATCH (`text`) AGAINST ('Database Applications' IN NATURAL LANGUAGE MODE) AS score 
FROM articles;

-- Perform searches in boolean mode
SELECT *
FROM articles
WHERE MATCH(`text`) AGAINST ('+Artificial -Intelligence' IN BOOLEAN MODE);

SELECT *
FROM articles
WHERE MATCH(`text`) AGAINST ('+Database MySQL' IN BOOLEAN MODE);
