use Umfragen;

-- Tabelle der WKP ohne Befragte

drop table if exists wkp_ergebnisse;
create table if not exists wkp_ergebnisse
  ( Datum DATE
  , SPD double
  , CDU double
  , GRUENE double
  , FDP double
  , AFD double
  , LINKE double
  , BSW double
  , Sonstige double
  , primary key (Datum));

LOAD DATA LOCAL 
INFILE '/tmp/wkp_ergebnisse.csv'      
INTO TABLE `wkp_ergebnisse`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;

-- Einfügen in die Umfragen

delete from Umfragen 
where 
  Institute_ID = 24 
  and Parliament_Id = 0;

insert into Umfragen 
select 
  Null, Datum, 24, 0 , 0, '' 
from wkp_ergebnisse;

-- Aktualisieren der Befragten aus alten Daten

update Umfragen as U 
join Surveys as W 
on U.Datum = W.`Date` 
  and U.Institute_ID = W.Institute_ID
set U.Befragte = W.Surveyed_Persons
where 
  W.Institute_ID = 24
  and W.Parliament_ID = 0; 

-- Laden der Trends

drop table if exists `wkp_trend_umfragen`;

CREATE TABLE if not exists `wkp_trend_umfragen` (
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
INFILE '/tmp/wkp_trend_umfragen.csv'      
INTO TABLE `wkp_trend_umfragen`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

delete U from Umfragen as U 
join wkp_trend_umfragen as W 
on
  U.Datum = W.Datum 
  and U.Institute_ID = W.Institute_ID;

insert into Umfragen 
select 
  NULL as `Id`
  , `Datum` as `Datum`
  , `Institute_ID` as `Institute_ID`
  , `Parliament_ID` as `Parliament_ID`
  , `Befragte` as `Befragte`
  , `Zeitraum` as `Zeitraum`
from wkp_trend_umfragen;

delete from Ergebnisse where Institute_ID = 24;

insert into Ergebnisse select Datum, 24, 0, Sonstige / 100 from wkp_ergebisse;
insert into Ergebnisse select Datum, 24, 1, CDU / 100 from wkp_ergebisse;
insert into Ergebnisse select Datum, 24, 2, SPD / 100 from wkp_ergebisse; 
insert into Ergebnisse select Datum, 24, 3, FDP / 100 from wkp_ergebisse;
insert into Ergebnisse select Datum, 24, 4, GRUENE / 100 from wkp_ergebisse;
insert into Ergebnisse select Datum, 24, 5, LINKE / 100 from wkp_ergebisse;
insert into Ergebnisse select Datum, 24, 7, AFD / 100 from wkp_ergebisse;
insert into Ergebnisse select Datum, 24, 23, BSW / 100 from wkp_ergebisse;


LOAD DATA LOCAL 
INFILE '/tmp/wkp_trend_ergebnis.csv'      
INTO TABLE `Ergebnisse`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;
