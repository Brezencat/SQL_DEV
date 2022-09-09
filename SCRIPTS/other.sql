--MSSQL

-- вывести скрипт процедуры
exec sp_helptext '<название процедуры>';

--перекомпиляция процедуры
exec sp_recompile '<proc_name>';

--перекомпиляция плана запроса
OPTION (RECOMPILE);
OPTION (OPTIMIZE FOR UNKNOWN);


--ошибки джобов
EXEC dbo.sp_help_jobhistory
;


--запуск запроса от имени другого пользователя в MS SQL Server
SELECT SUSER_NAME(), USER_NAME(); 

EXECUTE AS LOGIN = '<user_name>';

SELECT SUSER_NAME(), USER_NAME(); 

REVERT;
