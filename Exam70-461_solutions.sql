/*задание 1*/
Use TSQL2012

select custid, YEAR(orderdate)
from Sales.Orders
order by 1, 2
;
