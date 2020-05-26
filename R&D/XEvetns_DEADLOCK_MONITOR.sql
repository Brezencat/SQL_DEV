CREATE EVENT SESSION [DEADLOCK_MONITOR] ON SERVER 
ADD EVENT sqlserver.xml_deadlock_report ( --отчет о взаимоблокировке в формате XML
	ACTION ( sqlserver.client_app_name
			,sqlserver.client_hostname
			,sqlserver.database_id
			,sqlserver.nt_username
			,sqlserver.server_principal_name
			,sqlserver.session_id
			,sqlserver.sql_text
			,sqlserver.username))
ADD TARGET package0.event_file ( 
	SET filename=N'C:\Users\MSSQLSERVER\Documents\XEVENT_LOG\DEADLOCK_MONITOR.xel'
				,max_file_size=(100)  --размер файла лога в Мб
				,max_rollover_files = (5)) --количество файлов лога (если 0, то перезапись лога в один файл)
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