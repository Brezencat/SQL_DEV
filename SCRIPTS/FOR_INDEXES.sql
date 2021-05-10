--MSSQL Server

--список индексов
select * from sys.indexes;


--индексы, которые используются
SELECT    DB_NAME(us.database_id) AS [DB_NAME]
		, OBJECT_NAME(us.object_id) AS [TABLE_NAME]
		, i.name AS [INDEX_NAME]
		, i.type_desc AS [INDEX_TYPE]
		, us.user_seeks
		, us.user_scans
		, us.user_updates
		, us.last_user_seek
		, us.last_user_scan
		, us.last_user_update
		--, us.system_seek, us.system_scans, us.system_updates
		--, us.last_system_seek, us.last_system_scan, us.last_system_update
FROM sys.dm_db_index_usage_stats AS us
INNER JOIN sys.indexes AS i 
	ON us.index_id=i.index_id 
	AND us.object_id=i.object_id
WHERE database_id<>4 --исключил DB_ID('msdb')
;


--некластеризованные индексы, которые не используются
SELECT 	OBJECT_NAME(I.object_id) AS table_name
	, 	I.name AS index_name
	, 	I.index_id 
FROM sys.indexes AS I
--INNER JOIN sys.objects AS O ON O.object_id = I.object_id 
WHERE I.object_id > 100 
	AND I.type_desc = 'NONCLUSTERED' 
	AND I.index_id NOT IN (	SELECT S.index_id 
							FROM sys.dm_db_index_usage_stats AS S 
							WHERE S.object_id=I.object_id 
								AND I.index_id=S.index_id 
								AND database_id = DB_ID(DB_NAME())
						  ) --можно указать название конкретной базы в которой ищем индексы
ORDER BY I.object_id, I.name; 


--sys.dm_db_missing_index_details
--sys.dm_db_missing_index_columns
--sys.dm_db_missing_index_groups
--sys.dm_db_missing_index_group_stats

--Поиск недостающих индексов
SELECT 	MID.statement AS [Database.Schema.Table]
	,	MID.Equality_Columns
	,	MID.Inequality_Columns
	,	MID.Included_Columns
	,	(MIGS.User_Seeks + MIGS.Users_Scans) * MIGS.Avg_Total_User_Cost * MIGS.Avg_User_Impact AS total_cost --ожидаемое совокупное улучшение производительности запросов
	,	MIC.column_id AS ColumnId
	,	MIC.column_name AS ColumnName
	,	MIC.column_usage AS ColumnUsage
	,	MIGS.user_seeks AS UserSeeks
	,	MIGS.user_scans AS UserScans
	,	MIGS.last_user_seek AS LastUserSeek
	,	MIGS.avg_total_user_cost AS AvgQueryCostReduction
	,	MIGS.avg_user_impact AS AvgPctBenefit
FROM sys.dm_db_missing_index_details AS MID
CROSS APPLY sys.dm_db_missing_index_columns (MID.index_handle) AS MIC 
INNER JOIN sys.dm_db_missing_index_groups AS MIG 
	ON MIG.index_handle = MID.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats AS MIGS 
	ON MIG.index_group_handle = MIGS.group_handle 
ORDER BY MIGS.avg_user_impact DESC;


--Уровень индексов, строки и страницы. Фрагментация
--внешняя фрагментация < 30% - реорганизация, > 30% - перестроение индекса
SELECT 	index_type_desc
	, 	index_depth
	, 	index_level						--уровень индекса
	, 	page_count						--количество страниц на уровне
	, 	record_count					--количество строк
	, 	avg_page_space_used_in_percent 	--внутренняя фрагментация
	, 	avg_fragmentation_in_percent	--внешняя фрагментация
FROM sys.dm_db_index_physical_stats (DB_ID(DB_NAME()), OBJECT_ID(N'dbo.TestStructure'), NULL, NULL , 'DETAILED');


--Выделенная и фактически использованая память для таблицы + размер индекса
EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure', @updateusage = true;

