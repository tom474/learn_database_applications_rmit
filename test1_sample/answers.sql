-- Note: you must use MS Word for the test

----------------------------
-- Problem 1
SELECT s.ID AS student_id,
       name AS student_name,
       d.dept_name AS department_name,
       build_name AS building_name,
       address AS building_address
FROM student s JOIN department d
ON s.dept_name = d.dept_name
JOIN building b
ON d.building = b.build_name;

ALTER TABLE student ADD INDEX dept_idx(dept_name);
ALTER TABLE department ADD INDEX building_idx(building);

-- Explanation: indexes can be used to answer the above query
-- because the indexed columns are used in the WHERE/JOIN clause
-- (d.dept_name has a primary index on it and s.dept_name
-- has the dept_idx index on it) and (b.build_name has a primary
-- index on it and d.building has the building_idx index on it).
-- As such, index entries are searched to find the matching rows
-- instead of scanning the actual data entries.

----------------------------
-- Problem 2

CREATE TABLE course (
    title VARCHAR(255),
    dept_name VARCHAR(20),
    credits INT
)
PARTITION BY LIST(credits) (
    PARTITION p1 VALUES IN (1,4,7),
    PARTITION p2 VALUES IN (2,9),
    PARTITION p3 VALUES IN (3,8),
    PARTITION p4 VALUES IN (5,6,10)
);

INSERT INTO course VALUES
('Intro to Programming', 'Comp. Sci.', 1),
('Database Applications', 'Comp. Sci.', 2),
('Further Programming', 'Comp. Sci.', 3),
('Full Stack Development', 'Comp. Sci.', 5);

SELECT c.title, c.dept_name, d.building, c.credits
FROM course c JOIN department d
ON c.dept = d.dept_name
WHERE c.credits <= 3;

----------------------------
-- Problem 3

-- You can draw different execution plans by
-- 1. changing join order
-- 2. applying the SELECT operator before or after JOIN
-- 3. or combining them

-- For calculation:
-- You can follow the steps mentioned in the lecture slides
