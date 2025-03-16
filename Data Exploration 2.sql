select * from athletes
select* from athlete_events

--1 which team has won the maximum gold medals over the years
select top 1 a.team,count(distinct event) as total_gold_medals  
from athletes a join athlete_events e on a.id=e.athlete_id
where medal='gold'
group by a.team
order by total_gold_medals desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
with cte as (
select a.team,ae.year , count(distinct event) as silver_medals
,rank() over(partition by team order by count(distinct event) desc) as rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Silver'
group by a.team,ae.year)
select team,sum(silver_medals) as total_silver_medals, max(case when rn=1 then year end) as  year_of_max_silver
from cte
group by team;


--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
with cte as(
select name,medal
from athletes a join athlete_events e on a.id=e.athlete_id
where medal='gold' and name not in (select distinct name from athletes a join athlete_events e on a.id=e.athlete_id where medal in ('silver','bronze')))
select top 1 name,count(*) as no_of_gold_medals
from cte
group by name
order by no_of_gold_medals desc

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with cte as(
select name,year,count(*) num_gold_medals,dense_rank()over(partition by year order by count(case when medal='gold' then 1 end) desc) as rn
from athletes a join athlete_events e on a.id=e.athlete_id
where medal='gold'
group by name,year)
select year,num_gold_medals,STRING_AGG(name,',') as players
from cte
where rn=1
group by year,num_gold_medals


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
with cte as(
select event,year,medal,dense_rank()over(partition by medal order by year) as rn
from athletes a join athlete_events e on a.id=e.athlete_id
where team='india' and medal!='NA')
select distinct * from cte
where rn=1
order by year

--6 find players who won gold medal in summer and winter olympics both.
select name
from athletes a join athlete_events e on a.id=e.athlete_id
where medal='gold'
group by name
having count(distinct season)=2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select name,year
from athletes a join athlete_events e on a.id=e.athlete_id
where medal!='NA'
group by name,year
having count(distinct medal)=3

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
with cte as(
select name,event,year
from athletes a join athlete_events e on a.id=e.athlete_id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)
select name,event
from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4

