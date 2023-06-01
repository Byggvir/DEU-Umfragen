use Umfragen;

create or replace view LetzteUmfragen as
select
    U.*
    , I.*
    , P.Id as PId
    , P.Color as Color
    , P.Fill as Fill 
from
    Umfragen as U
join ( 
    select 
        max(Datum) as Datum
        , IId
    from Umfragen
    group by IId
    ) as D
on 
    D.Datum=U.Datum and D.IId = U.IId
join Institute as I
on
    I.Id = U.IId
join Partei as P
on 
    P.Partei = U.Partei
where U.Ergebnis > 0
order by 
    I.Id, P.Id 
;

create or replace view Zusammenfassung as
select 
    Partei
    , concat( round(min(Ergebnis)*100,1)," % bis "
    , round(max(Ergebnis)*100,1), " %") as Spanne 
from LetzteUmfragen
group by 
    Partei 
order by PId;

create or replace view Spanne as
select 
    Partei
    , PId
    , 'Minimum' as Spanne
    , min(Ergebnis) as Ergebnis
from LetzteUmfragen
group by 
    PId 
union
select 
    Partei
    , PId
    , 'Maximum' as Spanne
    , max(Ergebnis) as Ergebnis
from LetzteUmfragen
group by 
    PId 
order by PId;
