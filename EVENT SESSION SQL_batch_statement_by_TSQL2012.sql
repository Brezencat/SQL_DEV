--Сделал в интерфейсе расширенных событий
--Отслеживать пакеты и запросы в TSQL2012
CREATE EVENT SESSION [SQL_batch_statement_by_TSQL2012] ON SERVER 
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'TSQL2012')),
ADD EVENT sqlserver.sql_batch_starting(
    ACTION(sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'TSQL2012')),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'TSQL2012')),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(sqlserver.plan_handle,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)
    WHERE ([sqlserver].[database_name]=N'TSQL2012'))
ADD TARGET package0.event_file(SET filename=N'Test_20200113')
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


