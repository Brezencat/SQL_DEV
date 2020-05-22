CREATE PROC [dbo].[XEVENT_LOG_LOADER]
--declare  
		 @DATE datetime2 = null --для отбора записей по большему (или меньшему) периоду времени, формат datetime2
		,@XEVENT_NAME varchar(255) = null --для запуска по конкретному эвенту
		,@FILE_DIRECTORY varchar(255) = 'C:\Users\MSSQLSERVER\Documents\XEVENT_LOG' --'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\' папка сохранения файлов по умолчанию
		,@view bit = 0 -- 0 - запись в постоянную таблицу, 1 - запись во временную таблицу, null - вывод набора данных (select)

AS

BEGIN TRY
	IF @view = 0
		SET NOCOUNT ON;

	DECLARE	@ROWS int; --для логирования количества строк

	IF @DATE is null
	BEGIN
		select @DATE = CAST(CONVERT(varchar(8), DATEADD(dd, -1, getutcdate()), 112) as datetime2)
	END;

		IF @view = 1
			print 'Дата отбора данных ' + CONVERT(varchar(19), @DATE, 121);

	--список эвентов
	DROP TABLE IF EXISTS #XEVENT_LIST;

	CREATE TABLE #XEVENT_LIST
		( ID_ROW int
		 ,XEVENT_NAME varchar(255)
		);

	IF @XEVENT_NAME is null
	BEGIN
		DECLARE  @S_DATE_TO datetime = getdate();

		EXEC dbo.DIC_DICTIONARY_GET	  @DICTIONARY_NAME = 'Список эвентов для отслеживания'
									, @TABLE_NAME = '#XEVENT_LIST'
									, @DATE = @S_DATE_TO
	END
	ELSE
	BEGIN
		INSERT INTO #XEVENT_LIST (ID_ROW, XEVENT_NAME)
		select   CAST(1 as tinyint) AS ID_ROW
				,XEVENT_NAME
		from dbo.XEVENT_LIST
		where XEVENT_NAME = @XEVENT_NAME;
	END

	--собираем список файлов из дирректории, где хранятся логи эвентов
	DROP TABLE IF EXISTS #ALL_FILE_NAME;

	CREATE TABLE #ALL_FILE_NAME
		( FILE_PATH varchar(255) null
		 ,DEPTH int null
		 ,[file] int null
		);
	INSERT INTO #ALL_FILE_NAME
	EXEC master.sys.xp_dirtree	 @FILE_DIRECTORY --дирректория, где хранятся логи эвентов
								,0 --сколько вложенных уровней отображать (0 - все)
								,1; --отображать (1) файлы в дирректориях или нет (0) 

	--подготовка таблицы для курсора со списком эвентов и их файлов логов
	DROP TABLE IF EXISTS #XEVENT_FILE;

	SELECT	 l.XEVENT_NAME
			,f.FILE_PATH
	into #XEVENT_FILE
	FROM #ALL_FILE_NAME AS f
	INNER JOIN #XEVENT_LIST AS l 
		ON  f.FILE_PATH like l.XEVENT_NAME + '%';

		SET @ROWS = @@ROWCOUNT;
		IF @view = 1
			print 'По какому количеству файлов будем собирать данные = ' + CAST(@ROWS as varchar(10));

	--временная таблица для сбора данных в xml
	DROP TABLE IF EXISTS #XML_DATA;

	CREATE TABLE #XML_DATA
		( XEVENT_NAME 	varchar(255)	NOT NULL --имя эвента
		 ,[EVENT]		varchar(255) 	NOT NULL --имя события
		 ,[UTCDATE]		datetime2 		NOT NULL --дата и время события 
		 ,[VALUE] 		XML 			NOT NULL --xml с данными события
		);

	IF @view is null
	BEGIN
		DROP TABLE IF EXISTS #XML_BUFFER;

		CREATE TABLE #XML_BUFFER
			( XEVENT_NAME 	varchar(255)	NOT NULL --имя эвента
			 ,[EVENT]		varchar(255) 	NOT NULL --имя события
			 ,[UTCDATE]		datetime2 		NOT NULL --дата и время события 
			 ,[VALUE] 		XML 			NOT NULL --xml с данными события
			);
	END

	DECLARE @FILE_PATH varchar (255); -- переменная для пути к файлу

	DECLARE CUR CURSOR
	FOR	select	 XEVENT_NAME
				,FILE_PATH
		from #XEVENT_FILE

	OPEN CUR
	FETCH NEXT FROM CUR INTO @XEVENT_NAME, @FILE_PATH;

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		TRUNCATE TABLE #XML_DATA;
		DROP TABLE IF EXISTS #RESULT;

		INSERT INTO #XML_DATA
			( XEVENT_NAME
			 ,[EVENT]
			 ,[UTCDATE]
			 ,[VALUE]
			)
		SELECT	 @XEVENT_NAME AS XEVENT_NAME
				,[object_name] AS [EVENT]
				,CAST(timestamp_utc as datetime2) AS [UTCDATE]
				,CAST(event_data as XML) AS [VALUE]
				--,[file_name]
		FROM sys.fn_xe_file_target_read_file (@FILE_DIRECTORY + '\' + @FILE_PATH, null, null, null)
		WHERE CAST(timestamp_utc as datetime2) >= @DATE;
		
			set @ROWS = @@ROWCOUNT;
			IF @view = 1
				print 'Сколько строк вытащили из файла ' + CAST(@FILE_PATH as varchar(255)) + ' = ' + CAST(@ROWS as varchar(10));

		SELECT   d.XEVENT_NAME
				,d.[EVENT]
				,d.[UTCDATE]
				,d.[VALUE]
		into #RESULT
		FROM #XML_DATA AS d
		LEFT JOIN dbo.XEVENT_XML_BUFFER AS l ON not exists (select d.XEVENT_NAME, d.[EVENT], d.[UTCDATE]
															except
															select l.XEVENT_NAME, l.[EVENT], l.[UTCDATE])
		WHERE l.XEVENT_NAME is null;

			set @ROWS = @@ROWCOUNT;
			IF @view = 1
				print 'Сколько новых данных = ' + CAST(@ROWS as varchar(10));
		
		TRUNCATE TABLE #XML_DATA;

		--вставка в основную таблицу
		IF @view = 0
		BEGIN
			INSERT INTO dbo.XEVENT_XML_BUFFER
					( XEVENT_NAME
					 ,[EVENT]
					 ,[UTCDATE]
					 ,[VALUE]
					)
			SELECT   XEVENT_NAME
					,[EVENT]
					,[UTCDATE]
					,[VALUE]
			FROM #RESULT;
		END
		ELSE
		BEGIN
			INSERT INTO #XML_BUFFER
					( XEVENT_NAME
					 ,[EVENT]
					 ,[UTCDATE]
					 ,[VALUE]
					)
			SELECT   XEVENT_NAME
					,[EVENT]
					,[UTCDATE]
					,[VALUE]
			FROM #RESULT;
		END;

		FETCH NEXT FROM CUR INTO @XEVENT_NAME, @FILE_PATH;
	END
	CLOSE CUR;
	DEALLOCATE CUR;

	DROP TABLE IF EXISTS #XML_DATA;
	DROP TABLE IF EXISTS #RESULT;

	IF @view is null
	BEGIN
		SELECT   ROW_NUMBER() OVER (ORDER BY XEVENT_NAME, [UTCDATE]) AS ID
				,XEVENT_NAME
				,[EVENT]
				,[UTCDATE]
				,[VALUE]
		FROM #XML_BUFFER;

	END;
		
END TRY
BEGIN CATCH
	;THROW
	--exec UTILITY.dbo.Catch;
END CATCH
;