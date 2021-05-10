--Ситуация на сервере

SELECT * 
FROM sys.dm_os_wait_stats 
WHERE wait_type like '%MEMORY_ALLOCATION_EXT%'

select * 
from sys.dm_exec_session_wait_stats 
where session_id = 123



--Посмотреть сессию
DECLARE @id_session int =123

SELECT  ses.original_login_name, s.granted_query_memory, s.cpu_time,
s.logical_reads, s.reads, s.writes, s.wait_type, s.wait_time,
s.last_wait_type,
                SUBSTRING(st.text,s.statement_start_offset/2 +1,
          (CASE WHEN s.statement_end_offset = -1
                THEN LEN(CONVERT(nvarchar(max), st.text)) * 2
                ELSE s.statement_end_offset end -
                    s.statement_start_offset
          )/2
      ) as sql_text, sp.*, s.*
FROM    sys.dm_exec_requests AS s                       
        inner join sys.dm_exec_sessions AS ses ON s.session_id = ses.session_id
        cross apply sys.dm_exec_sql_text(s.sql_handle) AS st
        outer apply sys.dm_exec_query_plan(s.plan_handle) AS sp
WHERE s.session_id = @id_session

select * from sys.dm_os_waiting_tasks where session_id = @id_session

exec sp_who2 @id_session

exec sp_lock @id_session

--======================================================================================================


-- текущая ситуация на сервере (выполняемые запросы)
SELECT  qs.session_id, qs.status, wait_type, command, last_wait_type,
percent_complete, qt.text,
                qs.total_elapsed_time/1000 as [total_elapsed_time, сек],
                wait_time/1000 as [wait_time, сек], (qs.total_elapsed_time -
wait_time)/1000 as [work_time, сек]
FROM    sys.dm_exec_requests as qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
INNER JOIN sys.dm_exec_sessions AS es ON qs.session_id = es.session_id
WHERE qs.session_id <> @@spid and is_user_process = 1
ORDER BY 1



SELECT physical_io, cpu, cmd, STATUS, spid, sp.loginame, sp.hostname,
       dat.name, sp.lastwaittype, sp.blocked, sp.program_name, sp.waitresource,
       dat.log_reuse_wait_desc, sp.dbid, sp.memusage, sp.open_tran
FROM   sys.sysprocesses AS sp
       INNER JOIN sys.databases AS dat ON dat.database_id = sp.dbid
WHERE  LTRIM(hostname) <> '' AND STATUS <> 'background'
--         and spid=871
ORDER BY
       sp.physical_io DESC, sp.cpu DESC, sp.hostname, sp.dbid,
nt_domain, nt_username



SELECT r.session_id,
       r.status,
       r.wait_time,
       wait_type,
       r.wait_resource,
       r.row_count,
       r.percent_complete,
       qt.text,
       SUBSTRING(
           qt.text,
           (r.statement_start_offset / 2) + 1,
           (
               CASE
                    WHEN r.statement_end_offset = -1 THEN
LEN(CONVERT(NVARCHAR(MAX), qt.text))
                         * 2
                    ELSE r.statement_end_offset
               END -r.statement_start_offset
           ) / 2
       ) AS stmt_executing,
           r.blocking_session_id,
       r.reads AS phys_reads,
       r.writes,
       r.logical_reads,
       r.total_elapsed_time,
       r.estimated_completion_time
FROM   sys.dm_exec_requests r
       INNER JOIN sys.dm_exec_sessions s
            ON  r.session_id = s.session_id
       CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS qt
--where  r.session_id=871
ORDER BY
       r.wait_resource DESC



--история процессов/сессий
select collection_time , * from Utility..WhoIsActiveLog l (nolock)
where l.collection_time>=dateadd(dd,0,datediff(dd,0,GETDATE())-1)
and session_id=871
--and convert(nvarchar(max),sql_text) like '%DIC_AGREEMENT_FOREX%'
order by l.collection_time desc



 --Моя писанина
select
convert(varchar(20),DATEDIFF(ss, s.last_request_start_time,
getdate())/3600)+ right( convert(varchar(10), DATEADD(ss,DATEDIFF(ss,
s.last_request_start_time, getdate()),0),108),6) AS RUNNING,
s.session_id,
DB_NAME(s.database_id) AS DB,
s.status,
s.login_name, s.nt_user_name,
s.cpu_time, s.memory_usage, s.reads, s.writes, s.logical_reads,
s.row_count, s.open_transaction_count,
w.blocking_session_id, w.wait_duration_ms, w.wait_type, login_time,
s.host_name, s.program_name
from sys.dm_exec_sessions as s
left join sys.dm_os_waiting_tasks as w on s.session_id=w.session_id
where is_user_process = 1
and status<>'sleeping'
