use Umfragen;

drop table if exists wkp;

create table if not exists wkp 
  ( `Id` BIGINT
  , Datum DATE
  , Befragte BIGINT(20)
  , primary key (`Id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

select `Id`, Datum, Befragte from Umfragen 
where Institute_ID = 24 ;

/* select `Date` as Datum, Surveyed_Persons as Befragte from Surveys where Institute_ID = 24 and Parliament_ID = 0;
*/

DROP TABLE IF EXISTS `Umfragen`;

CREATE TABLE `Umfragen` (
  `Id` BIGINT(20) AUTO_INCREMENT,
  `Datum` date DEFAULT NULL ,
  `Institute_ID` int(11) DEFAULT 0 ,
  `Parliament_ID` int(11) DEFAULT 0 ,
  `Befragte` bigint(20) DEFAULT 0 ,
  `Zeitraum` CHAR(255) DEFAULT '',
  PRIMARY KEY (`Id`) ,
  INDEX (`Datum`,`Institute_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/Umfragen.csv'      
INTO TABLE `Umfragen`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;

DELETE FROM `Umfragen` where Datum = '2017-02-02' and Institute_ID = 1;

DROP TABLE IF EXISTS `Ergebnisse`;

CREATE TABLE `Ergebnisse` (
  `Datum` date DEFAULT NULL ,
  `Institute_ID` int(11) DEFAULT NULL ,
  `Partei_ID` int(11) DEFAULT NULL ,
  `Ergebnis` double DEFAULT 0 ,
  PRIMARY KEY (`Datum`,`Institute_ID`,`Partei_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/Ergebnisse.csv'      
INTO TABLE `Ergebnisse`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;

DELETE FROM `Ergebnisse` where Datum = '2017-02-02' and Institute_ID = 1;
