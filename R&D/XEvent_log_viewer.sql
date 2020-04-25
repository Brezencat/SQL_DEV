--select * from dbo.XEVENT_LIST

--select len('0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')

drop table if exists #XEVENT_LIST;

select ROW_NUMBER() over (order by ID) as ID, EVENT_NAME, FILE_PATH, ISNULL(LAST_DATE, getutcdate()) as LAST_DATE
into #XEVENT_LIST
from dbo.XEVENT_LIST
where IS_ACTIVE = 1
;

drop table if exists #RESULT;

CREATE TABLE #RESULT
	( XEVENT_NAME 	varchar(255)	NOT NULL --имя XEvent
	 ,[EVENT]		varchar(255) 	NOT NULL --имя собоытия из XML
	 ,[TIMESTAMP] 	datetime2 		NOT NULL --дата и время проишествия
	 ,SERVER_NAME 	varchar(255) 	NOT NULL --client_hostname
	 ,DATABASE_ID 	tinyint 		NOT NULL --smallint ???
	 ,[APP_NAME] 	varchar(255) 	NOT NULL --client_app_name
	 ,USERNAME 		varchar(255) 	NOT NULL 
	 ,[SESSION_ID] 	smallint 		NOT NULL
	 ,SQL_TEXT 		varchar(MAX) 	NULL --тексты запросов. exec процедуры
	 ,[STATEMENT]	varchar(4000) 	NULL --запрос, вызвавший событие. Запрос из процедуры
	 ,CPU_TIME 		int 			NULL
	 ,LOGICAL_READS int 			NULL
	 ,ROW_COUNT 	int 			NULL

	 ,PLAN_HANDLE			varchar(100)	null
	 ,WRITES				int				null
	 ,OUTPUT_PARAMETERS		varchar(255)	null
	 ,transaction_id_query	int				null
	 ,session_id_query		int				null --с какими сессиями взаимодействие для lock_deadlock_chain
	 ,database_id_query		tinyint			null--в каких базах эти сессии для lock_deadlock_chain
	 ,deadlock_id			int				null--нужен???
	 ,resource_type			varchar(10)		null --какой тип блокировки наложен
	 ,DEADLOCK_GRAF			varchar(MAX)	null
	 
	 ,[VALUE] 		XML 			NULL --разные параметры
	)
;
declare  @count tinyint --количество циклов
		,@i tinyint --количество итераций
		,@SEANS_NAME varchar(255)
		,@FILE_PATH varchar(255)
		,@DATE varchar(11);

select @count = count(ID) from #XEVENT_LIST;
set @i = 1;

while @i <= @count
BEGIN

	select @SEANS_NAME = EVENT_NAME, @FILE_PATH = FILE_PATH, @DATE = CAST(LAST_DATE as varchar(10)) + '%' from #XEVENT_LIST where ID=@i;

	WITH CTE AS
	(
		SELECT CAST(event_data as XML) AS [DATA]
		FROM sys.fn_xe_file_target_read_file (@FILE_PATH, null, null, null)
		WHERE 1=1--object_name = 'sql_batch_starting'
			and timestamp_utc like @DATE
	)
	INSERT INTO #RESULT
		( XEVENT_NAME
		 ,[EVENT]
		 ,[TIMESTAMP]
		 ,SERVER_NAME
		 ,DATABASE_ID
		 ,[APP_NAME]
		 ,USERNAME
		 ,[SESSION_ID]
		 ,SQL_TEXT
		 ,[STATEMENT]
		 ,CPU_TIME
		 ,LOGICAL_READS
		 ,ROW_COUNT
		 ,PLAN_HANDLE			
		 ,WRITES				
		 ,OUTPUT_PARAMETERS		
		 ,transaction_id_query	
		 ,session_id_query		
		 ,database_id_query		
		 ,deadlock_id			
		 ,resource_type			
		 ,DEADLOCK_GRAF
		)
	SELECT  @SEANS_NAME as XEVENT_NAME
			,data.value('(event/@name)[1]','varchar(255)') as [EVENT]
			,data.value('(event/@timestamp)[1]','datetime2') as [TIMESTAMP]
			,data.value('(event/action[@name="client_hostname"]/value)[1]','varchar(255)') as SERVER_NAME
			,ISNULL(data.value('(event/action[@name="database_id"]/value)[1]','tinyint'),
					data.value('(event/data[@name="database_id"]/value)[1]','tinyint')) as DATABASE_ID
			,data.value('(event/action[@name="client_app_name"]/value)[1]','varchar(255)') as [APP_NAME]
			,data.value('(event/action[@name="username"]/value)[1]','varchar(255)') as USERNAME
			,data.value('(event/action[@name="session_id"]/value)[1]','smallint') as SESSION_ID
			,data.value('(event/action[@name="sql_text"]/value)[1]','varchar(MAX)') as SQL_TEXT
			,data.value('(event/data[@name="statement"]/value)[1]','varchar(4000)') as [STATEMENT]
			,data.value('(event/data[@name="cpu_time"]/value)[1]','int') as CPU_TIME
			,data.value('(event/data[@name="logical_reads"]/value)[1]','int') as LOGICAL_READS
			,data.value('(event/data[@name="row_count"]/value)[1]','int') as ROW_COUNT

			,data.value('(event/action[@name="plan_handle"]/value)[1]','varchar(100)') as PLAN_HANDLE
			,data.value('(event/data[@name="writes"]/value)[1]','int') as WRITES --проверить, точно столько пишет
			,data.value('(event/data[@name="output_parameters"]/value)[1]','varchar(255)') as OUTPUT_PARAMETERS --подумать над возвращаемым параметром
			,data.value('(event/data[@name="transaction_id"]/value)[1]','int') as transaction_id_query
			,data.value('(event/data[@name="session_id"]/value)[1]','int') as session_id_query --с какими сессиями взаимодействие для lock_deadlock_chain
			,data.value('(event/data[@name="database_id"]/value)[1]','tinyint') as database_id_query --в каких базах эти сессии для lock_deadlock_chain
			,data.value('(event/data[@name="deadlock_id"]/value)[1]','int') as deadlock_id --нужен???
			,data.value('(event/data[@name="resource_type"]/text)[1]','varchar(10)') as resource_type --какой тип блокировки наложен
			,data.value('(event/data[@name="xml_report"]/value)[1]','varchar(MAX)') as DEADLOCK_GRAF--это из xml_deadlock_report--вообе надо обрабатывать иначе
			--как то надо правильно вытянуть внутренности с тегами
      --,[DATA]
	FROM CTE

	set @i += 1
END;

--как то собрать VALUE
select *--, COALESCE(DEADLOCK_GRAF,
from #RESULT

select XEVENT_NAME, MAX([TIMESTAMP]) as LASTDATE
from #RESULT
GROUP BY XEVENT_NAME
;

begin tran
	
	INSERT INTO dbo.XEVENT_LOG
		( XEVENT_NAME
		 ,[EVENT]
		 ,[TIMESTAMP]
		 ,SERVER_NAME
		 ,DATABASE_ID
		 ,[APP_NAME]
		 ,USERNAME
		 ,[SESSION_ID]
		 ,SQL_TEXT
		 ,[STATEMENT]
		 ,CPU_TIME
		 ,LOGICAL_READS
		 ,ROW_COUNT
		 ,[VALUE]
		)
	SELECT  XEVENT_NAME
			,[EVENT]
			,[TIMESTAMP] 
			,SERVER_NAME 
			,DATABASE_ID 
			,[APP_NAME] 
			,USERNAME 
			,[SESSION_ID] 
			,SQL_TEXT 
			,[STATEMENT]
			,CPU_TIME
			,LOGICAL_READS
			,ROW_COUNT
			,[VALUE]
	FROM #RESULT


	update el
	set el.LASTDATE = d.LASTDATE
	from dbo.XEVENT_LIST as el
	inner join #EVENT_DATE as d ON el.EVENT_NAME = d.EVENT_NAME;

commit