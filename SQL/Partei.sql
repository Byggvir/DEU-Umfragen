use Umfragen;

DROP TABLE IF EXISTS `Partei`;

CREATE TABLE `Partei` (
  `Id` int (11) DEFAULT NULL ,
  `Partei` char(16) DEFAULT NULL ,
  `Fill` char(32) DEFAULT NULL ,
  `Color` char(32) DEFAULT NULL ,
  PRIMARY KEY (`Id`) ,
  INDEX ( `Partei`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/Partei.csv'      
INTO TABLE `Partei`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
