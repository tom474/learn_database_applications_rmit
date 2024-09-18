-- Exercise 1: Functions
DELIMITER $$
CREATE FUNCTION fn_maxSalary (department_number INT)
RETURNS CHAR(9) NOT DETERMINISTIC
READS SQL DATA
BEGIN
	-- Maximum salary 
	DECLARE max_sal DECIMAL(6, 0);
    -- Ssn of the employee whose salary is maximum
    DECLARE max_ssn CHAR(9);
    
    -- Get maximum salary
    SELECT MAX(salary) INTO max_sal
    FROM employee
    WHERE dno = department_number;
    
    -- Search for ssn
    SELECT Ssn INTO max_ssn
    FROM employee
    WHERE dno = department_number AND salary = max_sal;
    
    RETURN max_ssn;
END $$
DELIMITER ;

SELECT dnumber, dname, fname, salary
FROM department
JOIN employee ON dnumber = dno
WHERE Ssn = fn_maxSalary(dnumber);


-- Exercise 2: Trigger 1
CREATE TABLE dep_avg_salary
SELECT dnumber, dname, AVG(salary) AS avg_salary
FROM department
JOIN employee ON dnumber = dno
GROUP BY dnumber, dname;

DELIMITER $$
CREATE TRIGGER trg_avg_sal
AFTER UPDATE ON employee
FOR EACH ROW
BEGIN
	-- Update average salary
	DECLARE avg_sal DECIMAL(9, 2);
    
    SELECT AVG(salary) INTO avg_sal
    FROM employee
    WHERE dno = NEW.dno;
    
    UPDATE dep_avg_salary
    SET avg_salary = avg_sal
    WHERE dnumber = NEW.dno;
END $$
DELIMITER ;


-- Exercise 3: Trigger 2
DELIMITER $$
CREATE TRIGGER trg_prevent_overwork
BEFORE INSERT ON works_on
FOR EACH ROW
BEGIN
	-- Current total hours
	DECLARE current_hours DECIMAL(5, 1);

	SELECT SUM(hours) INTO current_hours
	FROM works_on
	WHERE essn = new.essn;
  
	IF current_hours + new.hours > 40 THEN
		SIGNAL SQLSTATE '45000' SET message_text = 'Overworked!';
	END IF;
END $$
DELIMITER ;
