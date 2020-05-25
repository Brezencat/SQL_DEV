--* Настройку XEvent осуществляют Администраторы сервера.
--* Нам должны сообщить путь, куда настроено сохранение файла лога эвента  
--* Для оборботки файла лога используется процедура XEVENT_LOG_LOADER, котрая по умолчанию запускается каждый день с датой сбора данных -1 день.
--* Важно! В эвентах используется дата в формате UtC +0
--* Так же процедура запускается с заданными параметрами и режимами работы.
--* Описание параметров и режимов работы указано в параметрах процедуры.
--* Процедура накапливает данные в буферной таблице XEVENT_XML_BUFFER, затем из этой таблицы данные обрабатываются процедурой XEVENT_LOG_LOADER и удаляются (только в режиме записи в постоянную таблицу).

CREATE PROC [dbo].[XEVENT_LOG_LOADER]
--declare  
		 @DATE datetime2 = null --для отбора записей по большему (или меньшему) периоду времени, формат datetime2. Если указана дата, то отбор записей будет производиться от неё до текущего момента.
		,@XEVENT_NAME varchar(255) = null --для запуска по конкретному эвенту. Если указано название XEvent, то процедура будет работать только по указанному эвенту.
		,@FILE_DIRECTORY varchar(255) = 'C:\Users\MSSQLSERVER\Documents\XEVENT_LOG' --Путь к месту хранения файла лога эвента. Используется для получения списка файлов логов эвента и для дальнейшего указания, где эти файлы искать для преобразования данных в XML отчёт. По умолчанию SQL Server сохраняет логи во внутреннюю дирректорию: 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Log\' и там же ищет файлы по маске, если не указан путь.
		,@view bit = 0 -- Режим работы процедуры: 0 - запись в постоянную таблицу, 1 - запись во временную таблицу (требуется для запуска XEVENT_XML_VIEWER в режиме просмотра данных), null - вывод набора данных (select)

AS

BEGIN TRY
	IF @view = 0
		SET NOCOUNT ON;

	DECLARE	@ROWS int; --для логирования количества строк

	IF @DATE is null --если дата не указана, то отбираем данные на дату Т-1 от UTC+0 (сервера)
	BEGIN
		select @DATE = CAST(CONVERT(varchar(8), DATEADD(dd, -1, getutcdate()), 112) as datetime2)
	END;

		IF @view is null
			print 'Дата отбора данных ' + CONVERT(varchar(19), @DATE, 121);

	--таблица со списком эвентов, по которым булем собирать данные
	DROP TABLE IF EXISTS #XEVENT_LIST;

	CREATE TABLE #XEVENT_LIST
		( ID_ROW int
		 ,XEVENT_NAME varchar(255)
		);

	IF @XEVENT_NAME is null --если в параметрах запуска не указано название XEvent, то собираем список из справочника
	BEGIN
		DECLARE  @S_DATE_TO datetime = getdate(); --??? убрать дату совсем или поставить сценарную

		EXEC dbo.DIC_DICTIONARY_GET	  @DICTIONARY_NAME = 'Список эвентов для отслеживания'
									, @TABLE_NAME = '#XEVENT_LIST'
									, @DATE = @S_DATE_TO
	END
	ELSE
	BEGIN
		DECLARE @RUN_XEVENT_NAME varchar(255); --эта переменная нужна, потому что в курсоре сбор данных идёт по названию эвента и имени файла и переменная @XEVENT_NAME на выходе всегда имеет значение, что создаёт сложности при работе процедуры в режиме промотра данных (view)

		SET @RUN_XEVENT_NAME = @XEVENT_NAME

		INSERT INTO #XEVENT_LIST (ID_ROW, XEVENT_NAME)
		VALUES (CAST(1 as tinyint), @RUN_XEVENT_NAME);
	END

	--собираем список файлов из дирректории, где хранятся логи эвентов
	--системная процедура sys.xp_dirtree возвращает список файлов из переданной ей дирректории. Так же может работать в нескольких режимах (описаны у соответсвующих параметров)
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
	--Отфильтровываем список файлов (по названиями) из дирректории по списку эвентов из справочника 
	DROP TABLE IF EXISTS #XEVENT_FILE;

	SELECT	 l.XEVENT_NAME
			,f.FILE_PATH
	into #XEVENT_FILE
	FROM #ALL_FILE_NAME AS f
	INNER JOIN #XEVENT_LIST AS l 
		ON  f.FILE_PATH like l.XEVENT_NAME + '%';

		SET @ROWS = @@ROWCOUNT;
		IF @view is null
			print 'По какому количеству файлов будем собирать данные = ' + CAST(@ROWS as varchar(10));

	--временная таблица для сбора данных в xml и сравнения с существующими данными в буферной таблице
	DROP TABLE IF EXISTS #XML_DATA;

	CREATE TABLE #XML_DATA
		( XEVENT_NAME 	varchar(255)	NOT NULL --имя эвента
		 ,[EVENT]		varchar(255) 	NOT NULL --имя события
		 ,[UTCDATE]		datetime2 		NOT NULL --дата и время события 
		 ,[VALUE] 		XML 			NOT NULL --xml с данными события
		);

	IF @view is null --для режима просмотра данных создаём отдельную таблицу
	BEGIN
		DROP TABLE IF EXISTS #XML_BUFFER;

		CREATE TABLE #XML_BUFFER
			( ID			int			
			 ,XEVENT_NAME 	varchar(255)
			 ,[EVENT]		varchar(255)
			 ,[UTCDATE]		datetime2
			 ,[VALUE] 		XML	
			);
	END;

	DECLARE  @FILE_PATH varchar (255); --будет указываться имя файла лога

--Курсор для сбора данных из файла лога по названию эвента и имени его файла лога
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

--формирование и запись во временную таблицу XML отчета из файла лога
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
		FROM sys.fn_xe_file_target_read_file (@FILE_DIRECTORY + '\ ' + @FILE_PATH, null, null, null)
		WHERE CAST(timestamp_utc as datetime2) >= @DATE;
		
			set @ROWS = @@ROWCOUNT;
			IF @view is null
				print 'Сколько строк вытащили из файла ' + CAST(@FILE_PATH as varchar(255)) + ' = ' + CAST(@ROWS as varchar(10));

--если данные не записывались ранее, то сохраняем их во временную таблицу для дальнейшей записи в буферную таблицу.
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
			IF @view is null
				print 'Сколько новых данных = ' + CAST(@ROWS as varchar(10));
		
		TRUNCATE TABLE #XML_DATA;

--в зависимости от режима производим сохранение данных в основную таблицу или запись во временную таблицу для дальнейщшей обработки
--Было принято решение делать запись в основную таблицу сразу же после обработки одного из файлов лога, так как могут возникать проблемы с переполнением tempdb во время чтения объёмных файлов логов эвента
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

--для режима просмотра и записи во временную таюлицу производим дополнительную обработку данных
	IF @view is null or @view = 1
	BEGIN
		IF NOT EXISTS (select TOP(1) 1 from #XML_BUFFER) --если во времянку не набрались новые записи (ранее были сохранены), то возьмём их по дате и, опционально, по названию эвента из буфера
		BEGIN
			DECLARE @sql nvarchar(4000);

			SET @sql = 'SELECT	 ID
								,XEVENT_NAME
								,[EVENT]
								,UTCDATE
								,[VALUE]
						FROM dbo.XEVENT_XML_BUFFER
						WHERE UTCDATE >= @DATEFROM';

			IF @RUN_XEVENT_NAME is not null
			BEGIN
				SET @sql = @sql + ' and XEVENT_NAME = ' + '''' + @RUN_XEVENT_NAME + '''';
			END;

			IF @view = 1 --для режима записи во времянку наполняем её из буфера с сохранение ID
			BEGIN
				INSERT INTO #XML_BUFFER
					( ID
					 ,XEVENT_NAME
					 ,[EVENT]
					 ,[UTCDATE]
					 ,[VALUE]
					)
				EXEC sp_executesql @sql
					,N'@DATEFROM datetime2'
					,@DATE;
			END
			ELSE --для режима просмотра сделаем просто запрос данных из буфера, если времянка пустая
			BEGIN 
				EXEC sp_executesql @sql
					,N'@DATEFROM datetime2'
					,@DATE;				
			END;
		END
		ELSE
		BEGIN
			IF @view is null --если времянка не пустая и режим просмотра, то выводим запрос из неё c нумерацией строк
			BEGIN
				SELECT   ROW_NUMBER() OVER (ORDER BY XEVENT_NAME, [UTCDATE]) AS ID
						,XEVENT_NAME
						,[EVENT]
						,[UTCDATE]
						,[VALUE]
				FROM #XML_BUFFER;
			END;
		END;
	END;
		
END TRY
BEGIN CATCH
	;THROW
	--exec UTILITY.dbo.Catch;
END CATCH
;