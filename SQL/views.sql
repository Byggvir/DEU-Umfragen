use Umfragen;

create or replace view LetzteUmfrage as
select 
      Institute_ID as Institute_ID
    , max(Datum) as Datum
from Umfragen 
group by 
    Institute_ID;

/*

*/

create or replace view LetzteErgebnisse as
select 
    E.*
    , U.Befragte
    , I.*
    , P.Shortcut as Partei
    , P.Color
    , P.Fill
from LetzteUmfrage as D
join Umfragen as U
on 
    D.Institute_ID = U.Institute_ID
    and D.Datum = U.Datum
join Institute as I 
on I.`Id` = D.Institute_ID 
join Ergebnisse as E
on
    E.Datum = D.Datum
    and D.Institute_ID = E.Institute_ID
join Partei as P 
on P.`Id` = E.`Partei_ID` 
where 
    E.Ergebnis > 0 
order by 
    I.`Id`, P.`Id` ;

    /* */
    
create or replace view UmfrageErgebnisse as

select 
    I.`Id` as Institute_ID
    , I.Shortname as Institut
    , P.`Id` as Partei_ID
    , P.Shortcut as Partei
    , U.Datum as Datum
    , U.Befragte as Befragte
    , E.Ergebnis as Ergebnis
from Umfragen as U
join Ergebnisse as E
on 
    U.Datum = E.Datum
    and U.Institute_ID = E.Institute_ID
join Institute as I
on 
    U.Institute_ID = I.`Id`
join Partei as P
on 
    E.Partei_ID = P.`Id`
where
  U.Parliament_ID = 0
;

/* dawum views */

create or replace view LastSurveys as
select 
    S.*
    , I.`Name` as `Name`
    ,  max(`Date`) as `Date_Last`
from Surveys as S 
join Institutes as I
on 
    S.`Institute_ID` = I.`Id` 
group by 
    S.`Institute_ID`
    , S.`Parliament_ID`
;

create or replace view LastSurveyResults as
select 
    L.*
    , P.Name as Partyname
    , R.Result as Result
from LastSurveys as L
join Results as R
on L.`Id` = R.`Survey_ID`
join Parties as P
on R.Party_ID = P.`Id`

;

create or replace view `Spanne` AS 
select 
      `Partei` AS `Partei`
    , `Partei_ID` AS `Partei_ID`
    , 'Minimum' AS `Spanne`
    ,  min( `Ergebnis` ) AS `Ergebnis`
from `LetzteErgebnisse` 
group by `Partei_ID` 
union 
select 
      `Partei` AS `Partei`
    , `Partei_ID` AS `Partei_ID`
    , 'Maximum' AS `Spanne`
    , max(`Ergebnis`) AS `Ergebnis` 
from `LetzteErgebnisse` 
group by `Partei_ID` 
order by `Partei_ID`;


CREATE or replace view `Zusammenfassung` as

select `Partei` AS `Partei`
, concat(round(min(`Ergebnis`) * 100,1),' % bis ',round(max(`Ergebnis`) * 100,1),' %') AS `Spanne` 

from `LetzteErgebnisse` 
group by `Partei` 
order by `Partei_ID`
