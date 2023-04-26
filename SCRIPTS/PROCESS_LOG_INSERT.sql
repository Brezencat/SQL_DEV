--Процедура записи данных в таблицу логирования

CREATE OR ALTER PROC dbo.PROCESS_LOG_INSERT
		@process_name varchar(255)
	,	@message nvarchar(255)
	,	@description nvarchar(4000) = null
	,	@date_start datetime = null
	,	@db_name varchar(255) = null
	,	@spid smallint = null
	,	@row_count int = null
	,	@params varchar(4000) = null
	,	@user_name nvarchar(128) = null
	,	@host_name nvarchar(128) = null
	,	@is_query_plan bit = 0

WITH EXECUTE AS 'dbo'

AS
BEGIN TRY
	SET NOCOUNT ON;

--блок проверок
	IF @user_name is null
		SELECT @user_name = SUSER_SNAME();
	
	IF @host_name is null
		SELECT @host_name = HOST_NAME();
--/----------------------------------------/

--Сбор параметров, если не указаны (доработать)
	IF @params is null
	BEGIN
		SET @params = '';

		--SELECT @params = @params + [name] + ', '
		--FROM sys.parameters
		--WHERE object_id = OBJECT_ID(@process_name)
		--;
	END;
--/----------------------------------------/

--Поиск плана запроса, если установлен флаг
	DECLARE @query_plan_xml xml;

	IF @is_query_plan = 1 and @spid is not null
	BEGIN
		SELECT
			--@CPU = er.cpu_time
			--,	@Duration = er.total_elapsed_time
			--,	@Reads = er.logical_reads
			--,	@Writes = er.writes
			@query_plan_xml = qp.query_plan
		FROM sys.dm_exec_requests AS er
		CROSS APPLY sys.dm_exec_query_plan (er.plan_handle) AS qp
		WHERE er.session_id = @spid
		;
	END
	ELSE
		SET @query_plan_xml = null;
--/----------------------------------------/

--Запись лога
	IF @date_start is null
		SELECT @date_start = getdate();

	INSERT INTO dbo.PROCESS_LOG
		(ProcessName, [Message], [Description], DateStart, DBName, SPID, [RowCount], Params, UserName, HostName, QueryPlan)
	SELECT	@process_name
		,	@message
		,	@description
		,	@date_start
		,	@db_name
		,	@spid
		,	@row_count
		,	@params
		,	@user_name
		,	@host_name
		,	@query_plan_xml
	;
--/----------------------------------------/
END TRY
BEGIN CATCH
--если ошибка при записи, попробовать её записать

	SELECT @description = TRY_CAST(t.error as nvarchar(4000))
	FROM (
			select  ERROR_NUMBER() AS [@ErrorNumber]  
				,	ERROR_SEVERITY() AS [@Severity]  
				,	ERROR_STATE() AS [@ErrorState]  
				,	ERROR_PROCEDURE() AS [@ErrorProcedure] 
				,	ERROR_LINE() AS [@ErrorLine]
				,	ERROR_MESSAGE() AS [@ErrorMessage]
			for xml path ('error')
		) AS t(error)
	;

	SET @message = 'ERROR';
	SET @db_name = DB_NAME();
	SET @spid = @@SPID

	INSERT INTO dbo.PROCESS_LOG
		(ProcessName, [Message], [Description], DBName, SPID)
	SELECT	@process_name
		,	@message
		,	@description
		,	@db_name
		,	@spid
	;
--/----------------------------------------/

	THROW;
END CATCH
;