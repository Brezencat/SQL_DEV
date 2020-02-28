--разные планы выполнения, одинаковое время и количество чтений
USE master
GO

DROP DATABASE IF EXISTS TEST_EXISTS_NOT_EXISTS;

CREATE DATABASE TEST_EXISTS_NOT_EXISTS;

USE TEST_EXISTS_NOT_EXISTS
GO

SELECT [object_id]
	 , [name]
into ONE
FROM TSQL2012.sys.all_objects
;

SELECT [object_id]
	 , [name]
into TWO
FROM ONE
;


UPDATE ONE
SET [name] += '.abc'
WHERE [object_id] < 0
;


set statistics io, time on;

select * 
from ONE as o
inner join TWO as t on o.[object_id]=t.[object_id]
	and not exists  (select o.[name]
					 EXCEPT
					 select t.[name]
					)
;

select * 
from ONE as o
inner join TWO as t on o.[object_id]=t.[object_id]
	and exists  (select o.[name]
				 INTERSECT
				 select t.[name]
				)
;



--DROP TABLE ONE;
--DROP TABLE TWO;
--DROP DATABASE TEST_EXISTS_NOT_EXISTS;
