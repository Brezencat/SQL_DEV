--MSSQL Sarver

--посмотреть, какая статистика есть по таблице
SELECT  OBJECT_NAME(object_id) AS table_name,
		name AS statistics_name, 
		auto_created,
		STATS_DATE(object_id, stats_id) as UPDATE_DATE --дата обновления статистики
FROM sys.stats
WHERE object_id = OBJECT_ID(N'Sales.Orders', N'U');


--курсор удаляет автоматическую статистику, которая не на ключе индекса
DECLARE @stat_name nvarchar(128),
		@sql nvarchar(1000),
		@table_name nvarchar(512) = 'Sales.Orders';

DECLARE acs_cursor CURSOR FOR
	SELECT name AS statstics_name
	FROM sys.stats
	WHERE object_id = OBJECT_ID(@table_name)
		AND auto_created = 1;

OPEN acs_cursor
	FETCH NEXT FROM acs_cursor INTO @stat_name
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @sql = N'DROP STATISTICS ' + @table_name + '.' + @stat_name;

		EXEC(@sql);

		FETCH NEXT FROM acs_cursor INTO @stat_name
	END;
CLOSE acs_cursor;
DEALLOCATE acs_cursor;


