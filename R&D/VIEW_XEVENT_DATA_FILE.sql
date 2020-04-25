
SELECT CAST(event_data as XML) AS [DATA]
FROM sys.fn_xe_file_target_read_file ('DEADLOCK_MONITOR*.xel', null, null, null) WHERE timestamp_utc like '2020-04-25%'

SELECT CAST(event_data as XML) AS [DATA]
FROM sys.fn_xe_file_target_read_file ('LOGIN_APP_CONNECT*.xel', null, null, null) WHERE timestamp_utc like '2020-04-25%'

SELECT CAST(event_data as XML) AS [DATA], *
FROM sys.fn_xe_file_target_read_file ('QUERY_IO*.xel', null, null, null) WHERE timestamp_utc like '2020-04-25 12:14:19.8360000%'

SELECT CAST(event_data as XML) AS [DATA]
FROM sys.fn_xe_file_target_read_file ('QUERY_CPU*.xel', null, null, null) WHERE timestamp_utc like '2020-04-25%'


WITH CTE AS
(SELECT CAST(event_data as XML) AS [DATA]
 FROM sys.fn_xe_file_target_read_file ('DEADLOCK_MONITOR*.xel', null, null, null) WHERE timestamp_utc like '2020-04-25%' and object_name = 'xml_deadlock_report')
select data.value('(event/data[@name="xml_report"]/value)[1]','varchar(MAX)') as DEADLOCK_GRAF
from CTE



 data.value('(event/@name)[1]','varchar(255)') as EVENT_NAME
,data.value('(event/@timestamp)[1]','datetime2') as [TIMESTAMP]

,data.value('(event/action[@name="client_hostname"]/value)[1]','varchar(255)') as SERVER_NAME
,data.value('(event/action[@name="database_id"]/value)[1]','tinyint') as DATABASE_ID
,data.value('(event/action[@name="client_app_name"]/value)[1]','varchar(2000)') as [APP_NAME]
,data.value('(event/action[@name="username"]/value)[1]','varchar(255)') as USERNAME
,data.value('(event/action[@name="session_id"]/value)[1]','smallint') as SESSION_ID
,data.value('(event/action[@name="sql_text"]/value)[1]','varchar(4000)') as SQL_TEXT


--,data.value('(event/data[@name="batch_text"]/value)[1]','varchar(4000)') --для пакетов, есть sql_text, сравнить
,data.value('(event/data[@name="options_text"]/value)[1]','varchar(4000)') --для логинов ???

--по чтениям и ЦПУ
data name="cpu_time"
data name="logical_reads"
data name="row_count"
action name="plan_handle"
data name="writes" --проверить, точно столько пишет
data name="output_parameters" --подумать над возвращаемым параметром

--по дедлокам
data name="transaction_id"
data name="session_id" --с какими сессиями взаимодействие для lock_deadlock_chain
data name="database_id" --в каких базах эти сессии для lock_deadlock_chain
data name="deadlock_id" --нужен???
<data name="resource_type">
    <value>6</value>
    <text>PAGE</text> --подумать, нужно ли это
</data>

--это из xml_deadlock_report
  <data name="xml_report">
    <value>
      <deadlock>
--вообе надо обрабатывать иначе