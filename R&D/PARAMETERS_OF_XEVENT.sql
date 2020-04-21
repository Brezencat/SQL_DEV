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
