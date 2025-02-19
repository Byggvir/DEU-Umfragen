use Umfragen;

DROP TABLE IF EXISTS `Institute`;

CREATE TABLE `Institute` (
  `Id` int (11) DEFAULT NULL ,
  `Name` char(255) DEFAULT NULL ,
  `Shortname` char(16) DEFAULT NULL ,
  `urlbase` char(255) DEFAULT NULL ,
  `urlsub` char(255) DEFAULT NULL ,
  `urlext` char(255) DEFAULT NULL ,
  `autoupdate` boolean DEFAULT FALSE ,
  `dawum_Id` int (11) DEFAULT NULL ,
  PRIMARY KEY (`Id`) ,
  INDEX ( `Name`) ,
  INDEX ( `dawum_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/Institute.csv'      
INTO TABLE `Institute`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
