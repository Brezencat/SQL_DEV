--==============================================================
--где используется объект

select s.name + '.' + o.name
	,	o.type_desc
	--,	sm.definition --текст процедуры
from sys.sql_modules as sm
inner join sys.all_objects as o
	on o.object_id = sm.object_id
inner join sys.schemas as s
	on s.schema_id = o.schema_id
where [definition] like '%objects%'
;

--==============================================================
--где используется колонка

select s.[name] + '.' + o.[name] AS table_name
	,	c.[name] AS column_name
	,	CASE 
			WHEN c.max_length = -1 THEN t.[name] + N'(MAX)' 
			WHEN t.[name] in ('bigint', 'int', 'smallint', 'tinyint', 'bit', 'uniqueidentifier', 'datetime') THEN t.[name] + N''
			WHEN t.[name] = 'nvarchar' THEN t.[name] + N'(' + CAST(c.max_length / 2 as nvarchar) + N')'
			WHEN t.[name] = 'decimal' THEN t.[name] + N'(' + CAST(c.[precision] as nvarchar) + N',' + CAST(c.[scale] as nvarchar) + N')'
			ELSE t.[name] + N'(' + ISNULL(CAST(c.max_length as nvarchar),'') + N')'
		END AS data_type
	,	IIF(c.is_nullable = 1, 'NULL', 'NOT NULL') AS nullable
	,	IIF(c.is_identity = 1, 'IDENTITY', '') AS [identity]
from sys.all_columns AS c
inner join sys.types AS t
	on t.user_type_id = c.user_type_id
inner join sys.objects AS o
	on o.object_id = c.object_id
inner join sys.schemas AS s
	on s.schema_id = o.schema_id
where c.[name] ='contract_number'
;

--поиск по индексам

select	i.[name]
	,	s.[name] + '.' + o.[name] as [parent_name]
	,	o.[type_desc]
	,	c.[name] as column_name
	,	t.[name] as data_type
	,	IIF(c.is_nullable = 1, 'NULL', 'NOT NULL') as nullable
	,	IIF(c.is_identity = 1, 'IDENTITY', '') as [identity] 
from sys.index_columns as ic
inner join sys.all_columns as c
	on c.object_id = ic.object_id
	and c.column_id = ic.column_id
inner join sys.types as t
	on t.user_type_id = c.user_type_id
inner join sys.indexes as i
	on i.index_id = ic.index_id
	and i.object_id = ic.object_id
inner join sys.objects as o
	on o.object_id = c.object_id
inner join sys.schemas as s
	on s.schema_id = o.schema_id
where c.[name] ='name'
;

--=================================================================
--Для процедуры поиска использования объекта по всем базам сервера
--=================================================================
DECLARE @search_obj_name varchar(255) = 'name' --название (или часть) объектра, по которому ищем зависимости
	,	@is_used bit = 0; --признак поиска объекта или использования объекта в коде. 0 - поиск объекта, 1 - поиск, где используется объект

DECLARE @i tinyint = 1 --число итераций для цикла
	,	@dbname varchar(255) --имя БД, в которой производится поиск
	,	@sql varchar(1000); --скрипт, который формируется для поиска

DROP TABLE IF EXISTS #list_db;

SELECT	ROW_NUMBER() over (order by database_id) as num
	,	[name]
into #list_db
FROM sys.databases 
WHERE [name] not in ('master', 'tempdb', 'model', 'msdb');

DROP TABLE IF EXISTS #OBJECT_USE;

CREATE TABLE #OBJECT_USE
	(DBNAME varchar(255)
	,OBJ_NAME varchar(511)
	,OBJ_TYPE varchar(255)
	);

WHILE @i < (select count(*) from #list_db)
BEGIN
	SELECT @dbname = [name]
	FROM #list_db
	WHERE num = @i;

	IF @is_used = 1
	BEGIN
		set @sql =
			'select	''' + @dbname + ''' as dbname
				,	s.name + ''.'' + o.name as obj_name
				,	o.type_desc
			from [' + @dbname + '].sys.sql_modules as sm
			inner join [' + @dbname + '].sys.all_objects as o
				on o.object_id = sm.object_id
			inner join [' + @dbname + '].sys.schemas as s
				on s.schema_id = o.schema_id
			where [definition] like ''%' + @search_obj_name + '%''';
	END
	ELSE IF @is_used = 0
	BEGIN
		set @sql =
			'select	''' + @dbname + ''' as dbname
				,	s.name + ''.'' + o.name as obj_name
				,	o.type_desc
			from [' + @dbname + '].sys.all_objects as o
			inner join [' + @dbname + '].sys.schemas as s
				on s.schema_id = o.schema_id
			where o.[name] like ''%' + @search_obj_name + '%''';
	END
	ELSE
		BREAK;

	INSERT INTO #OBJECT_USE
		(DBNAME, OBJ_NAME, OBJ_TYPE)
	EXEC (@sql);

	SET @i += 1;
END

SELECT DBNAME, OBJ_NAME, OBJ_TYPE FROM #OBJECT_USE;

--==============================================================

