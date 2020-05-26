CREATE PROC dbo.LOAD_XEVENT_XML_VIEW
--declare  
		 @DATE datetime2 = null --отбор записей по большему (или меньшему) периоду времени, формат datetime2. Если указана дата, то отбор записей будет производиться от неё до текущего момента.
		,@XEVENT_NAME varchar(255) = null ---запуск по конкретному эвенту. Если указано название XEvent, то процедура будет работать только по указанному эвенту.
		,@FILE_DIRECTORY varchar(255) = 'C:\Users\MSSQLSERVER\Documents\XEVENT_LOG' --Путь к месту хранения файла лога эвента. Используется для передачи в процедуру загрузки буферной таблицы LOAD_XEVENT_XML_BUFFER
		,@view bit = 0 --Режим работы процедуры: 0 - запись в постоянную таблицу, 1 - возврат набора данных

AS

BEGIN TRY
	SET XACT_ABORT ON;
	IF @view = 0
		SET NOCOUNT ON;

	DECLARE	@ROWS int; --для логирования количества строк

--если дата не указана, то отбираем данные на дату Т-1 от UTC+0 (сервера)
	IF @DATE is null
	BEGIN
		select @DATE = CAST(CONVERT(varchar(8), DATEADD(dd, -5, getutcdate()), 112) as datetime2)
	END;

		IF @view = 1
			print 'Дата отбора данных ' + CONVERT(varchar(19), @DATE, 121);


	--набираем из буферной таблицы нужные нам данные. Если указано название эвента, то собираем данные только по нему.
	--если режим для просмотра данных, то запускается процедура чтения файла лога эвента без сохранения данных.
	DECLARE @sql nvarchar(4000) = '';

		DROP TABLE IF EXISTS #XML_BUFFER;
	
		CREATE TABLE #XML_BUFFER
			( ID			int
			 ,XEVENT_NAME	varchar(255)
			 ,[EVENT]		varchar(255)
			 ,UTCDATE		datetime2
			 ,[VALUE]		xml
			);

	IF @view = 0
	BEGIN
		SET @sql = 'SELECT	 ID
							,XEVENT_NAME
							,[EVENT]
							,UTCDATE
							,[VALUE]
					FROM dbo.XEVENT_XML_BUFFER
					WHERE UTCDATE >= @DATEFROM';

		IF @XEVENT_NAME is not null
		BEGIN
			SET @sql = @sql + ' and XEVENT_NAME = ' + '''' + @XEVENT_NAME + '''';
		END
		ELSE
		BEGIN
			INSERT INTO #XML_BUFFER
				( ID
				 ,XEVENT_NAME
				 ,[EVENT]
				 ,UTCDATE
				 ,[VALUE]
				)
			EXEC sp_executesql	 @sql
								,N'@DATEFROM datetime2'
								,@DATE;
		END;
	END
	ELSE
	BEGIN
		exec dbo.LOAD_XEVENT_XML_BUFFER 
			 @DATE = @DATE
			,@XEVENT_NAME = @XEVENT_NAME 
			,@FILE_DIRECTORY = @FILE_DIRECTORY
			,@view = 1 --в этом режиме процедура записывает данные во времянку
	END;


	DROP TABLE IF EXISTS #DATA;

	CREATE TABLE #DATA
		( XEVENT_NAME 	varchar(255)	--имя XEvent
		 ,[EVENT]		varchar(255) 	--имя собоытия из XML
		 ,UTCDATE 		datetime2 		--дата и время проишествия UTC +0
		 ,SERVER_NAME 	varchar(255)	--client_hostname
		 ,DATABASE_ID 	tinyint 
		 ,[APP_NAME] 	varchar(255) 	--client_app_name
		 ,USERNAME 		varchar(255)	--nt_username или usernsme
		 ,SESSION_ID 	smallint		--SPID
		 ,SQL_TEXT 		varchar(4000) 	--тексты запросов
		 ,[VALUE] 		varchar(4000) 	--разные параметры
		);

	--дробим xml, для события deadlock отдельно, так как разбираем внутренний xml-отчёт
	WITH CTE AS
		(
			select   b.XEVENT_NAME
					,b.[EVENT]
					,b.UTCDATE
					,p.v.value ('(@hostname)','varchar(255)') AS SERVER_NAME
					,p.v.value ('(@currentdb)','tinyint') AS DATABASE_ID
					,p.v.value ('(@clientapp)','varchar(255)') AS [APP_NAME]
					,p.v.value ('(@loginname)','varchar(255)') AS USERNAME
					,p.v.value ('(@spid)','int') AS SESSION_ID
					,p.v.value ('(inputbuf)[1]','varchar(4000)') AS SQL_TEXT
					,SUBSTRING(p.v.value ('(@waitresource)','varchar(255)')
								, 1
								, CHARINDEX(':',p.v.value ('(@waitresource)','varchar(255)'))-1) AS RESOURCE_LOCK --после ":" указывается какой-то ID
					,d.v.value ('(victim-list/victimProcess/@id)[1]','varchar(255)') AS dead_process_id
					,p.v.value ('(@id)[1]','varchar(255)') AS process_id
					--,p.v.value ('(executionStack/frame/@sqlhandle)[1]','varchar(255)') AS PLAN_HANDLE
			from #XML_BUFFER AS b
			cross apply b.value.nodes('event/data/value/deadlock') AS d(v) --дробим xml два раза, так как SQL Server плохо смотрит назад (на уровень выше)
			cross apply d.v.nodes('process-list/process') AS p(v) --дробление от уже раздробленной XML
			where XEVENT_NAME = 'DEADLOCK_MONITOR'
				and [EVENT] = 'xml_deadlock_report' --событие с xml отчётом
		)
	INSERT INTO #DATA
		( XEVENT_NAME
		 ,[EVENT]
		 ,UTCDATE
		 ,SERVER_NAME
		 ,DATABASE_ID
		 ,[APP_NAME]
		 ,USERNAME
		 ,SESSION_ID
		 ,SQL_TEXT
		 ,[VALUE]
		)
	SELECT	 XEVENT_NAME
			,[EVENT]
			,UTCDATE
			,SERVER_NAME
			,DATABASE_ID
			,[APP_NAME]
			,USERNAME
			,SESSION_ID
			,SQL_TEXT 
			,IIF(dead_process_id = process_id, 'KILL, RESOURCE_LOCK: ', 'RESOURCE_LOCK: ') 
				+ RESOURCE_LOCK AS [VALUE] --находим процесс, который был выбран в качестве жертвы при взаимной блокировке
	FROM CTE
		
	UNION ALL
	
	SELECT   XEVENT_NAME
			,[EVENT]
			,UTCDATE
			,[VALUE].value('(event/action[@name="client_hostname"]/value)[1]','varchar(255)') as SERVER_NAME
			,ISNULL([VALUE].value('(event/action[@name="database_id"]/value)[1]','tinyint'),
					[VALUE].value('(event/data[@name="database_id"]/value)[1]','tinyint')) as DATABASE_ID --у некоторых событий база отражается под разными родительскими тегами
			,[VALUE].value('(event/action[@name="client_app_name"]/value)[1]','varchar(255)') as [APP_NAME]
			,ISNULL([VALUE].value('(event/action[@name="nt_username"]/value)[1]','varchar(255)'),
					[VALUE].value('(event/action[@name="username"]/value)[1]','varchar(255)')) as USERNAME
			,[VALUE].value('(event/action[@name="session_id"]/value)[1]','smallint') as SESSION_ID
			,[VALUE].value('(event/action[@name="sql_text"]/value)[1]','varchar(4000)') as SQL_TEXT
			,NULL as [VALUE]
	FROM #XML_BUFFER
	WHERE XEVENT_NAME <> 'DEADLOCK_MONITOR';

	set @ROWS = @@ROWCOUNT;

	IF @view = 1
		print 'Сколько новых данных = ' + CAST(@ROWS as varchar(10));

	--отбираем только новые данные, которые ещё не сохранены
	SELECT   d.XEVENT_NAME
			,d.[EVENT]
			,d.UTCDATE
			,d.SERVER_NAME
			,d.DATABASE_ID
			,d.[APP_NAME]
			,d.USERNAME
			,d.SESSION_ID
			,d.SQL_TEXT
			,d.[VALUE]
	into #RESULT
	FROM #DATA as d
	LEFT JOIN dbo.XEVENT_XML_VIEW as l on not exists (select d.XEVENT_NAME, d.[EVENT], d.UTCDATE, d.SERVER_NAME, d.DATABASE_ID, d.[APP_NAME], d.USERNAME, d.SESSION_ID, d.[VALUE]
												 except
												 select l.XEVENT_NAME, l.[EVENT], l.UTCDATE, l.SERVER_NAME, l.DATABASE_ID, l.[APP_NAME], l.USERNAME, l.SESSION_ID, d.[VALUE])
	WHERE l.XEVENT_NAME is null;

	set @ROWS = @@ROWCOUNT;

	IF @view = 1
		print 'Сколько данных в итоге (#RESULT) = ' + CAST(@ROWS as varchar(10));

	DROP TABLE IF EXISTS #DATA;

	--в зависимости от режима, либо вставляем данные в постоянную таблицу и удаляем xml из буфера, либо возвращаем набор данных
	IF @view = 0
	BEGIN
		BEGIN TRAN
		
			INSERT INTO dbo.XEVENT_XML_VIEW
				( XEVENT_NAME
				 ,[EVENT]
				 ,UTCDATE
				 ,SERVER_NAME
				 ,DATABASE_ID
				 ,[APP_NAME]
				 ,USERNAME
				 ,SESSION_ID
				 ,SQL_TEXT
				 ,[VALUE]
				)
			SELECT   XEVENT_NAME
					,[EVENT]
					,UTCDATE
					,SERVER_NAME
					,DATABASE_ID
					,[APP_NAME]
					,USERNAME
					,SESSION_ID
					,SQL_TEXT
					,[VALUE]
			FROM #RESULT;

			DELETE b
			FROM dbo.XEVENT_XML_BUFFER AS b
			INNER JOIN #XML_BUFFER AS t 
				ON b.ID = t.ID;

		COMMIT;
	END
	ELSE
	BEGIN
		SELECT   XEVENT_NAME
				,[EVENT]
				,UTCDATE
				,SERVER_NAME
				,DATABASE_ID
				,[APP_NAME]
				,USERNAME
				,SESSION_ID
				,SQL_TEXT
				,[VALUE]
		FROM #RESULT;
	END;

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK;
	THROW
	--exec UTILITY.dbo.Catch
END CATCH
;