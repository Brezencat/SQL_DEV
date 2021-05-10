--MSSQL

-- вывести скрипт процедуры
exec sp_helptext '<название процедуры>';

--перекомпиляция процедуры
exec sp_recompile '<proc_name>';

--перекомпиляция плана запроса
OPTION (RECOMPILE);
OPTION (OPTIMIZE FOR UNKNOWN);

