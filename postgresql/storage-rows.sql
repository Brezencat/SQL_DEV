--Как Postgres хранит строки

CREATE DATABASE _test_storage;


--переключиться на БД _test_storage

CREATE EXTENSION pageinspect; --активируем модуля


--начало тестов
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

SELECT ctid, * FROM test_page_storage LIMIT 10;
SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,119)	119	07e1cd7dca89a1678042477183b7ac3f
--(0,120)	120	da4fb5c6e93e74d3df8527599fa62642

--проверяем страницу, которую заняли
SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn				checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460D5118		0			0		504		512		8 192	8 192		4		0


--удалим одну запись и посмотрим на номер страницы и  номер кортежа, ничего не изменится, только пропадёт запись
DELETE FROM test_page_storage
WHERE id = 119;

SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,120)	120	da4fb5c6e93e74d3df8527599fa62642

SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460D5118	0			0		504		576		8 192	8 192		4		0


--вставляем новую запись, которая встанет на эту же страницу, но с новым номером кортежа
INSERT INTO test_page_storage
	(name)
SELECT md5('119'::text);

SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,120)	120	da4fb5c6e93e74d3df8527599fa62642
--(0,121)	121	07e1cd7dca89a1678042477183b7ac3f

SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460D5218	0			0		508		512		8 192	8 192		4		0

VACUUM FULL test_page_storage;

--после vacuum физические строки изменили порядковые номера
SELECT ctid, * FROM test_page_storage OFFSET 115 LIMIT 10;
--ctid		id	name
--(0,118)	118	5ef059938ba799aaa845e1c2e8a762bd
--(0,119)	120	da4fb5c6e93e74d3df8527599fa62642
--(0,120)	121	07e1cd7dca89a1678042477183b7ac3f

--видим, что указатели строк (lower) на странице тоже почистились
SELECT * FROM page_header(get_raw_page('test_page_storage', 0));
--lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--3A/460F5BC0	0			0		504		512		8 192	8 192		4		0


