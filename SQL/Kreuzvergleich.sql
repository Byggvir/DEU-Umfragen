use Umfragen;

create or replace view KreuzVergleich as 
select 
    u1.Datum as Datum
    , u1.Institute_ID as IId1
    , u2.Institute_ID as IId2
    , u1.Partei_ID as Partei_ID
    , u1.Ergebnis as Ergebnis_x
    , u2.Ergebnis as Ergebnis_y 
from UmfrageErgebnisse as u1
join UmfrageErgebnisse as u2
on 
    abs(datediff(u1.Datum , u2.Datum)) < 8 
    and u1.Partei_ID = u2.Partei_ID 
where u1.Institute_ID <> u2.Institute_ID;

select 
    IId1
    , IId2
    , Partei_ID
    , round(exp(avg(log(Ergebnis_x/Ergebnis_y))),5) as Score
    , round(exp(stddev(log(Ergebnis_x/Ergebnis_y))), 5) as sdScore
from KreuzVergleich
where 
 IId1 = 8
 and Partei_ID = 7
group by
    IId1
    , IId2
    , Partei_ID 
;
