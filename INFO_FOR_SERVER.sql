--Системные представления и функции
--SQLOS
SELECT  cpu_count AS LOGICAL_CPU_COUNT, --логических процессоров (потоков)
		hyperthread_ratio, --количество ядер
		cpu_count / hyperthread_ratio AS PHYSICAL_CPU_COUNT, --физических процессоров
		CAST(physical_memory_kb / 1024./ 1024. AS int) AS PHYSICAL_MEMORY_GB, --Оперативная память
		sqlserver_start_time --время установки экзепляра SQL Server
FROM sys.dm_os_sys_info;



--активные сессии + блокировки. Сколько потребляют ресурсов
--is_user_process фильтрует системные сеансы 
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
where is_user_process = 1


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


--=====================
--Индексы. Начало


	--список индексов
	select * from sys.indexes

--индексы, которые используются
select    DB_NAME(us.database_id) as [DB_NAME]
		, OBJECT_NAME(us.object_id) as [OBJECT_NAME]
		, i.name as [INDEX_NAME]
		, i.type_desc as [INDEX_TYPE]
		, us.user_seeks, us.user_scans, us.user_updates
		, us.last_user_seek, us.last_user_scan, us.last_user_update
		--, us.system_seek, us.system_scans, us.system_updates
		--, us.last_system_seek, us.last_system_scan, us.last_system_update
FROM sys.dm_db_index_usage_stats as us
inner join sys.indexes as i on us.index_id=i.index_id and us.object_id=i.object_id
where database_id<>4 --исключил DB_ID('msdb')

--некластеризованные индексы, которые не используются
SELECT OBJECT_NAME(I.object_id) AS objectname, I.name AS indexname, I.index_id AS indexid
	FROM sys.indexes AS I
	--INNER JOIN sys.objects AS O ON O.object_id = I.object_id 
	WHERE I.object_id > 100 AND I.type_desc = 'NONCLUSTERED' 
		AND I.index_id NOT IN (	SELECT S.index_id 
						FROM sys.dm_db_index_usage_stats AS S 
						WHERE S.object_id=I.object_id AND I.index_id=S.index_id 
						AND database_id = DB_ID('TSQL2012')) 
	ORDER BY objectname, indexname; 

--sys.dm_db_missing_index_details
--sys.dm_db_missing_index_columns
--sys.dm_db_missing_index_groups
--sys.dm_db_missing_index_group_stats

--Поиск недостающих индексов:
	SELECT
MID.statement AS [Database.Schema.Table], 
MIC.column_id AS ColumnId,
MIC.column_name AS ColumnName,
MIC.column_usage AS ColumnUsage,
MIGS.user_seeks AS UserSeeks,
MIGS.user_scans AS UserScans,
MIGS.last_user_seek AS LastUserSeek, 
MIGS.avg_total_user_cost AS AvgQueryCostReduction, 
MIGS.avg_user_impact AS AvgPctBenefit
FROM sys.dm_db_missing_index_details AS MID
CROSS APPLY sys.dm_db_missing_index_columns (MID.index_handle) AS MIC 
INNER JOIN sys.dm_db_missing_index_groups AS MIG ON MIG.index_handle=MID.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats AS MIGS ON MIG.index_group_handle=MIGS.group_handle 
ORDER BY MIGS.avg_user_impact DESC;

--Уроыень индексов, строки и страницы. Фрагментация
--внешняя фрагментация < 30% - реорганизация, > 30% - перестроение индекса
SELECT index_type_desc
	, index_depth
	, index_level						--уровень индекса
	, page_count						--количество страниц на уровне
	, record_count						--количество строк
	, avg_page_space_used_in_percent 	--внутренняя фрагментация
	, avg_fragmentation_in_percent		--внешняя фрагментация
FROM sys.dm_db_index_physical_stats (DB_ID(N'tempdb'), OBJECT_ID(N'dbo.TestStructure'), NULL, NULL , 'DETAILED');

--Выделенная и фактически использованая память для таблицы + размер индекса
EXEC dbo.sp_spaceused @objname = N'dbo.TestStructure', @updateusage = true;



--Индексы. Конец
--=====================

--Инфо о базах данных сервера
select * from sys.databases