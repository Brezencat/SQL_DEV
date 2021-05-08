--MSSQL Server

--вычисление времени
select format(dateadd(ms, datediff(ms, <datetime_column>, <datetime_column>),
convert(datetime2(3), '')), 'HH:mm:ss.fff') as EXECUTION_TIME


