-- Exercise 1: Transaction
SELECT * FROM department;
SELECT * FROM employee;

-- Scenario #1
START TRANSACTION;

UPDATE Department
SET Mgr_ssn = '123456789', Mgr_start_date = CURDATE()
WHERE Dnumber = 5;

UPDATE Employee
SET Salary = Salary + 2000
WHERE Ssn = '123456789';

COMMIT;

-- Scenario #2
START TRANSACTION;

UPDATE Department
SET Mgr_ssn = '123456789', Mgr_start_date = CURDATE()
WHERE Dnumber = 5;

UPDATE Employee
SET Salary = Salary + 2000
WHERE Ssn = '123456789';

ROLLBACK;


-- Exercise 2: Locks
-- 2.1 Shared lock & Exclusive lock
-- Session #1
-- T1
START TRANSACTION;

-- T3
SELECT * FROM Employee
WHERE Ssn = '123456789' FOR SHARE;

-- T6
COMMIT;

-- Session #2
-- T2
START TRANSACTION;

-- T4
SELECT * FROM Employee
WHERE Ssn = '123456789' FOR SHARE;

-- T5
UPDATE Employee
SET Salary = Salary + 1000
WHERE Ssn = '123456789';

-- T7
COMMIT;

-- 2.2 Deadlock
-- Session #1
-- T1
START TRANSACTION;

-- T3
SELECT * FROM Employee
WHERE Ssn = '123456789' FOR SHARE;

-- T5
UPDATE Employee
SET Salary = Salary + 1000
WHERE Ssn = '333445555';

-- T7
COMMIT;

-- Session #2
-- T2
START TRANSACTION;

-- T4
SELECT * FROM Employee
WHERE Ssn = '333445555' FOR SHARE;

-- T6
UPDATE Employee
SET Salary = Salary + 1000
WHERE Ssn = '123456789';

-- T8
COMMIT;


-- Exercise 3: Isolation Levels
-- 3.1 Default level (Repeatable Read)
-- Session #1
-- T1
START TRANSACTION;

-- T3
SELECT * FROM Employee
WHERE Ssn = '123456789';

-- T6
SELECT * FROM Employee
WHERE Ssn = '123456789';

-- T7
COMMIT;

-- Session #2
-- T2
START TRANSACTION;

-- T4
UPDATE Employee
SET Salary = Salary + 1000
WHERE Ssn = '123456789';

-- T5
COMMIT;

-- 3.2 Read Uncommitted
-- Session #1
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- T1
START TRANSACTION;

-- T3
SELECT * FROM Employee
WHERE Ssn = '123456789';

-- T6
SELECT * FROM Employee
WHERE Ssn = '123456789';

-- T7
COMMIT;

-- Session #2
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- T2
START TRANSACTION;

-- T4
UPDATE Employee
SET Salary = Salary + 1000
WHERE Ssn = '123456789';

-- T5
COMMIT;
