--MSSQL Server

--SQLOS, информация о сервере
SELECT  cpu_count AS LOGICAL_CPU_COUNT, --логических процессоров (потоков)
		hyperthread_ratio, --количество ядер
		cpu_count / hyperthread_ratio AS PHYSICAL_CPU_COUNT, --физических процессоров
		CAST(physical_memory_kb / 1024./ 1024. AS int) AS PHYSICAL_MEMORY_GB, --Оперативная память
		sqlserver_start_time --время установки экзепляра SQL Server
FROM sys.dm_os_sys_info;


--Инфо о базах данных сервера
select * from sys.databases;



--активные сессии + блокировки. Сколько потребляют ресурсов
select 
convert(varchar(20),DATEDIFF(ss, s.last_request_start_time, getdate())/3600)+ right( convert(varchar(10), DATEADD(ss,DATEDIFF(ss, s.last_request_start_time, getdate()),0),108),6) AS RUNNING,
s.session_id, 
DB_NAME(s.database_id) AS DB,
s.status,
s.login_name, s.nt_user_name,  
s.cpu_time, s.memory_usage, s.reads, s.writes, s.logical_reads, s.row_count, s.open_transaction_count, 
w.blocking_session_id, w.wait_duration_ms, w.wait_type, login_time,
s.host_name, s.program_name
from sys.dm_exec_sessions as s
left join sys.dm_os_waiting_tasks as w on s.session_id=w.session_id
where is_user_process = 1 --is_user_process фильтрует системные сеансы





--Быстрый подсчёт строк таблицы
SELECT SUM(rows) AS [RowCount]
FROM sys.partitions
WHERE index_id IN (0, 1)
	AND object_id = OBJECT_ID(N'dbo.TABLE_NAME')
GROUP BY object_id

--вариант использования с запуском на другом сервере (должен быть насроен Linked Server)
exec ( 'USE DATABASE
		SELECT SUM(rows) AS [RowCount]
		FROM sys.partitions
		WHERE index_id IN (0,1)
			AND object_id = OBJECT_ID(N''dbo.TABLE_NAME'')
		GROUP BY object_id'
	 ) at [LINKED_SERVER];

--ещё вариант с подсчётом
SELECT isnull(t.row_count, 0) AS CountRec
FROM sys.objects o
INNER JOIN
	(
		select 	p.[object_id]
			, 	SUM(p.row_count) as [row_count]
		from sys.dm_db_partition_stats as p
		where p.index_id < 2
		group by p.[object_id]
	) AS t 
	ON t.[object_id] = o.[object_id]
WHERE o.[type] = 'U' 
	AND o.is_ms_shipped = 0 
	AND o.name = 'TABLE_NAME';


--============================================
--с этим надо ещё разобраться

--Пример запроса информации о текущих запросах, их времени ожидания и текста из пакета SQL, а также информацию о пользователе, хосте и приложении:
SELECT S.login_name, S.host_name, S.program_name, R.command, 
				T.text, 
				R.wait_type, R.wait_time, R.blocking_session_id 
		FROM sys.dm_exec_requests AS R --выполняющиеся в данный момент запросы
		INNER JOIN sys.dm_exec_sessions AS S ON R.session_id = S.session_id
		OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) AS T 
		WHERE S.is_user_process = 1; 

--5 запросов, использовавших большую часть логических операций ввода-вывода, а также выводит текст запроса, извлеченный из текста пакета
SELECT TOP (5)
(total_logical_reads + total_logical_writes) 	AS total_logical_IO, execution_count,
(total_logical_reads/execution_count) 	AS avg_logical_reads, 
(total_logical_writes/execution_count) 	AS avg_logical_writes, 
(	SELECT SUBSTRING(text, statement_start_offset/2 + 1,
			(
			 CASE WHEN statement_end_offset = -1
			 THEN LEN(CONVERT(nvarchar(MAX),text)) * 2 
			 ELSE statement_end_offset
			 END 
				- statement_start_offset
			)
				/2)
		FROM sys.dm_exec_sql_text(sql_handle)
) 						AS query_text
FROM sys.dm_exec_query_stats
ORDER BY (total_logical_reads + total_logical_writes) DESC;



--==============================

--очистка кэша планов запросов
DBCC FREEPROCCACHE;
