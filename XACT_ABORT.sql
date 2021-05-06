--MSSQL Server

--определение set xact_abort on;

DECLARE @XACT_ABORT VARCHAR(3) = 'OFF';

--16384 = значение параметра user options для xact_abort
--@@OPTIONS возвращает битовую маску в десятиричной системе
IF ( (16384 & @@OPTIONS) = 16384 )
	SET @XACT_ABORT = 'ON';

SELECT @XACT_ABORT AS [XACT_ABORT];