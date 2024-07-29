-- Exercise 1: Compare AND and OR

DESCRIBE EMPLOYEE;

SELECT *
FROM EMPLOYEE
WHERE Dno = 5 AND Sex = 'F';

SELECT *
FROM EMPLOYEE
WHERE Dno = 5 OR Sex = 'F';

-- Use EXPLAIN and EXPLAIN ANALYZE to check if your
-- indexes can be used to MySQL to answer the query
EXPLAIN SELECT *
FROM EMPLOYEE
WHERE Dno = 5 AND Sex = 'F';

EXPLAIN ANALYZE SELECT *
FROM EMPLOYEE
WHERE Dno = 5 AND Sex = 'F';

EXPLAIN SELECT *
FROM EMPLOYEE
WHERE Dno = 5 OR Sex = 'F';

EXPLAIN ANALYZE SELECT *
FROM EMPLOYEE
WHERE Dno = 5 OR Sex = 'F';

-- Suggested index
ALTER TABLE EMPLOYEE
ADD INDEX idx_dno_sex (Dno, Sex);

ALTER TABLE EMPLOYEE
DROP INDEX idx_dno_sex;

-- Note 1: We should create an index on a column
-- with more unique values
-- An index on (Dno) is better than on (Sex)

-- Note 2: The condition order we specified in
-- WHERE does not matter
-- (condition1 AND condition2) is the same as
-- (condition2 AND condition1) in term of performance

-- Note 3: The logical OR makes some indexes useless
-- In this case, individual indexes on individual columns work


-- Exercise 2: Order of JOIN

SELECT * FROM EMPLOYEE;
SELECT * FROM DEPARTMENT;
SELECT * FROM DEPENDENT;

SELECT Fname, Lname, Dname, Dependent_name
FROM EMPLOYEE
JOIN DEPARTMENT ON Dno = Dnumber
JOIN DEPENDENT ON Ssn = Essn;

EXPLAIN SELECT Fname, Lname, Dname, Dependent_name
FROM EMPLOYEE
JOIN DEPENDENT ON Ssn = Essn
JOIN DEPARTMENT ON Dno = Dnumber;

EXPLAIN ANALYZE SELECT Fname, Lname, Dname, Dependent_name
FROM EMPLOYEE
JOIN DEPENDENT ON Ssn = Essn
JOIN DEPARTMENT ON Dno = Dnumber;

-- MySQL provides optimizer hints
-- https://dev.mysql.com/doc/refman/8.4/en/optimizer-hints.html
-- where you can add some hints to the optimizer


-- Exercise 3: Nested-queries/Sub-queries

-- First solution
SELECT Dnumber, Dname
FROM DEPARTMENT
WHERE Dnumber IN (
	SELECT Dno
    FROM EMPLOYEE
    WHERE Ssn IN (
		SELECT Essn
        FROM DEPENDENT
    )
);

EXPLAIN ANALYZE SELECT Dnumber, Dname
FROM DEPARTMENT
WHERE Dnumber IN (
	SELECT Dno
    FROM EMPLOYEE
    WHERE Ssn IN (
		SELECT Essn
        FROM DEPENDENT
    )
);

-- Second solution
SELECT Dnumber, Dname
FROM Department
WHERE EXISTS (
    SELECT *
    FROM Employee JOIN Dependent
    ON Ssn = Essn
    WHERE Dno = Dnumber
);

EXPLAIN ANALYZE SELECT Dnumber, Dname
FROM Department
WHERE EXISTS (
    SELECT *
    FROM Employee JOIN Dependent
    ON Ssn = Essn
    WHERE Dno = Dnumber
);

-- With SUB-QUERY, you can control the execution order
-- (join order of tables) more than with JOIN
