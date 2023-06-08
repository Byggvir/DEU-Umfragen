use Umfragen;

drop table if exists wkp;

create table wkp 
  ( Datum DATE
  , Befragte BIGINT(20)
  , primary key (Datum)
  ) 
select Datum from Umfragen where Institute_ID = 10 ;

DROP TABLE IF EXISTS `Umfragen`;

CREATE TABLE `Umfragen` (
  `Datum` date DEFAULT NULL ,
  `Institute_ID` int(11) DEFAULT 0 ,
  `Parliament_ID` int(11) DEFAULT 0 ,
  `Befragte` bigint(20) DEFAULT 0 ,
  PRIMARY KEY (`Datum`,`Institute_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

LOAD DATA LOCAL 
INFILE '/tmp/Umfragen.csv'      
INTO TABLE `Umfragen`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;

DELETE FROM `Umfragen` where Datum = '2017-02-02' and Institute_ID = 8;

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

DELETE FROM `Ergebnisse` where Datum = '2017-02-02' and Institute_ID = 8;
