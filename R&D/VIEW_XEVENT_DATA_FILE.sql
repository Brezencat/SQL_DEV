;
WITH XML_DATA AS 
(
    SELECT CAST(event_data as XML) AS [DATA]
    FROM sys.fn_xe_file_target_read_file (
        'C:\Users\MSSQLSERVER\Documents\HUNT_KILL_0_132297016577870000.xel'
        , null, null, null)
	WHERE object_name = 'sql_batch_starting' --эту часть надо будет обсуждать, на тесте выбираю только пакеты, стейтменты только для массовки
		and timestamp_utc like '2020-04-17%'
),
EE_DATA AS
(
    SELECT 
        data.value('(event/@timestamp)[1]','datetime2') as [DATETIME], --возможно надо будет конвертить в varchar(), потому что 2020-04-11T15:59:01.026Z
        data.value('(event/data[@name="batch_text"]/value)[1]','varchar(4000)') as SQL_TEXT, --текст запроса
        data.value('(event/action[@name="client_app_name"]/value)[1]','varchar(2000)') as [APP_NAME],
        data.value('(event/action[@name="client_hostname"]/value)[1]','varchar(256)') as SERVER_NAME,
        data.value('(event/action[@name="database_id"]/value)[1]','tinyint') as ID_DATABASE,
        data.value('(event/action[@name="database_name"]/value)[1]','varchar(256)') as NAME_DATABASE,
        data.value('(event/action[@name="session_id"]/value)[1]','int') as ID_SESSION,
        data.value('(event/action[@name="username"]/value)[1]','varchar(512)') as [USERNAME]
    FROM XML_DATA
)
SELECT --DISTINCT 
    [DATETIME],
    SQL_TEXT,
    [APP_NAME],
    SERVER_NAME,
    ID_DATABASE,
    NAME_DATABASE,
    ID_SESSION,
    [USERNAME]
FROM EE_DATA 
;

--collect_system_time не нужно, потому что в эвенте есть timestamp