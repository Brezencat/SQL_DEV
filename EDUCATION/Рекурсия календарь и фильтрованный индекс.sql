--диапазоны дат отбирал по 50 лет, 100 лет не влезают в 32000
with CTE as
(
	SELECT CAST('19000101' as smalldatetime) as DT
	union all
	SELECT DATEADD(dd, 1, c.DT) as DT
	FROM CTE as c
	WHERE c.DT<'20790606'
) 
--INSERT INTO dbo.DATEWEEK ([DATE],DayWeek,[WEEK])
select  CAST(DT as date) as [DATE], 
		DATEPART(dw, DT) as DayWeek, 
		CASE when DATEPART(dw, DT) in (6,7)
			 then 1
			 else 0
		END as [WEEK]
into dbo.DATEWEEK   -- !!!!! таблица не временная !!!!!
from CTE
option(MAXRECURSION 32000);

--Фильтрованный индекс (не временный)
CREATE NONCLUSTERED INDEX INX_DATEWEEK_DATE ON dbo.DATEWEEK ([DATE]) where [WEEK] = 1;

--SET STATISTICS IO, TIME ON
--DBCC DROPCLEANBUFFERS
select [DATE]
from dbo.DATEWEEK
where [WEEK] = 1
	and [DATE] between '20200101' and '20201231'
;
--drop index INX_DATEWEEK_DATE ON dbo.DATEWEEK

-- alter table dbo.DATEWEEK
-- alter column DayWeek TINYINT not null;
-- GO
-- alter table dbo.DATEWEEK
-- alter column [WEEK] bit not null;


--На постоянку таблицу с календарём
CREATE TABLE dbo.DATEWEEK
    ([DATE]     DATE    not null
    ,DAYWEEK    TINYINT not null 
    ,[WEEK]     BIT     not null
    );
--можно добавить интовое значение даты ID_DATE использовать CAST(CAST([DATE] as varchar(10)) as int)