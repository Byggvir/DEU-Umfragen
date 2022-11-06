use Umfragen;

DROP TABLE IF EXISTS `Institute`;

CREATE TABLE `Institute` (
  `Id` int (11) DEFAULT NULL ,
  `Name` char(255) DEFAULT NULL ,
  `url` char(255) DEFAULT NULL ,
  `Shortname` char(16) DEFAULT NULL ,
  `autoupdate` boolean DEFAULT FALSE ,
  PRIMARY KEY (`Id`) ,
  INDEX ( `Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/Institute.csv'      
INTO TABLE `Institute`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
