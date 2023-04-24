--text vs varchar(n) + TOAST

CREATE DATABASE IF NOT EXISTS _test_storage;


--переключиться на БД _test_storage

--Создаём таблицы с типами колонок text и varchar с указанием длинны. И наполняем их одинаковыми данными 
DROP TABLE IF EXISTS test_datatype_text;

CREATE TABLE test_datatype_text
	(id serial
	,name TEXT
	);

INSERT INTO test_datatype_text
	(name)
SELECT md5(generate_series::text)
FROM pg_catalog.generate_series(1, 120);


DROP TABLE IF EXISTS test_datatype_varchar;

CREATE TABLE test_datatype_varchar
	(id serial
	,name varchar(32)
	);

INSERT INTO test_datatype_varchar
	(name)
SELECT md5(generate_series::text)
FROM pg_catalog.generate_series(1, 120);


--Проверяем количество строк в каждой таблице
SELECT count(*), 'test_datatype_text' AS table_name FROM test_datatype_text
UNION ALL
SELECT count(*), 'test_datatype_varchar' AS table_name FROM test_datatype_varchar;
--count	table_name
--120	test_datatype_text
--120	test_datatype_varchar

--проверяем максимальную и минимальную длину колонок text и varchar(32)
SELECT 'test_datatype_text' AS table_name, MAX(LENGTH(name)) AS MAX_LENGTH, MIN(LENGTH(name)) AS MIN_LENGTH, MAX(bit_length(name)) AS MAX_bit_length, MAX(char_length(name)) AS MAX_char_length, MAX(octet_length(name)) AS MAX_octet_length FROM test_datatype_text
UNION ALL
SELECT 'test_datatype_varchar' AS table_name, MAX(LENGTH(name)) AS MAX_LENGTH, MIN(LENGTH(name)) AS MIN_LENGTH, MAX(bit_length(name)) AS MAX_bit_length, MAX(char_length(name)) AS MAX_char_length, MAX(octet_length(name)) AS MAX_octet_length FROM test_datatype_varchar;
--table_name			max_length	min_length	max_bit_length	max_char_length	max_octet_length
--test_datatype_text	32			32			256				32				32
--test_datatype_varchar	32			32			256				32				32

--взглянем на сами данные и размещение кортежей на страницах
SELECT ctid, * FROM test_datatype_text LIMIT 10;
SELECT ctid, * FROM test_datatype_text OFFSET 115 LIMIT 10;

SELECT ctid, * FROM test_datatype_varchar LIMIT 10;
SELECT ctid, * FROM test_datatype_varchar OFFSET 115 LIMIT 10;

--Проверим соединение таблиц по текстовому полю
SELECT count(*)
FROM test_datatype_text AS t
INNER JOIN test_datatype_varchar AS v 
	ON v.name = t.name
--count
--120
	
--смотрим на физические страницы и строки
SELECT 'test_datatype_text' AS table_name, * FROM page_header(get_raw_page('test_datatype_text', 0));
--table_name			lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--test_datatype_text	3A/4612E5E0	0			0		504		512		8 192	8 192		4		0
SELECT 'test_datatype_varchar' AS table_name, * FROM page_header(get_raw_page('test_datatype_varchar', 0));
--table_name			lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--test_datatype_varchar	3A/46133A48	0			0		504		512		8 192	8 192		4		0

--смотрим знимаемое место только таблицей и таблицей с индексами и попутным
--тут видим, что таблица без ограничения длины занимает больше места, потому что появилась область TOAST
SELECT 'test_datatype_text' AS table_name, pg_size_pretty(pg_relation_size('test_datatype_text')), pg_size_pretty(pg_total_relation_size('test_datatype_text'));
--table_name			pg_size_pretty	pg_size_pretty
--test_datatype_text	8192 bytes		16 kB
SELECT 'test_datatype_varchar' AS table_name, pg_size_pretty(pg_relation_size('test_datatype_varchar')), pg_size_pretty(pg_total_relation_size('test_datatype_varchar'));
--table_name			pg_size_pretty	pg_size_pretty
--test_datatype_varchar	8192 bytes		8192 bytes

--вот таким нехитрым способом находим это попутное
SELECT 	tb.oid 
	,	tb.relname 
	,	tb.relpages 
	,	pg_size_pretty(pg_relation_size(tb.relname::text)) AS table_size
	,	sec.oid
	,	sec.relname
	,	sec.relpages 
	,	pg_size_pretty(pg_total_relation_size(tb.relname::text)) AS table_size
FROM pg_catalog.pg_class AS tb
LEFT JOIN pg_catalog.pg_class AS sec
	ON sec.oid = tb.reltoastrelid 
WHERE tb.relname = 'test_datatype_text'
	OR tb.relname = 'test_datatype_varchar'
;


--А теперь добавим данных, чтобы получить 2 страницы
INSERT INTO test_datatype_text
	(name)
SELECT md5(generate_series::text)
FROM pg_catalog.generate_series(1, 120);


INSERT INTO test_datatype_varchar
	(name)
SELECT md5(generate_series::text)
FROM pg_catalog.generate_series(1, 120);

--проверим, что у нас там в конце таблицы
SELECT ctid, * FROM test_datatype_text ORDER BY id DESC LIMIT 10;
SELECT ctid, * FROM test_datatype_varchar ORDER BY id DESC LIMIT 10;

--смотрим на физические страницы и строки
SELECT 'test_datatype_text' AS table_name, * FROM page_header(get_raw_page('test_datatype_text', 1))
UNION ALL
SELECT 'test_datatype_varchar' AS table_name, * FROM page_header(get_raw_page('test_datatype_varchar', 1));
--table_name			lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--test_datatype_text	3A/46295328	0			0		504		512		8 192		8 192	4		0
--test_datatype_varchar	3A/46298220	0			0		504		512		8 192		8 192	4		0

--смотрим знимаемое место только таблицей и таблицей с индексами и попутным
--увидим, что резервирование идёт только для одной страницы TOAST
SELECT 'test_datatype_text' AS table_name, pg_size_pretty(pg_relation_size('test_datatype_text')), pg_size_pretty(pg_total_relation_size('test_datatype_text'))
UNION ALL
SELECT 'test_datatype_varchar' AS table_name, pg_size_pretty(pg_relation_size('test_datatype_varchar')), pg_size_pretty(pg_total_relation_size('test_datatype_varchar'));
--table_name			pg_size_pretty	pg_size_pretty
--test_datatype_text	16 kB			48 kB
--test_datatype_varchar	16 kB			40 kB

--накинем больших данных, колонку больше 8Кб
--важно, чтобы строка была как можно более уникальной, так как Postgres по умолчанию использует стратегию хранения EXTENDED со сжатием (сначала пытается сжать, а потом уже отправить в TOAST) и например repeat(MD5, 900) не подходил, так как ужимался
INSERT INTO test_datatype_text
	(name)
SELECT string_agg(value,'_')
FROM (
		SELECT sha256(generate_series::TEXT::bytea)::TEXT AS value
		FROM pg_catalog.generate_series(1, 300)
) AS t
;

--а в этом случае ожидаемо получим ошибку: ERROR: value too long for type character varying(32)
INSERT INTO test_datatype_varchar
	(name)
SELECT string_agg(value,'_')
FROM (
		SELECT sha256(generate_series::TEXT::bytea)::TEXT AS value
		FROM pg_catalog.generate_series(1, 300)
) AS t
;

--проверим, что у нас там в конце таблицы
SELECT ctid, * FROM test_datatype_text ORDER BY id DESC LIMIT 10;
--ctid		id	name
--(2,1)		241	\x6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b_..._\x983bd614bb5afece5ab3b6023f71147cd7b6bc2314f9d27af7422541c6558389
--(1,120)	240	da4fb5c6e93e74d3df8527599fa62642

--проверяем максимальную и минимальную длину колоноки text
SELECT 'test_datatype_text' AS table_name, MAX(LENGTH(name)) AS MAX_LENGTH, MIN(LENGTH(name)) AS MIN_LENGTH, MAX(bit_length(name)) AS MAX_bit_length, MAX(char_length(name)) AS MAX_char_length, MAX(octet_length(name)) AS MAX_octet_length FROM test_datatype_text
--table_name			max_length	min_length	max_bit_length	max_char_length	max_octet_length
--test_datatype_text	20 099		32			160 792			20 099			20 099

--смотрим знимаемое место только таблицей и таблицей с индексами и попутным
SELECT 'test_datatype_text' AS table_name, pg_size_pretty(pg_relation_size('test_datatype_text')), pg_size_pretty(pg_total_relation_size('test_datatype_text'));
--table_name			pg_size_pretty	pg_size_pretty
--test_datatype_text	24 kB			112 kB

--смотрим на физические страницы и строки
SELECT 'test_datatype_text' AS table_name, * FROM page_header(get_raw_page('test_datatype_text', 2));
--table_name			lsn			checksum	flags	lower	upper	special	pagesize	version	prune_xid
--test_datatype_text	3A/462FF470	0			0		28		8 144	8 192	8 192		4		0

--гдянем ещё раз на наши таблицы
SELECT 	tb.oid 
	,	tb.relname 
	,	tb.relpages 
	,	pg_size_pretty(pg_relation_size(tb.relname::text)) AS table_size
	,	sec.oid
	,	sec.relname
	,	sec.relpages 
	,	pg_size_pretty(pg_total_relation_size(tb.relname::text)) AS table_size
FROM pg_catalog.pg_class AS tb
LEFT JOIN pg_catalog.pg_class AS sec
	ON sec.oid = tb.reltoastrelid 
WHERE tb.relname = 'test_datatype_text'
	OR tb.relname = 'test_datatype_varchar'
;

--из предыдущего запроса копируем название TOAST таблицы и посмотрим её
SELECT * FROM pg_toast.pg_toast_475897;
--chunk_id - ссылка на значение, подвергнутое TOAST-обработке
--chunk_seq - последовательный номер порции данных, представляющей часть значения
--chunk_data - порция данных (сами данные)

--посмотрим размер больших строк и количесво порций
SELECT chunk_id, count(chunk_seq), pg_size_pretty(sum(octet_length(chunk_data)::bigint)) FROM pg_toast.pg_toast_475897 GROUP BY chunk_id;
--chunk_id	count	pg_size_pretty
--475 908	11		20 kB


--SELECT pg_database_size('_test_storage'), pg_size_pretty(pg_database_size('_test_storage'));