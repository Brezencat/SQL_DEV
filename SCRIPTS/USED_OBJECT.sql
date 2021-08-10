--Описание. Процедура поиска объекта или использования объекта в скриптах.
--работает в двух режимах:
--парамерт @mode = 0 - поиска объекта (таблицы, представления, функции, процедуры и т.п.) на сервере по всем БД
--параметр @mode = 1 - выводит, где используется объект в скриптах

CREATE PROC dbo.USED_OBJECT
--declare
        @search_obj_name varchar(255) --название (или часть названия) объектра, который ищем
    ,	@mode bit = 1 --признак поиска объекта или использования объекта в коде. 0 - поиск объекта, 1 - поиск, где используется объект

AS
BEGIN TRY

    DECLARE @i tinyint = 1 --число итераций для цикла
        ,	@dbname varchar(255) --имя БД, в которой производится поиск
        ,	@sql varchar(1000); --скрипт, который формируется для поиска

--собираем список баз данных текущего сервера (исключаем служебные БД)
    DROP TABLE IF EXISTS #list_db;

    SELECT	ROW_NUMBER() OVER (ORDER BY database_id) AS num
        ,	[name]
    into #list_db
    FROM sys.databases 
    WHERE [name] not in ('master', 'tempdb', 'model', 'msdb');

--временная таблица для сбора результатов поиска
    DROP TABLE IF EXISTS #OBJECT_USE;

    CREATE TABLE #OBJECT_USE
        (DBNAME varchar(255)
        ,OBJ_NAME varchar(511)
        ,OBJ_TYPE varchar(255)
        );

--поиск и сбор результатов
    WHILE @i <= (select count(*) from #list_db)
    BEGIN
        SELECT @dbname = [name]
        FROM #list_db
        WHERE num = @i;

        IF @mode = 1
        BEGIN
            SET @sql =
                'select	''' + @dbname + ''' as dbname
                    ,	s.name + ''.'' + o.name as obj_name
                    ,	o.type_desc
                from [' + @dbname + '].sys.sql_modules as sm
                inner join [' + @dbname + '].sys.all_objects as o
                    on o.object_id = sm.object_id
                inner join [' + @dbname + '].sys.schemas as s
                    on s.schema_id = o.schema_id
                where [definition] like ''%' + @search_obj_name + '%''';
        END
        ELSE IF @mode = 0
        BEGIN
            SET @sql =
                'select	''' + @dbname + ''' as dbname
                    ,	s.name + ''.'' + o.name as obj_name
                    ,	o.type_desc
                from [' + @dbname + '].sys.all_objects as o
                inner join [' + @dbname + '].sys.schemas as s
                    on s.schema_id = o.schema_id
                where o.[name] like ''%' + @search_obj_name + '%''';
        END
        ELSE
            BREAK;

        INSERT INTO #OBJECT_USE
            (DBNAME, OBJ_NAME, OBJ_TYPE)
        EXEC (@sql);

        SET @i += 1;
    END;

--вывод результата
    SELECT DBNAME, OBJ_NAME, OBJ_TYPE FROM #OBJECT_USE;

END TRY
BEGIN CATCH
    THROW;
END CATCH;