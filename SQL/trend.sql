use Umfragen;

delimiter //

-- Mitte zwischen zwei Tagen

create or replace function middate ( von DATE, bis DATE ) returns DATE

begin
  return (adddate(von, interval  floor(datediff(bis,von)/2) day )) ;
end

//

-- Gewichtung Alter der Umfrage nach Volksverpetzer

create or replace function volksverpetzer ( t INT) returns DOUBLE

begin
  return (10/(0.1544*t+7.6449)/power(t+5,2));
end

//

-- Gewichtung exponentiell abnehmend nach Alter der Umfrage

create or replace function exp_weight ( t INT) returns DOUBLE

begin
  return (power(0.8,t));
end

//

delimiter ;

-- Gewichtete Umfragen

create or replace view WeightedSurveys as 
select 
    *
    , Surveyed_Persons * exp_weight(datediff((select max(middate(Survey_Start,Survey_End)) from Surveys where Parliament_Id = 0 ), middate(Survey_Start,Survey_End))) as Weight
from Surveys as S 
where 
    Parliament_Id = 0
    and Institute_Id <> 16    
--    and `Date` < "2021-09-26"
    and datediff((select max(middate(Survey_Start,Survey_End)) from Surveys where Parliament_Id = 0 ), middate(Survey_Start,Survey_End)) < 50;

-- Gewichtete TrendAnalyse

create or replace view TrendAnalyse as
select 
    case when Party_Id = 8 then 0 else Party_Id end as PId 
    , sum(Weight * Result) / (select sum(Weight) from WeightedSurveys) as Result
    , sum(Surveyed_Persons * Result) / (select sum(Surveyed_Persons) from WeightedSurveys) as RawResult
from Results as R
join WeightedSurveys as W
on R.Survey_Id = W.`Id`
group by
    PId
order by
    PId;

-- Verteilung der Gewichte auf die Institute

create or replace view TrendInstitutes as

select distinct 
  I.Name
from WeightedSurveys as W
join Institutes as I
on I.`Id` = W.Institute_Id
;
