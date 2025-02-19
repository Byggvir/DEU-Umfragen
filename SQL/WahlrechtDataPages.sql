use Umfragen;

DROP TABLE IF EXISTS `wahlrechtdatapages`;

CREATE TABLE `wahlrechtdatapages` (
  `IId` int (11) DEFAULT NULL ,
  `PId` int (11) DEFAULT NULL ,
  `page` char(255) DEFAULT NULL ,
  `title` char(255) DEFAULT NULL ,
  PRIMARY KEY (`IId`, `PId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/WahlrechtDataPages.csv'      
INTO TABLE `wahlrechtdatapages`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
