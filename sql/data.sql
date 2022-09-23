CREATE TABLE `test` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`identifier` VARCHAR(50) NOT NULL,
	`name` VARCHAR(50) NULL DEFAULT NULL,
	PRIMARY KEY (`id`),
	INDEX `identifier` (`identifier`)
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=2;

ALTER TABLE `society_ledger` ADD `taxRate` int(11) DEFAULT 0;
ALTER TABLE `society_ledger` ADD `repo` int(11) DEFAULT 0;