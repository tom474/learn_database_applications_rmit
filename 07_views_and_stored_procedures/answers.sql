-- Exercise 1: Views
-- Creating views
CREATE VIEW dept_stats
AS
SELECT Dnumber, Dname, mgr.Fname AS Manager_name, COUNT(*) AS NoOfEmp
FROM department
JOIN employee mgr ON Mgr_ssn = mgr.Ssn
JOIN employee emp ON Dnumber = emp.Dno
GROUP BY Dnumber, Dname, mgr.Fname;

-- Using views
SELECT * FROM dept_stats
WHERE NoOfEmp > 3;

-- Check view updatable property
SELECT * FROM information_schema.views
WHERE table_name = 'dept_stats';


-- Exercise 2: Materialized Views
-- Create material views
CREATE TABLE project_resources
SELECT Pnumber AS ProjectNumber,
	   Pname AS ProjectName,
       Plocation AS ProjectLocation,
       COUNT(*) AS TotalEmployees
FROM project
JOIN works_on ON Pnumber = Pno
GROUP BY ProjectNumber, ProjectName, ProjectLocation;

-- Using material views
SELECT * FROM project_resources;


-- Exercise 3: Stored Procedures
-- A stored procedure to increase a employee's salary
DELIMITER $$
CREATE PROCEDURE sp_update_salary(
	IN EmpID CHAR(9),
    IN IncAmt DECIMAL(5, 0)
)
BEGIN
	UPDATE employee
    SET Salary = Salary + IncAmt
    WHERE Ssn = EmpID;
END $$
DELIMITER ;

CALL sp_update_salary('123456789', 5000);

-- A stored procedure to do full refresh
DELIMITER $$
CREATE PROCEDURE sp_refresh()
BEGIN
	TRUNCATE TABLE project_resources;
    
    INSERT INTO Project_Resources
	SELECT Pnumber AS ProjectNumber,
		   Pname AS ProjectName,
		   Plocation AS ProjectLocation,
           COUNT(*) AS TotalEmployees
	FROM Project JOIN Works_on
	ON Pnumber = Pno
	GROUP BY ProjectNumber, ProjectName, ProjectLocation;
END $$
DELIMITER ;

CALL sp_refresh();

-- A stored procedure that uses transaction management
DELIMITER $$
CREATE PROCEDURE sp_update_salary_advanced(
	IN EmpID CHAR(9),
    IN IncAmt DECIMAL(5, 0),
    OUT success INT
)
BEGIN
	DECLARE emp_sal decimal(5,0);
	DECLARE sup_sal decimal(5,0);
	DECLARE `_rollback` INT DEFAULT 0;
	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `_rollback` = 1;
    
    START TRANSACTION;
    
	UPDATE employee
    SET Salary = Salary + IncAmt
    WHERE Ssn = EmpID;
    
    SELECT emp.Salary, sup.Salary
    INTO emp_sal, sup_sal
	FROM employee emp 
    JOIN employee sup ON emp.Super_ssn = sup.Ssn
	WHERE emp.Ssn = EmpID;
    
    IF `_rollback` = 1 THEN
		ROLLBACK;
		SET success = 0;
	ELSEIF emp_sal >= sup_sal THEN
		ROLLBACK;
		SET success = 0;
	ELSE
		COMMIT;
		SET success = 1;
	END IF;
END $$
DELIMITER ;

SET @outcome = 0;
CALL sp_update_salary_advanced('123456789', 5000, @outcome);
SELECT @outcome;
