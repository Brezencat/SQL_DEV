--Проверка существования столбца в таблице
--Несколько вариантов

--1. указываем ID таблицы через функцию и имя столбца
IF EXISTS (select 1 from sys.all_columns where object_id = OBJECT_ID('sys.schemas') and [name] = 'name')
BEGIN
	print 1;
END;

--2. указываем название таблицы и столбца
IF COL_LENGTH('sys.schemas', 'name') IS NOT NULL
BEGIN
	print 1;
END;

--3. указываем название таблицы и ID стоблца
IF COL_NAME(OBJECT_ID('sys.schemas'), 1) IS NOT NULL
BEGIN
	print 1;
END;

--4. указываем ID таблицы через функцию, имя столбца и какое его свойство вывести
IF COLUMNPROPERTY(OBJECT_ID('sys.schemas'),'name','Columnid') IS NOT NULL
BEGIN
	print 1;
END;

--5. Через уставревшее представление, Майскрософт не рекомендует использовать представления из схемы INFORMATION_SCHEMA и заменять их системаными представляениями, как в первом варианте. Также тут отсутсвуют системные таблицы
IF EXISTS (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_CATALOG = DB_NAME() and TABLE_NAME = 'sys.schemas' and COLUMN_NAME = 'name')
BEGIN
	print 1;
END;

--Посмореть, что же возвращают фугкции:
select	COL_LENGTH('sys.schemas', 'name') --длина столбца
	,	COL_NAME(OBJECT_ID('sys.schemas'), 1) --название столбца
	,	COLUMNPROPERTY(OBJECT_ID('sys.schemas'),'name','Columnid') --можно возвращать свойства из sys.columns
;
