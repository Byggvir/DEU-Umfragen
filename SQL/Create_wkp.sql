use Umfragen;

drop table if exists wkp;

create table if not exists wkp 
  ( `Id` BIGINT
  , Datum DATE
  , Befragte BIGINT(20)
  , primary key (`Id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

select
    `Id` as `Id`
  , `Date` as Datum
  , Surveyed_Persons as Befragte
from Surveys 
where 
  Institute_ID = 24 
  and Parliament_ID = 0
;
