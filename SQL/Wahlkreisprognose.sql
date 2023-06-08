use Umfragen;
/*
drop table if exists wkp;

create table wkp 
  ( Datum DATE
  , Befragte BIGINT(20)
  , primary key (Datum)
  ) 
select Datum from Umfragen where Institute_ID = 10 ;
*/
/*
LOAD DATA LOCAL 
INFILE '/data/git/R/DEU-Umfragen/data/befragte.csv'      
INTO TABLE `wkp`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;
*/

drop table if exists wahlkreisprognose;
create table if not exists wahlkreisprognose
  ( Datum DATE
  , SPD double
  , CDU double
  , GRUENE double
  , FDP double
  , AFD double
  , LINKE double
  , Sonstige double
  , primary key (Datum));

LOAD DATA LOCAL 
INFILE '/tmp/wahlkreisprognose.csv'      
INTO TABLE `wahlkreisprognose`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;

insert into Umfragen select Datum, 10, 0 , 0 from wahlkreisprognose;
update Umfragen as U join wkp as W on U.Datum = W.Datum and U.Institute_ID = 10  set U.Befragte = W.Befragte; 

delete from Ergebnisse where Institute_ID = 10;

insert into Ergebnisse select Datum, 10, 0, Sonstige / 100 from wahlkreisprognose;
insert into Ergebnisse select Datum, 10, 1, CDU / 100 from wahlkreisprognose;
insert into Ergebnisse select Datum, 10, 2, SPD / 100 from wahlkreisprognose; 
insert into Ergebnisse select Datum, 10, 3, FDP / 100 from wahlkreisprognose;
insert into Ergebnisse select Datum, 10, 4, GRUENE / 100 from wahlkreisprognose;
insert into Ergebnisse select Datum, 10, 5, LINKE / 100 from wahlkreisprognose;
insert into Ergebnisse select Datum, 10, 7, AFD / 100 from wahlkreisprognose;
