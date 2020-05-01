CREATE PROC dbo.XEVENT_LOG_VIEWER
--declare 
	 @DATE varchar(11) = null --строго в формате ГГГГ-ММ-ДД
	,@XEVENT_NAME varchar(255) = null

AS

BEGIN TRY
	SET XACT_ABORT ON;

	SET @DATE = @DATE + '%';

	IF @DATE is null
	BEGIN
		SELECT @DATE = CONVERT(varchar(10), DATEADD(dd, -1, getdate()), 120) + '%' --не работает выборка из файла по больше-меньше, только с лайком
	END;

	DROP TABLE IF exists #XEVENT_LIST;

	CREATE TABLE #XEVENT_LIST
		( ID tinyint
		 ,XEVENT_NAME varchar(255)
		 ,FILE_PATH varchar(255)
		);

	IF @XEVENT_NAME is null
	BEGIN
		INSERT INTO #XEVENT_LIST (ID, XEVENT_NAME, FILE_PATH)
		SELECT ROW_NUMBER() over (order by ID) AS ID, XEVENT_NAME, FILE_PATH
		FROM dbo.XEVENT_LIST
		WHERE IS_ACTIVE = 1;
	END
	ELSE
	BEGIN
		INSERT INTO #XEVENT_LIST (ID, XEVENT_NAME, FILE_PATH)
		SELECT CAST(1 as tinyint) AS ID, XEVENT_NAME, FILE_PATH
		FROM dbo.XEVENT_LIST
		WHERE XEVENT_NAME = @XEVENT_NAME;
	END

	DROP TABLE IF exists #FILE_DATA;

	CREATE TABLE #FILE_DATA
		( XEVENT_NAME 	varchar(255)	NOT NULL --имя XEvent
		 ,[EVENT]		varchar(255) 	NOT NULL --имя собоытия из XML
		 ,[TIMESTAMP] 	datetime2 		NOT NULL --дата и время проишествия
		 ,SERVER_NAME 	varchar(255) 	NOT NULL --client_hostname
		 ,DATABASE_ID 	tinyint 		NOT NULL --smallint ???
		 ,[APP_NAME] 	varchar(255) 	NOT NULL --client_app_name
		 ,USERNAME 		varchar(255) 	NOT NULL 
		 ,[SESSION_ID] 	smallint 		NOT NULL
		 ,SQL_TEXT 		varchar(4000) 	NULL --тексты запросов. exec процедуры

		 ,session_id_query		int				null --с какими сессиями взаимодействие для lock_deadlock_chain
		 ,database_id_query		tinyint			null --в каких базах эти сессии для lock_deadlock_chain
		 ,deadlock_id			int				null --нужен для группировки событий
		 ,transaction_id_query	int				null
		 ,resource_type			varchar(10)		null --какой тип блокировки наложен
		-- ,DEADLOCK_GRAF			varchar(MAX)	null
		 ,[VALUE] 		XML 			NULL --разные параметры
		)
	;
	DECLARE  @count tinyint --количество циклов
			,@i tinyint --количество итераций
			,@SEANS_NAME varchar(255)
			,@FILE_PATH varchar(255);

	SELECT @count = count(ID) from #XEVENT_LIST;
	SET @i = 1;

	WHILE @i <= @count
	BEGIN

		SELECT @SEANS_NAME = XEVENT_NAME
			 , @FILE_PATH = FILE_PATH
		FROM #XEVENT_LIST 
		WHERE ID = @i;

		WITH CTE AS
		(
			SELECT CAST(event_data as XML) AS [DATA]
			FROM sys.fn_xe_file_target_read_file (@FILE_PATH, null, null, null)
			WHERE timestamp_utc like @DATE
		)
		INSERT INTO #FILE_DATA
			( XEVENT_NAME
			 ,[EVENT]
			 ,[TIMESTAMP]
			 ,SERVER_NAME
			 ,DATABASE_ID
			 ,[APP_NAME]
			 ,USERNAME
			 ,[SESSION_ID]
			 ,SQL_TEXT		
			 ,session_id_query		
			 ,database_id_query		
			 ,deadlock_id
			 ,transaction_id_query
			 ,resource_type			
			 --,DEADLOCK_GRAF
			 ,[VALUE]
			)
		SELECT  @SEANS_NAME as XEVENT_NAME
				,data.value('(event/@name)[1]','varchar(255)') AS [EVENT]
				,data.value('(event/@timestamp)[1]','datetime2') AS [TIMESTAMP]
				,data.value('(event/action[@name="client_hostname"]/value)[1]','varchar(255)') AS SERVER_NAME
				,ISNULL(data.value('(event/action[@name="database_id"]/value)[1]','tinyint'),
						data.value('(event/data[@name="database_id"]/value)[1]','tinyint')) AS DATABASE_ID --у дедлока база запроса использутся, а не события
				,data.value('(event/action[@name="client_app_name"]/value)[1]','varchar(255)') AS [APP_NAME]
				,data.value('(event/action[@name="username"]/value)[1]','varchar(255)') AS USERNAME
				,data.value('(event/action[@name="session_id"]/value)[1]','smallint') AS SESSION_ID
				,data.value('(event/action[@name="sql_text"]/value)[1]','varchar(4000)') AS SQL_TEXT
			
				,data.value('(event/data[@name="session_id"]/value)[1]','int') AS session_id_query --с какими сессиями взаимодействие для lock_deadlock_chain
				,data.value('(event/data[@name="database_id"]/value)[1]','tinyint') AS database_id_query --в каких базах эти сессии для lock_deadlock_chain
				,data.value('(event/data[@name="deadlock_id"]/value)[1]','int') AS deadlock_id
				,data.value('(event/data[@name="transaction_id"]/value)[1]','int') AS transaction_id_query
				,data.value('(event/data[@name="resource_type"]/text)[1]','varchar(10)') AS resource_type --какой тип блокировки наложен
				--,data.value('(event/data[@name="xml_report"]/value)[1]','varchar(MAX)') as DEADLOCK_GRAF--это из xml_deadlock_report--вообе надо обрабатывать иначе
				,CASE WHEN data.value('(event/@name)[1]','varchar(255)') = 'xml_deadlock_report'
					  THEN [DATA]
					  ELSE NULL
				 END AS DEADLOCK_GRAF_XML
		FROM CTE

		SET @i += 1
	END;


	DROP TABLE IF exists #RESULT;

	SELECT   d.XEVENT_NAME
			,d.[EVENT]
			,d.[TIMESTAMP]
			,d.SERVER_NAME
			,d.DATABASE_ID
			,d.[APP_NAME]
			,d.USERNAME
			,d.SESSION_ID
			,d.SQL_TEXT
			,d.session_id_query
			,d.database_id_query
			,d.deadlock_id
			,d.transaction_id_query
			,d.resource_type
			,d.[VALUE]
	into #RESULT
	FROM #FILE_DATA AS d
	LEFT JOIN dbo.XEVENT_LOG AS l ON not exists (select d.XEVENT_NAME, d.[EVENT], d.[TIMESTAMP], d.SERVER_NAME, d.DATABASE_ID, d.[APP_NAME], d.USERNAME, d.SESSION_ID, d.session_id_query, d.database_id_query, d.deadlock_id, d.transaction_id_query, d.resource_type
												 except
												 select l.XEVENT_NAME, l.[EVENT], l.[TIMESTAMP], l.SERVER_NAME, l.DATABASE_ID, l.[APP_NAME], l.USERNAME, l.SESSION_ID, l.session_id_query, l.database_id_query, l.deadlock_id, l.transaction_id_query, l.resource_type)
	WHERE l.XEVENT_NAME is null;


	BEGIN TRAN
	
		INSERT INTO dbo.XEVENT_LOG
			( XEVENT_NAME
			 ,[EVENT]
			 ,[TIMESTAMP]
			 ,SERVER_NAME
			 ,DATABASE_ID
			 ,[APP_NAME]
			 ,USERNAME
			 ,SESSION_ID
			 ,SQL_TEXT
			 ,session_id_query
			 ,database_id_query
			 ,deadlock_id
			 ,transaction_id_query
			 ,resource_type
			 ,[VALUE]
			)
		SELECT   XEVENT_NAME
				,[EVENT]
				,[TIMESTAMP]
				,SERVER_NAME
				,DATABASE_ID
				,[APP_NAME]
				,USERNAME
				,SESSION_ID
				,SQL_TEXT
				,session_id_query
				,database_id_query
				,deadlock_id
				,transaction_id_query
				,resource_type
				,[VALUE]
		FROM #RESULT;
	

		UPDATE el
		SET el.LAST_DATE = getdate()
		FROM dbo.XEVENT_LIST AS el
		INNER JOIN #XEVENT_LIST AS d ON el.XEVENT_NAME = d.XEVENT_NAME;

	COMMIT;

END TRY
BEGIN CATCH
	--exec UTILITY.dbo.Catch
END CATCH
