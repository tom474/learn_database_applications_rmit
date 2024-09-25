CREATE DATABASE sample_test_2;
USE sample_test_2;

-- Problem 2: Functions & Triggers
CREATE TABLE teams (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) UNIQUE,
    points INT
) ENGINE = InnoDB;

CREATE TABLE matches (
	id INT PRIMARY KEY AUTO_INCREMENT,
    home_team INT,
    away_team INT,
    home_score INT,
    away_score INT
) ENGINE = InnoDB;

INSERT INTO teams (name, points)
VALUES
('Manchester United', 3),
('Barcelona', 5),
('RMIT', 7),
('Cuong', 5);

SELECT * FROM teams;

DELIMITER $$
CREATE FUNCTION top_team()
	RETURNS INT NOT DETERMINISTIC
    READS SQL DATA
BEGIN
	DECLARE top_id INT;
    SELECT id INTO top_id
    FROM teams
    ORDER BY points DESC
    LIMIT 1;
    
    RETURN top_id;
END $$
DELIMITER ;

SELECT top_team();

DELIMITER $$
CREATE TRIGGER new_match_update_point
	AFTER INSERT ON matches
    FOR EACH ROW
OUTER_MOST: BEGIN
	IF NEW.home_score > NEW.away_score THEN
		UPDATE teams
        SET points = points + 3
        WHERE id = NEW.home_team;
        LEAVE OUTER_MOST;
	END IF;
    IF NEW.away_score > NEW.home_score THEN
		UPDATE teams
        SET points = points + 3
        WHERE id = NEW.away_team;
        LEAVE OUTER_MOST;
	END IF;
    UPDATE teams
	SET points = points + 1
	WHERE id = NEW.home_team OR id = NEW.away_team;
END $$
DELIMITER ;

INSERT INTO matches (home_team, away_team, home_score, away_score)
VALUES
(1, 3, 3, 3),
(2, 4, 2, 3);

SELECT * FROM matches;

-- Problem 3: Stored Procedures & Transaction Management
CREATE TABLE scores (
	id INT PRIMARY KEY AUTO_INCREMENT,
	match_id INT,
	team_id INT,
	scorer_name VARCHAR(50)
) ENGINE = InnoDB;

DELIMITER $$
CREATE PROCEDURE sp_score_a_goal(
	IN param_match_id INT,
    IN param_team_id INT,
    IN param_scorer_name VARCHAR(50)
)
BEGIN
	DECLARE found INT;
    START TRANSACTION;
    
    INSERT INTO scores(match_id, team_id, scorer_name)
	VALUES
    (param_match_id, param_team_id, param_scorer_name);
    
    SELECT count(*) INTO found
	FROM matches
	WHERE id = param_match_id AND (home_team = param_team_id OR away_team = param_team_id);
    
    IF found = 0 THEN
		ROLLBACK;
	ELSE
		UPDATE matches
        SET home_score = home_score + 1
		WHERE id = param_match_id AND home_team = param_team_id;

		UPDATE matches 
        SET away_score = away_score + 1
		WHERE id = param_match_id AND away_team = param_team_id;
	  
		COMMIT;
	END IF;
END $$
DELIMITER ;

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Problem 4: Security
CREATE DATABASE university;
USE university;

CREATE TABLE result (
	student_name VARCHAR(20),
	course_name VARCHAR(20),
	score DECIMAL(5, 2)
) ENGINE = InnoDB;

CREATE ROLE 'manager_role';
CREATE ROLE 'instructor_role';
CREATE ROLE 'student_role';

CREATE USER 'first'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'last'@'localhost' IDENTIFIED BY 'password';

GRANT SELECT, UPDATE ON university.result TO 'manager_role';
GRANT SELECT, INSERT ON university.result TO 'instructor_role';
GRANT SELECT ON university.result TO 'student_role';

GRANT manager_role, instructor_role TO 'first'@'localhost';
GRANT student_role TO 'last'@'localhost';

SET ROLE 'instructor_role';
INSERT INTO result (student_name, course_name, score)
VALUES ('Alice', 'DB App', 3.2);

CREATE VIEW your_result
AS
SELECT * FROM result
WHERE student_name = 'last';

GRANT SELECT(student_name, course_name, score), UPDATE(score)
ON your_result TO 'last'@'localhost';
