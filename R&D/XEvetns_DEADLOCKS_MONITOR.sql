CREATE EVENT SESSION [DEADLOCK_MONITOR] ON SERVER 
ADD EVENT sqlserver.lock_deadlock -- событие lock_deadlock отслеживает возникновение взаимоблокировок и объекты, которые в них участвуют
	(
    ACTION ( sqlserver.client_app_name
			,sqlserver.client_hostname
			,sqlserver.database_id
			,sqlserver.server_principal_name
			,sqlserver.session_id
			,sqlserver.sql_text
			,sqlserver.transaction_id
			,sqlserver.username
		   )
	),
ADD EVENT sqlserver.lock_deadlock_chain -- событие lock_deadlock_chain регистрирует условие возникновения взаимоблокировок

	(
    ACTION ( sqlserver.client_app_name
			,sqlserver.client_hostname
			,sqlserver.database_id
			,sqlserver.server_principal_name
			,sqlserver.session_id
			,sqlserver.sql_text
			,sqlserver.transaction_id
			,sqlserver.username
		   )
	),
ADD EVENT sqlserver.xml_deadlock_report --отчет о взаимоблокировке в формате XML
	(
    ACTION ( sqlserver.client_app_name
			,sqlserver.client_hostname
			,sqlserver.database_id
			,sqlserver.server_principal_name
			,sqlserver.session_id
			,sqlserver.sql_text
			,sqlserver.transaction_id
			,sqlserver.username
		   )
	)
ADD TARGET package0.event_file (SET 
									 filename = N'DEADLOCK_MONITOR'
									,max_file_size = (10) --размер файла лога в Мб
									,max_rollover_files = (0) -- количество файлов лога (если 0, то перезапись лога старый файл)
							   ) 
WITH (
		STARTUP_STATE=ON
	 )
GO


