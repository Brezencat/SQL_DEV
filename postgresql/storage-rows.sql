--Как Postgres хранит строки на физическом уровне (для таблицы кучи)
--Важно!!! Функции из используемого модуля могут запускаться только суперпользователем.
--по мотивам статьи https://habr.com/ru/companies/otus/articles/699812/


--создадим тестовую БД для экспериментов
CREATE DATABASE IF NOT EXISTS _test_storage;


--!нужно переключиться на БД _test_storage


--активируем модуль для исследования страниц базы данных
CREATE EXTENSION pageinspect; 
--функции, которые будем использовать:
--get_raw_page(relname text, blkno int) returns bytea - позволяет получить одну согласованную во времени копию блока
--page_header(page bytea) returns record - возвращает заголовок страницы. 

--Описание колонок заголовка страницы: https://postgrespro.ru/docs/postgresql/15/storage-page-layout
--lsn - 8 байт - следующий байт после последнего байта записи xlog для последнего изменения на этой странице
--checksum - 2 байта - контрольная сумма страницы
--flags - 2 байта - биты признаков
--lower - 2 байта - смещение до начала свободного пространства (занимается указателями на кортеж lp(...))
--upper - 2 байта - смещение до конца свободного пространства (занмается самими данными row(...))
--special - 2 байта - смещение до начала специального пространства
--pagesize - 2 байта - информация о размере страницы
--version - 2 байта - информация о номере версии компоновки
--prune_xid - 4 байта - самый старый неочищенный идентификатор XMAX на странице или ноль при отсутствии такового

--начало тестов
--создадим пустую таблицу
DROP TABLE IF EXISTS test_page_storage;

CREATE TABLE test_page_storage
	(id serial
	,name TEXT
	);

--занимаем ровно одну страницу данными
INSERT INTO test_page_storage
	(name)
SELECT md5(generate_series::text)
FROM pg_catalog.generate_series(1, 120);

--теперь посмотрим на перые и последние 10 строк и их распределение на странице с помощью системного столбца ctid
--первое значение в колонке ctid означает номер страницы, второе - номер кортежа на этой странице
SELECT ctid, * FROM test_page_storage LIMIT 10;
SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,119)	119	07e1cd7dca89a1678042477183b7ac3f
--(0,120)	120	da4fb5c6e93e74d3df8527599fa62642

--Посмотрим на занятую страницу с помощью функций из модуля pageinspect
SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn				checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460D5118		0			0		504		512		8 192	8 192		4		0


--удалим одну запись и снова посмотрим на информацию о странице
DELETE FROM test_page_storage
WHERE id = 119;

SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,120)	120	da4fb5c6e93e74d3df8527599fa62642

--увидем, что место освободилось и кортеж пропал (колонка upper), но указатель на кортеж (lp(...)) остался и занимает место (колонка lower)
SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460D5118	0			0		504		576		8 192	8 192		4		0


--вставляем новую запись, которая встанет на эту же страницу (так как достаточно метса для размещения строки целиком), но с новым номером кортежа
INSERT INTO test_page_storage
	(name)
SELECT md5('119'::text);

SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,120)	120	da4fb5c6e93e74d3df8527599fa62642
--(0,121)	121	07e1cd7dca89a1678042477183b7ac3f

--виддим, что добавился новый указатель на кортеж (lower) и сами данные (upper)
SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460D5218	0			0		508		512		8 192	8 192		4		0


--запустим процесс сборки мусора и высвобождения пространста
--именно VACUUM FULL переписывает всё содержимое таблицы в новый файл на диске и возвращает операционной системе высвобожденное пространство
VACUUM FULL test_page_storage;

--после vacuum физические строки (кортежи) изменили порядковые номера
--произошло полное перестроение таблицы
SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,119)	120	da4fb5c6e93e74d3df8527599fa62642
--(0,120)	121	07e1cd7dca89a1678042477183b7ac3f

--видим, что указатели строк (lower) на странице тоже почистились
SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460F5BC0	0			0		504		512		8 192	8 192		4		0

--окончание тестов
