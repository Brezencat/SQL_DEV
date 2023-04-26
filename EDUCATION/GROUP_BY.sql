


SELECT firstname + middlename AS FULLNAME
	,	division_id
	,	YEAR(dt_registration) AS YEAR_REGISTRATION
	, ID
FROM dtln.dbo.worker
WHERE [actual] = 1
;

SELECT  division_id
	,	count(*) AS cn_name
	,	count(division_id) AS cn_division
FROM dtln.dbo.worker
WHERE [actual] = 1
GROUP BY division_id
union all
SELECT null
	,	count(*) AS cn_name
	,	null
FROM dtln.dbo.worker
WHERE [actual] = 1


SELECT  division_id
	,	YEAR(dt_registration) AS YEAR_REGISTRATION
	,	count(*) AS cn_name
FROM dtln.dbo.worker
WHERE [actual] = 1
GROUP BY division_id
	,	 YEAR(dt_registration)
;

SELECT  division_id
	,	YEAR(dt_registration) AS YEAR_REGISTRATION
	,	count(*) AS cn_name
FROM dtln.dbo.worker
WHERE [actual] = 1
GROUP BY 
ROLLUP (division_id
	,	 YEAR(dt_registration)
	)
;

SELECT  division_id
	,	YEAR(dt_registration) AS YEAR_REGISTRATION
	,	count(*) AS cn_name
FROM dtln.dbo.worker
WHERE [actual] = 1
GROUP BY 
ROLLUP (YEAR(dt_registration)
	,	division_id
	)
;


SELECT  division_id
	,	YEAR(dt_registration) AS YEAR_REGISTRATION
	,	count(*) AS cn_name
FROM dtln.dbo.worker
WHERE [actual] = 1
GROUP BY 
CUBE (YEAR(dt_registration)
	,	division_id
	)
;


SELECT  division_id
	,	YEAR(dt_registration) AS YEAR_REGISTRATION
	,	count(*) AS cn_name
FROM dtln.dbo.worker
WHERE [actual] = 1
GROUP BY 
GROUPING SETS (YEAR(dt_registration)
	,	division_id
	)
;




SELECT  division_id
	,	YEAR(dt_registration) AS YEAR_REGISTRATION
	,	count(*) AS cn_name
	,	GROUPING (YEAR(dt_registration)) AS GROUP_AS_YEAR
	,	GROUPING (division_id) AS GROUP_AS_DIVISION
FROM dtln.dbo.worker
WHERE [actual] = 1
GROUP BY 
ROLLUP (division_id
	,	 YEAR(dt_registration)
	)
;

SELECT  CASE WHEN 1 in (GROUPING (division)) and 0 in (GROUPING (YEAR(dt_registration)))
			 THEN 'Промежуточный итог'
			 ELSE division
		END AS division
	,	CASE WHEN 1 in (GROUPING (YEAR(dt_registration))) and 0 in (GROUPING (division)) 
			 THEN 'Промежуточный итог'
			 ELSE CAST(YEAR(dt_registration) as varchar(5))
		END AS YEAR_REGISTRATION
	,	count(*) AS cn_name
FROM dtln.dbo.worker as w
inner join dbo.division as d
	on d.id = w.division_id
WHERE [actual] = 1
GROUP BY 
CUBE (division
	, YEAR(dt_registration)
	)
;
