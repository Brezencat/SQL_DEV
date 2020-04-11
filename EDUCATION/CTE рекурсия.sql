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
     AS (         select ID, PRNAME from PRICE where ID=1         union all         select ID+1, PRNAME from cte as c where c.id<=3
        ) SELECT * FROM CTE
;
--Результат: 
/*
1	AA1	AB1	AC2	AC3	AC4	AC2	AB3	AB4	AB2	AA3	AA4	AA
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