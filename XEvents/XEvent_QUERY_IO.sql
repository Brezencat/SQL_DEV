CREATE EVENT SESSION [QUERY_IO] ON SERVER 
ADD EVENT sqlserver.rpc_completed
	(
	 SET collect_output_parameters=(1)
		,collect_statement=(1)
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
     WHERE ([logical_reads]>(10)
		   )
	),
ADD EVENT sqlserver.sql_batch_completed
	(
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
     WHERE ([logical_reads]>(10)
		   )
	),
ADD EVENT sqlserver.sql_statement_completed
	(
	 SET collect_parameterized_plan_handle=(1)
     ACTION ( sqlos.task_time,sqlserver.client_app_name
			 ,sqlserver.client_hostname
			 ,sqlserver.compile_plan_guid
			 ,sqlserver.database_id
			 ,sqlserver.plan_handle
			 ,sqlserver.session_id
			 ,sqlserver.sql_text
			 ,sqlserver.username
			)
     WHERE ([logical_reads]>(10)
		   )
	)
ADD TARGET package0.event_file (SET 
									 filename=N'QUERY_IO'
									,max_file_size=(10)
									,max_rollover_files=(0)
							   )
WITH (
		 MAX_MEMORY=4096 KB
		,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS
		,MAX_DISPATCH_LATENCY=5 SECONDS
		,MAX_EVENT_SIZE=0 KB
		,MEMORY_PARTITION_MODE=NONE
		,TRACK_CAUSALITY=OFF
		,STARTUP_STATE=ON
	 )
GO


