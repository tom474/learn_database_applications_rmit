-- 1. Find the names of employees who work in the 'Research' department and participate in
-- at least one project with the number of hours per week greater than or equal to 10.
SELECT Fname, Lname
FROM EMPLOYEE
JOIN DEPARTMENT ON Dno = Dnumber
JOIN WORKS_ON ON Ssn = Essn
WHERE Dname = 'Research'
AND Hours >= 10;

-- 2. Find the names of employees who are supervised by managers from the 'Research' department.
-- Note: the managers are from the 'Research' department.
-- Solution 1
SELECT Emp.Fname, Emp.Lname
FROM EMPLOYEE Emp
JOIN EMPLOYEE Mgr ON Emp.Super_ssn = Mgr.Ssn
JOIN DEPARTMENT ON Mgr.Dno = Dnumber
WHERE Dname = 'Research';

-- Solution 2
SELECT Fname, Lname
FROM EMPLOYEE
JOIN DEPARTMENT ON Super_ssn = Mgr_ssn
WHERE Dname = 'Research';

-- 3. Find the names of all departments' managers who are not working on any project.
SELECT Fname, Lname
FROM EMPLOYEE
JOIN DEPARTMENT ON Ssn = Mgr_ssn
WHERE Ssn NOT IN (
    SELECT Essn
    FROM WORKS_ON
);

-- 4. For each project, display its name and total working hours per week
-- of all employees participating in that project.
SELECT Pname, SUM(Hours) AS Total_hours
FROM PROJECT
JOIN WORKS_ON ON Pnumber = Pno
GROUP BY Pname;

-- 5. Find the names of employees who are not working on any project in 'Houston'.
SELECT Fname, Lname
FROM EMPLOYEE
WHERE Ssn NOT IN (
    SELECT Essn
    FROM WORKS_ON
    JOIN PROJECT ON Pno = Pnumber
    WHERE Plocation = 'Houston'
);

-- 6. Find the names of employees who are working on all projects in 'Houston'.
SELECT Fname, Lname
FROM EMPLOYEE
JOIN WORKS_ON W_out ON Ssn = Essn
WHERE NOT EXISTS (
    SELECT Pnumber
    FROM PROJECT LEFT JOIN (
        SELECT *
        FROM WORKS_ON W_in
        WHERE W_out.Essn = W_in.Essn
    ) AS Prj_Emp
    ON Pnumber = Prj_Emp.Pno
    WHERE Plocation = 'Houston'
    AND Prj_Emp.Pno IS NULL
);

-- Explanation 1: First, the DIFFERENCE (MINUS) operator
-- {A, B, C} DIFFERENCE {B, C, D} = {A}
-- But, MySQL doesn't support DIFFERENCE. However, we can use OUTER JOIN instead.
-- What is the result of {A, B, C} LEFT JOIN {(B, x), (C, y), (D, z)}?
-- {B, C} have matching records, but not {A}
-- So, {A, B, C} LEFT JOIN {(B, x), (C, y), (D, z)} = {(A, NULL), (B, x), (C, y)}
-- By using IS NULL condition, we can keep only (A, NULL)

-- Explanation 2: The outer query find all employees and their projects.
-- Then, for each combination of (Employee, Project), we calculate
-- (all 'Houston' projects DIFFERENCE all projects being done by this employee)
-- If the result is empty (NOT EXISTS) => this employee is working on all 'Houston' projects

-- Explanation 3: MySQL 8.0.31 added the EXCEPT operator,
-- which is another name for DIFFERENCE/MINUS
-- https://dev.mysql.com/doc/refman/8.0/en/except.html

-- 7. Find the names of employees who have the highest salaries in each department.
SELECT Fname, Lname, Salary
FROM EMPLOYEE
WHERE (Dno, Salary) IN (
    SELECT Dno, MAX(Salary)
    FROM EMPLOYEE
    GROUP BY Dno
);

-- 8. Find the names of all departments that have at least 3 employees.
SELECT Dname, COUNT(*) AS No_Emp
FROM DEPARTMENT
JOIN EMPLOYEE ON Dnumber = Dno
GROUP BY Dname
HAVING COUNT(*) >= 3;

-- 9. Find all employees who are older than their direct supervisors. 
-- For each such employee, display his/her name, birthday, supervisor's name, and supervisor's birthday.
SELECT Emp.Fname, Emp.Lname, Emp.Bdate, Sup.Fname, Sup.Lname, Sup.Bdate
FROM EMPLOYEE Emp
JOIN EMPLOYEE Sup ON Emp.Super_ssn = Sup.Ssn
WHERE Emp.Bdate <= Sup.Bdate;
