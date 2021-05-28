--интересный пример на обработку AND и OR (x=1 AND y=1 OR x=2 AND y=2)
--Я думал, судя по доке, что порядок обрадотки предикатов в запросе должен выстроиться так:
-- x=1 and y=1 and y=2 or x=2
-- но на деле (тест ниже) результат одинаковый для:
-- x=1 AND y=1 OR x=2 AND y=2
-- и (x=1 AND y=1) OR (x=2 AND y=2)

USE tempdb;

CREATE TABLE #T1
	(x int
	,y int
	);

INSERT INTO #T1	
	(x,y)
VALUES (1,1), (1,2), (1,3), (2,1), (2,2), (2,3), (3,1), (3,2), (3,3);

--вариант вызовет вопросы
select *
from #T1
where x=1 and y=1 or x=2 and y=2
;

--выделена логика, проще понять, что автор хотел выбрать
select *
from #T1
where (x=1 and y=1) or (x=2 and y=2)
;

--думал, что сервер выстроит в этом порядке запрос
select *
from #T1
where x=1 and y=1 and y=2 or x=2
;
