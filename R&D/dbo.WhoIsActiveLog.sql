--запустим процедуру с параметром @return_schema  
declare @schema VARCHAR(MAX) = NULL;

exec [dbo].[sp_WhoIsActive]
    @return_schema = 1
    ,@schema = @schema OUTPUT
    --@help = 1
;
select @schema
;

--получим скрипт
CREATE TABLE dbo.WhoIsActiveLog
	([dd hh:mm:ss.mss] varchar(8000) NULL,
	 [session_id] smallint NOT NULL,
	 [sql_text] xml NULL,
	 [login_name] nvarchar(128) NOT NULL,
	 [wait_info] nvarchar(4000) NULL,
	 [CPU] varchar(30) NULL,
	 [tempdb_allocations] varchar(30) NULL,
	 [tempdb_current] varchar(30) NULL,
	 [blocking_session_id] smallint NULL,
	 [reads] varchar(30) NULL,
	 [writes] varchar(30) NULL,
	 [physical_reads] varchar(30) NULL,
	 [used_memory] varchar(30) NULL,
	 [status] varchar(30) NOT NULL,
	 [open_tran_count] varchar(30) NULL,
	 [percent_complete] varchar(30) NULL,
	 [host_name] nvarchar(128) NULL,
	 [database_name] nvarchar(128) NULL,
	 [program_name] nvarchar(128) NULL,
	 [start_time] datetime NOT NULL,
	 [login_time] datetime NULL,
	 [request_id] int NULL,
	 [collection_time] datetime NOT NULL)
;

--запрос для джоба, который будет записывать результат в лог
exec [dbo].[sp_WhoIsActive]
    @destination_table = 'AdventureWorks2017.dbo.WhoIsActiveLog'
;