--Рекурсия. От текущей даты на 3 месяца назад
WITH CTE AS (
	select CONVERT(DATE, GETDATE()) AS [DATE]
	UNION ALL
	select DATEADD(dd, -1, [DATE])
	from CTE
	where [DATE] >= DATEADD(mm, -3, GETDATE())
			)
SELECT CAST(REPLACE(CONVERT(varchar, ID_DATE, 112), '-', '') as int) AS ID_DATE
FROM CTE

