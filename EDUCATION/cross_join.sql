--Example used cross join

--==============================================================================
--it's source data
--==============================================================================

SELECT *
FROM (
		values('client-1', 10, 'client-777')
) AS carry([OUT], AMMOUNT, [IN]);

--OUT		AMMOUNT	IN
--client-1	10		client-777

--==============================================================================
--adding cross join
--==============================================================================

SELECT *
FROM (
		values('client-1', 10, 'client-777')
) AS carry([OUT], AMMOUNT, [IN])
CROSS JOIN (
			select 1 
			union all 
			select -1
) AS n(c);

--OUT		AMMOUNT	IN			c
--client-1	10		client-777	1
--client-1	10		client-777	-1

--==============================================================================
--total result
--==============================================================================

SELECT	CASE n.c 
			WHEN -1 THEN [OUT]
			WHEN 1 THEN [IN]
			ELSE NULL
		END AS [OUT]
	, AMMOUNT * n.c AS AMMOUNT
	, CASE n.c 
			WHEN 1 THEN [OUT]
			WHEN -1 THEN [IN]
			ELSE NULL
		END AS [IN]
FROM (
		values('client-1', 10, 'client-777')
) AS carry([OUT], AMMOUNT, [IN])
CROSS JOIN (
			select 1 
			union all 
			select -1
) AS n(c);

--OUT			AMMOUNT		IN
--client-777	10			client-1
--client-1		-10			client-777

--==============================================================================