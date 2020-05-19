DECLARE @eventname varchar(256);
set @eventname = 'DEADLOCK_MONITOR'; --название эвента, для которого ищем файл

--WITH CTE AS
--(
	select	 s.name AS EVENT_NAME
			,CAST(st.target_data as XML) AS ROAD_TO_FILE					--путь к файлу
			,st.bytes_written / 1024. / 1024 AS TOTAL_WRITTEN_TO_FILE_MB	--записано в файл с момента его существования
			,s.buffer_processed_count AS COUNT_RECORD_IN_BUFFER				-- общее количество записей в буфер
			,st.execution_count AS COUNT_RECORD_IN_FILE						--общее количество записей в файл
	from sys.dm_xe_sessions AS s
	inner join sys.dm_xe_session_targets AS st ON s.address = st.event_session_address
	where st.target_name = 'event_file' --если использовать st.target_name = 'ring_buffer' то выводим всё, что собирается в буфер эвента
		and s.name = @eventname
--)
--select ROAD_TO_FILE.value ('(EventFileTarget)[1]','varchar(1000)')
--from CTE


--показывает все файлы по указанному пути
exec master.sys.xp_dirtree 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\' --дирректория
							, 0 --сколько вложенных уровней отображать (0 - все)
							, 1 --отображать (1) файлы в дирректориях или нет (0) 
