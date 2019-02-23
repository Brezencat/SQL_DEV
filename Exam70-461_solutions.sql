/*Задание 1*/
Use TSQL2012

select custid, YEAR(orderdate)
from Sales.Orders
order by 1, 2
;

/*Задание 2*/
select DISTINCT custid, YEAR(orderdate) as Year_order
from Sales.Orders
--order by custid, Year_order
;
