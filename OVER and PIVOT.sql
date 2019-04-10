SELECT * ,LAG (TIME,1,'00:00') OVER (PARTITION BY STAGE ORDER BY TIME,ID) AS PREV_TIME_ST ,LAG (TIME,1,'00:00') OVER (PARTITION BY NAME ORDER BY TIME) AS PREV_TIME_NM ,FIRST_VALUE ([TIME]) OVER (PARTITION BY STAGE ORDER BY TIME ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS PREV_TIME_FV ,FIRST_VALUE ([TIME]) OVER (PARTITION BY STAGE ORDER BY TIME) AS BEST_TIME ,ROW_NUMBER() OVER (PARTITION BY STAGE ORDER BY NAME) AS RN ,RANK() OVER (ORDER BY NAME) AS RANK ,DENSE_RANK () OVER (ORDER BY NAME) AS DR ,NTILE(3) OVER (ORDER BY NAME) AS NTILEFROM RUNORDER BY STAGE, NAME


--PIVOT по этапам
WITH CTE AS (			select NAME, STAGE, TIME			from RUN			)SELECT NAME, [1],[2],[3]FROM CTEPIVOT (MIN(TIME)FOR STAGE IN ([1],[2],[3])) AS PORDER BY NAME--вариант PIVOT по бегунам
WITH CTE AS (			select NAME, STAGE, TIME			from RUN			)SELECT STAGE, run1,run2,run3,run4,run5FROM CTEPIVOT (MIN(TIME)FOR NAME IN (run1,run2,run3,run4,run5)) AS P


select *,LAG (TIME,1,'00:00:00') OVER (PARTITION BY COMAND ORDER BY TIME) as PREV_TIME,DATEDIFF(s, TIME, (LAG (TIME,1,'00:00:00') OVER (PARTITION BY COMAND ORDER BY TIME))) as SALDO,DATEDIFF(s, TIME, (LAG (TIME,1,'00:00:00') OVER (PARTITION BY COMAND ORDER BY TIME)))/60 as SALDO60,DATEDIFF(mi, TIME, (LAG (TIME,1,'00:00:00') OVER (PARTITION BY COMAND ORDER BY TIME))) as SALDOMI,FIRST_VALUE (TIME) OVER (PARTITION BY COMAND ORDER BY TIME) as BEST_TIME,LAST_VALUE (TIME) OVER (ORDER BY COMAND ) as FAIL_TIMEfrom DAKAR

