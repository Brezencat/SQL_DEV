CREATE EVENT SESSION [QUERY_CPU] ON SERVER 
ADD EVENT sqlserver.rpc_completed
	(
	 SET collect_statement = (1)
     ACTION ( sqlos.task_time
			 ,sqlserver.client_app_name
			 ,sqlserver.client_hostname
			 ,sqlserver.compile_plan_guid
			 ,sqlserver.database_id
			 ,sqlserver.plan_handle
			 ,sqlserver.session_id
			 ,sqlserver.sql_text
			 ,sqlserver.username
			)
     WHERE ( [package0].[greater_than_uint64]([cpu_time],(500000)) )
	),
ADD EVENT sqlserver.sql_batch_completed 
	(
	 SET collect_batch_text = (1)
     ACTION ( sqlos.task_time
			 ,sqlserver.client_app_name
			 ,sqlserver.client_hostname
			 ,sqlserver.compile_plan_guid
			 ,sqlserver.database_id
			 ,sqlserver.plan_handle
			 ,sqlserver.session_id
			 ,sqlserver.sql_text
			 ,sqlserver.username
			)
     WHERE ( [package0].[greater_than_uint64]([cpu_time],(300000)) )
	),
ADD EVENT sqlserver.sql_statement_completed
	(
	 SET collect_statement = (1)
     ACTION ( sqlos.task_time
			 ,sqlserver.client_app_name
			 ,sqlserver.client_hostname
			 ,sqlserver.compile_plan_guid
			 ,sqlserver.database_id
			 ,sqlserver.plan_handle
			 ,sqlserver.session_id
			 ,sqlserver.sql_text
			 ,sqlserver.username
			)
     WHERE ( [package0].[greater_than_uint64]([cpu_time],(300000)) ) 
	)
ADD TARGET package0.event_file (SET 
									 filename=N'QUERY_CPU'
									,max_file_size=(10)
									,max_rollover_files=(0)
							   )
WITH (
		 MAX_MEMORY=4096 KB
		,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS
		,MAX_DISPATCH_LATENCY=30 SECONDS
		,MAX_EVENT_SIZE=0 KB
		,MEMORY_PARTITION_MODE=NONE
		,TRACK_CAUSALITY=OFF
		,STARTUP_STATE=ON
	 )
GO


