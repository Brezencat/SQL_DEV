--тип данных флоат и работа с экпонентой

--2.3214052E7 число с экспонентой
	select	2.3214052E7 AS 'AUTO TYPE'
		,	CAST(2.3214052E7 as float(24)) AS 'float(24)'
		,	CAST(2.3214052E7 as float(53)) AS 'float(53)'

--итоговое число из экспоненты, 2.3214052 * 10 в 7 степени
	declare @float24 float(24) --4 байта 7 цифр
		,	@float53 float(53); --8 байт 15 цифр

	set @float24 = 23214052;
	set @float53 = 23214052;

	select	@float24 AS '@float24'
		,	@float53 AS '@float53';


GO

--232140.51 получение той самой экспоненты из числа (перевод рублей в копейки)
	select	232140.51 * 100 AS 'AUTO TYPE'
		,	CAST(232140.51 * 100 as float(24)) AS 'float(24)'
		,	CAST(232140.51 * 100 as float(53)) AS 'float(53)'

	declare @float24 float(24)
		,	@float53 float(53);

	set @float24 = 232140.51 * 100;
	set @float53 = 232140.51 * 100;

	select	@float24 AS '@float24'
		,	@float53 AS '@float53';



--сравнение с типом decimal и внимание на отсечение знаков после запятой, если там нули
select	CAST(100.00 as float) AS 'float'
	,	CAST (100 as decimal(5,2)) AS 'decimal'