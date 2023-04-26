--разные планы выполнения, одинаковое время и количество чтений
--создадим отдельную БД
USE master
GO

DROP DATABASE IF EXISTS TEST_EXISTS_NOT_EXISTS;
GO

CREATE DATABASE TEST_EXISTS_NOT_EXISTS;
GO

USE TEST_EXISTS_NOT_EXISTS
GO

--Наполним таблицы данными объектов из БД AdventureWorks2017
SELECT 	 [object_id]
		,[name]
		,principal_id
		,[schema_id]
		,parent_object_id
		,[type]
		,[type_desc]
		,create_date
		,modify_date
		,is_ms_shipped
		,is_published
		,is_schema_published
into ONE
FROM AdventureWorks2017.sys.all_objects
;

SELECT 	 [object_id]
		,[name]
		,principal_id
		,[schema_id]
		,parent_object_id
		,[type]
		,[type_desc]
		,create_date
		,modify_date
		,is_ms_shipped
		,is_published
		,is_schema_published
into TWO
FROM ONE
;

--Поменяем часть данных в таблице-источнике ONE
UPDATE ONE
SET modify_date = getdate()
WHERE [object_id] % 100 > 0
;

UPDATE ONE
SET is_ms_shipped = null
WHERE [object_id] % 100 > 0
	and [type] = 'D'
;


set statistics io, time on; --включаем статистику

select * 
from ONE as o
inner join TWO as t on o.[object_id]=t.[object_id]
	and not exists  (select o.[name],o.principal_id,o.[schema_id],o.parent_object_id,o.[type],o.[type_desc],o.create_date,o.modify_date,o.is_ms_shipped,o.is_published,o.is_schema_published
					 EXCEPT
					 select t.[name],t.principal_id,t.[schema_id],t.parent_object_id,t.[type],t.[type_desc],t.create_date,t.modify_date,t.is_ms_shipped,t.is_published,t.is_schema_published
					)
;

select * 
from ONE as o
inner join TWO as t on o.[object_id]=t.[object_id]
	and exists  (select o.[name],o.principal_id,o.[schema_id],o.parent_object_id,o.[type],o.[type_desc],o.create_date,o.modify_date,o.is_ms_shipped,o.is_published,o.is_schema_published
				 INTERSECT
				 select t.[name],t.principal_id,t.[schema_id],t.parent_object_id,t.[type],t.[type_desc],t.create_date,t.modify_date,t.is_ms_shipped,t.is_published,t.is_schema_published
				)
;


set statistics io, time off; --выключаем статистику

DROP TABLE IF EXISTS ONE; --удаляем таблицы
DROP TABLE IF EXISTS TWO;
GO

USE master --удаляем базу
GO
--ALTER DATABASE TEST_EXISTS_NOT_EXISTS SET SINGLE_USER;
DROP DATABASE TEST_EXISTS_NOT_EXISTS;
GO



--=======================================================
--доп.примеры
--есть описание в .md --!сделать это описание
--=======================================================

--create temp teble for test

DROP TABLE IF EXISTS #PHONE;

	CREATE TABLE #PHONE
		(id_name int
		,phone varchar(25)
		);

DROP TABLE IF EXISTS #NAME;

	CREATE TABLE #NAME
		(id_name int
		,name varchar(128)
		);

--fill in temp tables for test

INSERT INTO #PHONE
	(id_name, phone)
VALUES (1, 'xxx-xxx-xx-xx')
	,	(2, 'eee-eee-ee-ee')
	,	(3, '');

INSERT INTO #NAME
	(id_name, name)
VALUES (1, 'AAA')
	,	(2, 'BBBB')
	,	(3, 'CCCCC');



select p.*
from #PHONE as p
where NOT EXISTS (	select n.*
				from #NAME as n
				where n.name = 'AAA'
					and n.id_name = p.id_name)
;

select p.*
from #PHONE as p
inner join #NAME as n
	on n.id_name = p.id_name
	and n.name <> 'AAA';
;

select p.*
from #PHONE as p
left join #NAME as n
	on n.id_name = p.id_name
	and n.name = 'AAA'
where n.id_name is null
;