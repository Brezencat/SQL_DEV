
USE TEMPDB
;
--просто пример джойнов (дублей в таблицах нет)
--создание тестовых данных
DROP TABLE IF EXISTS #TABLE1;

CREATE TABLE #TABLE1
	(id int
	);

INSERT INTO #TABLE1
VALUES 
	 (1)
	,(2)
	,(3)
;

DROP TABLE IF EXISTS #TABLE2;

CREATE TABLE #TABLE2
	(id int
	);

INSERT INTO #TABLE2
VALUES 
	 (2)
	,(3)
	,(4)
	,(5)
;

--соединения

select t1.id as inner_join, t2.id
from #TABLE1 as t1
inner join #TABLE2 as t2
	on t2.id = t1.id
;

select t1.id as left_join, t2.id
from #TABLE1 as t1
left join #TABLE2 as t2
	on t2.id = t1.id
;

select t1.id as right_join, t2.id
from #TABLE1 as t1
right join #TABLE2 as t2
	on t2.id = t1.id
;

select t1.id as full_join, t2.id
from #TABLE1 as t1
full join #TABLE2 as t2
	on t2.id = t1.id
;

select t1.id as cross_join, t2.id
from #TABLE1 as t1
cross join #TABLE2 as t2
;

--Первое задание
--подумать, сколько максимум и минимум строк может вернуть каждый вид соединения (join) при условииотсутсвия дублей в таблицах

--почистить за собой
DROP TABLE IF EXISTS #TABLE1;
DROP TABLE IF EXISTS #TABLE2;

GO

--Второе задание
--посмотреть, что возвращает каздый вид соединения и почему так?

USE TEMPDB
;
--создание тестовых данных
DROP TABLE IF EXISTS #TABLE3;

CREATE TABLE #TABLE3
	(id int
	);

INSERT INTO #TABLE3
VALUES 
	 (1)
	,(1)
	,(2)
;

DROP TABLE IF EXISTS #TABLE4;

CREATE TABLE #TABLE4
	(id int
	);

INSERT INTO #TABLE4
VALUES 
	 (1)
	,(1)
	,(2)
	,(3)
;


--запросы

select t1.id as inner_join, t2.id
from #TABLE3 as t1
inner join #TABLE4 as t2
	on t2.id = t1.id
;

select t1.id as left_join, t2.id
from #TABLE3 as t1
left join #TABLE4 as t2
	on t2.id = t1.id
;

select t1.id as right_join, t2.id
from #TABLE3 as t1
right join #TABLE4 as t2
	on t2.id = t1.id
;

select t1.id as full_join, t2.id
from #TABLE3 as t1
full join #TABLE4 as t2
	on t2.id = t1.id
;

select t1.id as cross_join, t2.id
from #TABLE3 as t1
cross join #TABLE4 as t2
;


--почистить за собой
DROP TABLE IF EXISTS #TABLE3;
DROP TABLE IF EXISTS #TABLE4;

GO