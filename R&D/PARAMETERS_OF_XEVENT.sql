DECLARE @eventname varchar(256);
set @eventname = 'DEADLOCK_MONITOR'; --название эвента, для которого ищем файл

--какие события используются и список полей
select   s.name
        ,se.name
        ,sa.name
        ,se.predicate
from sys.server_event_sessions AS s
inner join sys.server_event_session_events AS se ON s.event_session_id = se.event_session_id
inner join sys.server_event_session_actions AS sa ON s.event_session_id = sa.event_session_id 
													and se.event_id = sa.event_id
where s.name = @eventname

union all
--параметры вывода данных эвента
select   s.name
        ,st.name
        ,sf.name
        ,sf.value 
from  sys.server_event_sessions AS s
inner join sys.server_event_session_targets AS st ON s.event_session_id = st.event_session_id
inner join sys.server_event_session_fields AS sf ON s.event_session_id = sf.event_session_id 
													and st.target_id = sf.object_id
where s.name = @eventname

--==============================================================

--Описание параметров событий
SELECT	 o.name AS XEvent_NAME
		,c.name AS XEvent_COLUMN
		,o.description AS Descr_NAME
		,c.description AS Descr_COLUMN
FROM sys.dm_xe_objects AS o
INNER JOIN sys.dm_xe_object_columns AS c ON o.name = c.object_name
ORDER BY o.name, c.name

--==============================================================

--*ROAD_TO_FILE_XEVENT
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
exec master.sys.xp_dirtree 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\ ' --дирректория
							, 0 --сколько вложенных уровней отображать (0 - все)
							, 1 --отображать (1) файлы в дирректориях или нет (0) 


--==============================================================

--Пример запуска процедур


declare @datefrom datetime2  = DATEADD(dd, -5, getutcdate())
exec dbo.LOAD_XEVENT_XML_BUFFER
		 @DATE = @datefrom
		,@XEVENT_NAME = null 
		,@FILE_DIRECTORY = 'C:\Users\MSSQLSERVER\Documents\XEVENT_LOG'
		,@view = null

declare @datefrom datetime2  = DATEADD(dd, -5, getutcdate())
exec [dbo].[LOAD_XEVENT_XML_VIEW]
		 @DATE = @datefrom
		,@XEVENT_NAME = null 
		,@FILE_DIRECTORY = 'C:\Users\MSSQLSERVER\Documents\XEVENT_LOG'
		,@view = 1

