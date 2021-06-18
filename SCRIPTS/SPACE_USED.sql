--системная процедура
exec sp_spaceused --если запускать без параметров, то считает данные по всей БД


--общий объём занятого места объектами в БД

SELECT	DB_NAME() as DatabaseName
	,	SUM(a.total_pages) * 8 AS TotalSpaceKB
	,	SUM(a.used_pages) * 8 AS UsedSpaceKB
	,	(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
	,	CAST(SUM(a.total_pages) * 8 / 1024.00 as decimal(10, 2)) AS TotalSpaceMB
	,	CAST(SUM(a.used_pages) * 8 / 1024.00 as decimal(10, 2)) AS UsedSpaceMB
	,	CAST((SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024.00 as decimal(10, 2)) AS UnusedSpaceMB
FROM sys.all_objects AS o
INNER JOIN sys.schemas AS s 
	ON s.[schema_id] = o.[schema_id]
INNER JOIN sys.indexes AS i 
	ON i.[object_id] = o.[object_id]
INNER JOIN sys.partitions AS p 
	ON p.[object_id] = i.[object_id] 
	AND p.index_id = i.index_id
INNER JOIN sys.allocation_units AS a 
	ON a.container_id = p.[partition_id]
WHERE o.is_ms_shipped = 0 --убираем из выборки системные объекты (таблицы)
;


--список объектов и занятое ими место в KB и MB

SELECT	s.[name] + '.' + o.[name] AS ObjectName
	,	p.[rows] AS RowCounts
	,	SUM(a.total_pages) * 8 AS TotalSpaceKB
	,	CAST(ROUND(((SUM(a.total_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS TotalSpaceMB
	,	SUM(a.used_pages) * 8 AS UsedSpaceKB
	,	CAST(ROUND(((SUM(a.used_pages) * 8) / 1024.00), 2) AS NUMERIC(36, 2)) AS UsedSpaceMB
	,	(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
	,	CAST(ROUND(((SUM(a.total_pages) - SUM(a.used_pages)) * 8) / 1024.00, 2) AS NUMERIC(36, 2)) AS UnusedSpaceMB
FROM sys.all_objects AS o
INNER JOIN sys.schemas AS s 
	ON s.[schema_id] = o.[schema_id]
INNER JOIN sys.indexes AS i 
	ON i.[object_id] = o.[object_id]
INNER JOIN sys.partitions AS p 
	ON p.[object_id] = i.[object_id] 
	AND p.index_id = i.index_id
INNER JOIN sys.allocation_units AS a 
	ON a.container_id = p.[partition_id]
WHERE o.is_ms_shipped = 0 --убираем из выборки системные объекты (таблицы)
GROUP BY o.[name]
	,	 s.[name]
	,	 p.[rows]
ORDER BY o.[name]
;