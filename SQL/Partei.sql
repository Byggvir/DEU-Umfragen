use Umfragen;

DROP TABLE IF EXISTS `Partei`;

CREATE TABLE `Partei` (
  `Id` int (11) DEFAULT NULL
  , `Shortcut` char(16) DEFAULT NULL
  , `Name` char(255) DEFAULT NULL
  , `Fill` char(32) DEFAULT NULL
  , `Color` char(32) DEFAULT NULL
  , PRIMARY KEY (`Id`)
  , INDEX ( `Shortcut`)
  , INDEX ( `Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
  INFILE '/data/git/R/DEU-Umfragen/data/Partei.csv'      
INTO TABLE `Partei`
  FIELDS TERMINATED BY ','
  IGNORE 1 ROWS;
