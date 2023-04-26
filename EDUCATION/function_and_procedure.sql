 

 

drop function if exists dbo.f_HELLO

CREATE FUNCTION dbo.f_HELLO ()
RETURNS varchar(30)
AS
BEGIN
	DECLARE @text varchar(30) = 'Марс';
	
	RETURN @text;
END;

GO

select dbo.f_HELLO()
go


declare @MY_TEXT varchar(30) --= dbo.f_HELLO()
select  @MY_TEXT = dbo.f_HELLO()
print @MY_TEXT



CREATE FUNCTION dbo.f_ONLY_DATE (@Date datetime)
RETURNS date
AS
BEGIN
	RETURN CAST(@Date as date);
END;

GO

select dbo.f_ONLY_DATE (getdate()), getdate()

CREATE FUNCTION dbo.f_EOM (@Date datetime)
RETURNS date
AS
BEGIN
	RETURN EOMONTH(@Date);
END;

GO


select dbo.f_EOM (getdate())


CREATE FUNCTION dbo.f_CUSTOMER()
RETURNS TABLE
AS
RETURN 
(
	SELECT	customer_id
		,	customer
		,	dt_created
	FROM dbo.customer
); 
GO

select *
from dbo.f_CUSTOMER()
where customer = dbo.f_HELLO()

 
CREATE FUNCTION dbo.f_CUSTOMER_FILTR (@customer varchar(128))
RETURNS TABLE
AS
RETURN 
(
	SELECT	customer_id
		,	customer
		,	dt_created
	FROM dbo.customer
	WHERE customer = @customer
);
GO

select *
from dbo.f_CUSTOMER_FILTR ('Марс')


CREATE FUNCTION dbo.F_CONTRAGENT_FILTR (@customer varchar(128), @date datetime)
RETURNS TABLE
AS
RETURN 
(
	SELECT	c.contragent
		,	cus.customer
		,	cus.dt_created as dt_cus
		,	c.dt_created as dt_contr
	FROM dbo.customer as cus
	inner join  dbo.contragent as c
		on c.customer_id = cus.customer_id
	WHERE customer = @customer
		and cus.dt_created > @date
);
GO

select *
from dbo.F_CONTRAGENT_FILTR (dbo.f_HELLO(), '20100101')




GO

CREATE PROC dbo.SELECT_CONTRAGENT_FILTR 
		@customer varchar(128)
	,	@date datetime

AS
BEGIN
	SELECT	c.contragent
		,	cus.customer
		,	cus.dt_created as dt_cus
		,	c.dt_created as dt_contr
	FROM dbo.customer as cus
	inner join  dbo.contragent as c
		on c.customer_id = cus.customer_id
	WHERE customer = @customer
		and cus.dt_created > @date;
END


exec dbo.SELECT_CONTRAGENT_FILTR 
	@customer = 'Марс'
	,@date = '20100101'

select contragent
into #TEMP
from dbo.F_CONTRAGENT_FILTR ('Марс', '20100101')

--drop table if exists #TEMP