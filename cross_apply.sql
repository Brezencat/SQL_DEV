SELECT * 
INTO TAB
FROM (
	   SELECT 1 AS ID, 'A' AS NAME
	   UNION ALL         
	   SELECT 2, 'B'  
	   UNION ALL         
	   SELECT 3, 'C'  
     ) AS T
;
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



SELECT T.ID, T.NAME, J.PRNAME, J.PRC
FROM TAB AS T
     INNER JOIN (
                 SELECT TOP 2 ID, PRNAME, PRC
                 FROM PRICE AS P
                 ORDER BY PRC
                ) AS J ON T.ID=J.ID
go
SELECT T.ID, T.NAME, CA.PRNAME, CA.PRC
FROM TAB AS T
     CROSS APPLY (
                  SELECT TOP 2 ID, PRNAME, PRC
                  FROM PRICE AS P
                  WHERE T.ID=P.ID
                  ORDER BY PRC
                 ) AS CA
;