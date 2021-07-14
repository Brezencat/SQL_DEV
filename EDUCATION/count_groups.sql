--пример работы группировки на примере агрегатной функции count()
--пример данных с одинаковыми и разными значениями в колонке
--таблица 1
select *
from (values (1), (2), (1), (2), (1)) as t(c);

---таблица 2
select *
from (values (1), (1), (1), (1), (1)) as t(c);

--подсчёт строк с  группировкой по колонке
select	c
	,	count(*) as cn
from (
		select *
		from (values (1), (1), (1), (1), (1)) as t(c)
) as x
group by c
;

select	c
	,	count(*) as cn
from (
		select *
		from (values (1), (2), (1), (2), (1)) as t(c)
) as x
group by c
;

--подсчёт срок во всей таблице
select	count(*) as cn
from (
		select *
		from (values (1), (1), (1), (1), (1)) as t(c)
) as x
;

select	count(*) as cn
from (
		select *
		from (values (1), (2), (1), (2), (1)) as t(c)
) as x
;
--=====================================================