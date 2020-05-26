CREATE EVENT SESSION [LOGIN_APP_CONNECT] ON SERVER 
ADD EVENT sqlserver.login (
	SET collect_database_name=(1)
		,collect_options_text=(1)
    ACTION ( sqlserver.client_app_name
			,sqlserver.client_hostname
			,sqlserver.nt_username
			,sqlserver.session_id
			,sqlserver.sql_text
			,sqlserver.username)
    WHERE ( [sqlserver].[not_equal_i_sql_unicode_string] ([sqlserver].[username],N'NT SERVICE\SQLSERVERAGENT') 
		AND [sqlserver].[not_equal_i_sql_unicode_string] ([sqlserver].[username],N'NT Service\SSISScaleOutMaster140') 
		AND [sqlserver].[not_equal_i_sql_unicode_string] ([sqlserver].[username],N'NT SERVICE\SQLTELEMETRY') 
		AND [sqlserver].[not_equal_i_sql_unicode_string] ([sqlserver].[client_app_name],N'.Net SqlClient Data Provider') 
		AND NOT [sqlserver].[like_i_sql_unicode_string] ([sqlserver].[client_app_name],N'%Microsoft SQL Server Management Studio%') 
		AND NOT [sqlserver].[like_i_sql_unicode_string] ([sqlserver].[client_app_name],N'%Service Broker%')))
ADD TARGET package0.event_file ( 
	SET filename=N'C:\Users\MSSQLSERVER\Documents\XEVENT_LOG\LOGIN_APP_CONNECT.xel'
				,max_file_size=(300)
				,max_rollover_files=(3))

WITH ( MAX_MEMORY=4096 KB
	  ,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS --возможная потеря одного события, если выделенный буфер памяти для события будет заполнен (при записи данных события на диск из памяти)
	  ,MAX_DISPATCH_LATENCY=3 SECONDS --задержка информации о событии в буферной памяти, после которой выполняется запись на диск (влияет на заполнение буфера)
	  ,MAX_EVENT_SIZE=0 KB
	  ,MEMORY_PARTITION_MODE=NONE
	  ,TRACK_CAUSALITY=OFF
	  ,STARTUP_STATE=ON) --запуск эвента со стартом сервера
GO

--запуск эвента после создания
ALTER EVENT SESSION [DEADLOCK_MONITOR] ON SERVER
	STATE = START;