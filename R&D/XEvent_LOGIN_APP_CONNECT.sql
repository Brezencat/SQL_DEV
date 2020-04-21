CREATE EVENT SESSION [LOGIN_APP_CONNECT] ON SERVER 
ADD EVENT sqlserver.login
	(
	 SET collect_database_name=(1)
		,collect_options_text=(1)
     ACTION ( sqlserver.client_app_name
			 ,sqlserver.client_hostname
			 ,sqlserver.session_id
			 ,sqlserver.username
		    )
     WHERE ([sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[username],N'NT SERVICE\SQLSERVERAGENT') 
			AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[username],N'NT Service\SSISScaleOutMaster140') 
			AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[username],N'NT SERVICE\SQLTELEMETRY') 
			AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N'Среда Microsoft SQL Server Management Studio - IntelliSense для языка Transact-SQL')
		   )
	)
ADD TARGET package0.event_file (SET 
									 filename=N'LOGIN_APP_CONNECT'
									,max_file_size=(10)
									,max_rollover_files=(0)
							   )
WITH (
		 MAX_MEMORY=4096 KB
		,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS
		,MAX_DISPATCH_LATENCY=3 SECONDS
		,MAX_EVENT_SIZE=0 KB
		,MEMORY_PARTITION_MODE=NONE
		,TRACK_CAUSALITY=OFF
		,STARTUP_STATE=ON
	 )
GO


