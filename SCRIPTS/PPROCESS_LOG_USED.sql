--===============================
--использование
--===============================
--Логирование. Старт
	IF @is_logging = 1
	BEGIN
		DECLARE @process_name varchar(255) = OBJECT_NAME(@@PROCID)
			,	@message nvarchar(255)
			,	@description nvarchar(4000)
			,	@db_name varchar(255) = DB_NAME()
			,	@params varchar(4000)
			,	@user_name nvarchar(128) = SUSER_SNAME()
			,	@host_name nvarchar(128) = HOST_NAME()
			,	@date_start_log datetime = getdate()
		
		SET @message = N'START ' + CONVERT(nvarchar(19), @date_start_log, 120);
		SET @params = CAST((
							select	@search_obj_name as [@search_obj_name]
								,	@mode as [@mode]
							for xml path ('params')
						) as varchar(4000));

		EXEC dbo.PROCESS_LOG_INSERT @process_name, @message, null, null, @db_name, @@SPID, null, @params, @user_name, @host_name, 0;
	END

--использование далее
IF @is_logging = 1
BEGIN
	SET @message = CONCAT(N'Название шага ', @varable);
	EXEC dbo.PROCESS_LOG_INSERT @process_name, @message, null, null, @db_name, @@SPID, null, null, @user_name, @host_name, 0;
END

--простой вариант
	IF @is_logging = 1
		EXEC dbo.PROCESS_LOG_INSERT @process_name, N'Подготовка', null, null, @db_name, @@SPID, null, null, @user_name, @host_name, 0;


--завершение
	IF @is_logging = 1
	BEGIN
		SET @message = (
			select	N'END. Время выполнения ' + CAST(CAST(getdate() - @date_start_log as time(0)) as nvarchar(8))
		);
		EXEC dbo.PROCESS_LOG_INSERT @process_name, @message, null, null, @db_name, @@SPID, null, @params, @user_name, @host_name, 0;
	END
--===============================