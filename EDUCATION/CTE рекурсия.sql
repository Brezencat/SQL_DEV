SELECT * 
INTO PRICE
FROM (
	   SELECT 1 AS ID, 'AA' AS PRNAME, 100 AS PRC
	   UNION ALL         
	   SELECT 1, 'AB', 50
	   UNION ALL         
	   SELECT 1, 'AC', 30
	   UNION ALL         
	   SELECT 2, 'BA', 200
	   UNION ALL         
	   SELECT 2, 'BB', 100
      UNION ALL         
	   SELECT 2, 'BC', 300
     ) AS P
;

WITH CTE 
     AS (
         select ID, PRNAME from PRICE where ID=1
         union all
         select ID+1, PRNAME from cte as c where c.id<=3
        ) 
SELECT * FROM CTE
;
--Результат: 
/*
1	AA
1	AB
1	AC
2	AC
3	AC
4	AC
2	AB
3	AB
4	AB
2	AA
3	AA
4	AA
*/



declare @t table (id int, num int)
insert @t
         select 1 id, 10 num 
         union all 
         select 1, 100
;
WITH CTE 
     AS (
         select id, num from @t 
         union all
         select id+1, num+1 from cte where id < 5
        )
SELECT * FROM CTE

--===============================================================================

declare @t1 table
	(id tinyint identity(1,1)
	,[name] char(1)
	,parent_id tinyint
	)
;

insert into @t1
	([name], parent_id)
values
	 ('a', 0)
	,('b', 1)
	,('c', 2)
	,('d', 3)
	,('e', 1)
	,('f', 2)
	,('g', 2)
;

--select *
--from @t1
--;


--select t.*, p.name
--from @t1 as t
--left join @t1 as p
--	on p.id = t.parent_id
--;

WITH CTE AS
(
	select  id
		,	[name]
		,	parent_id
		,	CAST('' as char(1)) as parent_name
		,	CAST(0 as int) as [level]
	from @t1
	where parent_id = 0
	UNION ALL
	select  t.id
		,	t.[name]
		,	t.parent_id
		,	c.[name]
		,	c.[level] + 1
	from CTE as c
	inner join @t1 as t
		on c.id = t.parent_id
)
select *
from CTE
;

--===============================================================================
