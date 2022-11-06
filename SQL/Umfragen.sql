use Umfragen;

DROP TABLE IF EXISTS `Umfragen`;

CREATE TABLE `Umfragen` (
  `Datum` date DEFAULT NULL ,
  `IId` int(11) DEFAULT NULL ,
  `Partei` char(16) DEFAULT NULL ,
  `Ergebnis` double DEFAULT 0 ,
  `Befragte` bigint(20) DEFAULT NULL ,
  PRIMARY KEY (`Datum`,`IId`,`Partei`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/Umfragen.csv'      
INTO TABLE `Umfragen`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;

DELETE FROM `Umfragen` where Datum = '2017-02-02' and IId = 8;
