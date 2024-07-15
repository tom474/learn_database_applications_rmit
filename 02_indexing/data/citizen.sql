CREATE TABLE `cities` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `lat` DECIMAL(10, 4) NOT NULL,
    `lng` DECIMAL(10, 4) NOT NULL,
    `capital` VARCHAR(255) NOT NULL,
    `population` INT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `people` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `birth_date` DATETIME NOT NULL,
    `birth_location` INT NOT NULL,
    `current_location` INT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB;