--Описание объектов и колонок БД с помощью EXTENDED PROPERTIES
--зависит от базы

--выводит только описание столбцов
select	s.[name] + '.' + o.[name] as TABLE_NAME
	,	c.[name] as COLUMN_NAME
	,	t.[name] + 
		CASE 
			WHEN t.[name] in ('bigint', 'int', 'smallint', 'tinyint', 'bit') THEN ''
			WHEN c.max_length = -1 THEN '(MAX)'
			ELSE '(' + CAST(c.max_length as varchar(5)) + ')'
		END as DATA_TYPE
	,	ep.[value] as [DESCRIPTION]
from sys.schemas as s
inner join sys.objects as o
	on o.schema_id = s.schema_id
inner join sys.all_columns as c
	on c.object_id = o.object_id
inner join sys.types as t
	on t.user_type_id = c.user_type_id
inner join sys.extended_properties as ep
	on o.object_id = ep.major_id
	and c.column_id = ep.minor_id
where ep.[name] = 'MS_Description'
	--and o.[type] <> 'S' --исключаем из выборки SYSTEM_TABLE
	and s.[name] <> 'sys' --исключаем системаные объекты со схемой sys
order by o.[name], c.column_id
;


--добавление описания
EXEC sp_addextendedproperty @name = N'MS_Description', --здесь также можно указывать своё значение
	@value = N'<Описание>',
    @level0type = N'SCHEMA', --TRIGGER не табличный
    @level0name = N'<название схемы>', --dbo
    @level1type = N'TABLE', --VIEW, PROCEDURE, DEFAULT, FUNCTION, 
    @level1name = N'<название таблицы>',
    @level2type = N'COLUMN', --CONSTRAINT, INDEX, TRIGGER 
    @level2name = N'<название столбца>'

--Скрипт автоматического формирования запроса на добавление описания по конкретному объекту
--нужно добавить исключение или обновление по уже существующему описанию
select  s.name AS level0name
	,	o.name AS level1name
	,	CASE o.type
			WHEN 'U' THEN 'TABLE'
			WHEN 'V' THEN 'VIEW'
			WHEN 'P' THEN 'PROCEDURE'
			WHEN 'D' THEN 'DEFAULT'
			WHEN 'TF' THEN 'FUNCTION'
			WHEN 'FN' THEN 'FUNCTION'
			ELSE 'N/A'
		END AS level1type
	,	CASE o.type
			WHEN 'D' THEN 'CONSTRAINT'
			WHEN 'PK' THEN 'CONSTRAINT'
			ELSE 'COLUMN'
		END AS level2type
	,	c.name AS level2name
	,	'
			EXEC sp_addextendedproperty @name = N''MS_Description'',
				@value = N''<...>'',
				@level0type = N''SCHEMA'',
				@level0name = N''' + s.name + ''',
				@level1type = N''' +	CASE o.type
										WHEN 'U' THEN 'TABLE'
										WHEN 'V' THEN 'VIEW'
										WHEN 'P' THEN 'PROCEDURE'
										WHEN 'D' THEN 'DEFAULT'
										WHEN 'TF' THEN 'FUNCTION'
										WHEN 'FN' THEN 'FUNCTION'
										ELSE 'N/A'
									END + ''', 
				@level1name = N''' + o.name + ''',
				@level2type = N''' +	CASE o.type
										WHEN 'D' THEN 'CONSTRAINT'
										WHEN 'PK' THEN 'CONSTRAINT'
										ELSE 'COLUMN'
									END + ''',
				@level2name = N''' + c.name + '''
		' AS ADD_EXTENDED_PROPERTY
from sys.objects as o
inner join sys.schemas as s
	on s.schema_id = o.schema_id
inner join sys.all_columns as c
	on c.object_id = o.object_id
where s.name <> 'sys' --исключаем системаные объекты
	and o.object_id = OBJECT_ID('dbo.TABLE_NAME')
;


--более расширенный запрос, который выводит описание не только столбцов, но и самого объекта
;WITH DESCR AS (
	SELECT	c.[name] AS TABLE_NAME
		,	c.column_id
		,	c.[object_id]
		,	t.[name] as COLUMN_NAME			
		,	CASE 
				WHEN c.max_length = -1 THEN 'MAX' 
				WHEN t.[name] in ('bigint', 'int', 'smallint', 'tinyint', 'bit', 'uniqueidentifier', 'datetime') THEN ''
				ELSE ISNULL(CAST(c.max_length as nvarchar),'') 
			END AS [LENGTH]
		,	IIF(c.is_nullable = 0, 'not null', 'null') AS NULLABLE
		,	ISNULL(ep.[name], '') AS DESCRIPTION_TYPE
		,	ISNULL(ep.[value], '') AS [DESCRIPTION]
	FROM sys.schemas AS s
	INNER JOIN sys.objects AS o
		ON o.[schema_id] = s.[schema_id]
		AND s.[name] <> 'sys'
	INNER JOIN sys.columns AS c 
		ON c.[object_id] = o.[object_id]
	INNER JOIN sys.types AS t
		ON t.system_type_id = c.system_type_id
		AND t.user_type_id = c.user_type_id
	LEFT JOIN sys.extended_properties AS ep 
		ON ep.major_id = o.[object_id] 
		AND ep.minor_id = c.column_id
	
	UNION ALL

	SELECT	QUOTENAME(s.[name]) + '.' + QUOTENAME(o.[name])
		,	0
		,	o.[object_id]
		,	''
		,	''
		,	''
		,	ISNULL(ep.[name], '')
		,	ISNULL(ep.[value], '')
	FROM	sys.schemas AS s
	INNER JOIN sys.objects AS o
		ON o.[schema_id] = s.[schema_id]
		AND s.[name] <> 'sys'						
	LEFT JOIN sys.extended_properties AS ep 
		ON ep.major_id = o.[object_id] 
		AND ep.minor_id = 0
)
SELECT	TABLE_NAME
	,	IIF([LENGTH] <> '', COLUMN_NAME + '(' + [LENGTH] + ')', COLUMN_NAME) as DATA_TYPE
	,	NULLABLE
	,	DESCRIPTION_TYPE
	,	[DESCRIPTION]
FROM DESCR
ORDER BY object_id, column_id
;
