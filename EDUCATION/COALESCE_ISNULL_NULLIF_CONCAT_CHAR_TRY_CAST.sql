
drop table if exists #TMP_TEST;

CREATE TABLE #TMP_TEST
	(a tinyint
	,b smallint
	,c int
	,d varchar(25)
	,e datetime
	);

INSERT INTO #TMP_TEST
	(a, b, c, d, e)
VALUES 
	(1, 20, 300, '20210101', getdate());


declare @a tinyint
	,	@b smallint
	,	@c int
	,	@d varchar(25)
	,	@e datetime

SET @a = 1
SET @b = 20
SET @c = 300
SET @d = '20210101'
SET @e = getdate()

SET @a = null
SET @c = null


--select  COALESCE(@a, @b, @c, @d, CAST(@e as varchar(30)))
--	,	ISNULL(@a, @c)

--select 	ISNULL(@a, @d)
--	,	ISNULL(@a, @e)

select  COALESCE(@a, @b, @c, @d, @e)
	,	COALESCE(@a, @e)
	,	COALESCE(@a, @b, @c, @d)
	,	COALESCE(@a, @b, @c)
	,	COALESCE(@a, @c)
	,	COALESCE(@c, @d)
	--,	ISNULL(@a, @e)
	--,	ISNULL(@a, @d)
	,	ISNULL(@c, @d)




select  NULLIF(1,1)
	,	NULLIF(1,2)

select isnull(nullif((select 0), 0), 1)
select 1 / (select 0)
select 1 / ISNULL(NULLIF((select 0), 0), 1)
select CASE WHEN (select 0) = 0
	THEN 1
	ELSE (select 0)
	END




select  a
	,	ISNUMERIC(a)
	,	d
	,	ISNUMERIC(d)
	,	e
	,	ISNUMERIC(e)
from #TMP_TEST

select  ISNUMERIC(@a)
	,	ISNUMERIC(@d)
	,	ISNUMERIC(@e)


select  ISDATE(@a)
	,	ISDATE(@d)
	,	ISDATE(@e)

select  a
	,	ISDATE(a)
	,	d
	,	ISDATE(d)
	,	e
	,	ISDATE(e)
from #TMP_TEST

select  *
from #TMP_TEST
where ISDATE(e) = 0



select 'a' + ' ' + '1' + ' ' + 'b' + ' ' + '2'
	,	CONCAT('a', ' ', '1', ' ', 'b', ' ', '2')


select 'a' + ' ' + '1' + ' ' + 'b' + ' ' + '2' + null
	,	CONCAT('a', ' ', '1', ' ', 'b', ' ', '2', null)


SELECT [lastname]
      ,[firstname]
      ,[middlename]
	  ,[lastname] + ' ' + [firstname] + ' ' + [middlename]
	  ,CONCAT([lastname], ' ', [firstname], ' ', [middlename])
FROM [masterdata].[dbo].[usr]



select 'a' + ' ' + '1' + ' ' + 'b' + ' ' + '2' + CHAR(13) + 'c'
	--,	CHAR(13)
	,	CONCAT('a', ' ', '1', ' ', 'b', ' ', '2', CHAR(13), 'c')




select CAST('a' as int)
select CAST('1' as int)


select TRY_CAST('a' as int)
select TRY_CAST('1' as int)



CREATE TABLE #TMP_TEST
	(a tinyint
	,b smallint
	,c int
	,d varchar(25)
	,e datetime
	);

INSERT INTO #TMP_TEST
	(a, b, c, d, e)
VALUES 
	(1, 20, 300, '20210101', getdate());




--drop table #TMP_TEST
--select 1 as ID
--	,	ISNULL('a', 'b') as [name]
--	,	COALESCE ('a', 'b') as comment
--into #TMP_TEST

--select * from #TMP_TEST

--insert into #TMP_TEST
--	(id, name)
--select 2, 'c'