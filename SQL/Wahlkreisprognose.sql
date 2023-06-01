use Umfragen;

drop table if exists wkp;

create temporary table wkp 
  ( Datum date
  , Befragte bigint(20)
  , primary key (Datum)
  ) 
select Datum, Befragte from wahlkreisprognose;

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
  , Befragte bigint(20) default 1300
  , primary key (Datum));

LOAD DATA LOCAL 
INFILE '/tmp/wahlkreisprognose.csv'      
INTO TABLE `wahlkreisprognose`
FIELDS TERMINATED BY ';'
IGNORE 0 ROWS;

update wahlkreisprognose as w join wkp as b on w.Datum = b.Datum set w.Befragte = b.Befragte; 

delete from Umfragen where IId = 10;

insert into Umfragen select Datum, 10, 'SPD', SPD /100, Befragte from wahlkreisprognose; 
insert into Umfragen select Datum, 10, 'CDU/CSU', CDU/100, Befragte from wahlkreisprognose;
insert into Umfragen select Datum, 10, 'GRÜNE', GRUENE/100, Befragte from wahlkreisprognose;
insert into Umfragen select Datum, 10, 'FDP', FDP/100, Befragte from wahlkreisprognose;
insert into Umfragen select Datum, 10, 'AfD', AFD/100, Befragte from wahlkreisprognose;
insert into Umfragen select Datum, 10, 'LINKE', LINKE/100, Befragte from wahlkreisprognose;
insert into Umfragen select Datum, 10, 'Sonstige', Sonstige/100, Befragte from wahlkreisprognose;


