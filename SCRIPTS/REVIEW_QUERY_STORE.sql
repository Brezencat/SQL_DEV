--запрос планов и текстов запросов из Query Store

SELECT	qsp.plan_id --идентификатор плана в хранилище query store
    ,	CAST(qsp.query_plan as xml) AS query_plan_xml --план в xml формате
    ,	CAST('<?query --' + CHAR(13)+CHAR(10) + REPLACE(REPLACE(qsqt.query_sql_text, '<','&lt;'), '>','&gt;') + CHAR(13)+CHAR(10) + ' --?>' as xml) AS query_sql_text --текст запроса + строка с полной заменой спец.символов xml --REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(qsqt.query_sql_text, '<','&lt;'), '>','&gt;'), '&','&amp;'), '"','&quot;'), '''','&apos;')
    ,	ISNULL(OBJECT_NAME(qsq.object_id), '') AS OBJ_NAME --имя объекта, частью которого является запрос
    ,	qsq.initial_compile_start_time --время первой компиляции
    ,	qsq.last_compile_start_time --время запуска последней компиляции плана
    ,	qsq.last_execution_time --время последнего выполнения запроса
    --,	qsp.is_trivial_plan --признак тривиального плана (0 - нет, 1 - да)
    --,	qsp.is_parallel_plan --признак параллельного плана (0 - нет, 1 - да)
    --,	qsp.is_forced_plan --признак принудительного использования этого плана
    --,	CAST('MS SQL Server v.' as nvarchar(16)) + qsp.engine_version AS engine_version--версия SQL Server
    --,	qsp.compatibility_level --установленный уровень совместимости
FROM sys.query_store_plan AS qsp
INNER JOIN sys.query_store_query AS qsq --в этом представлении инфа по времени компиляции запроса и т.п.
    ON qsq.query_id = qsp.query_id
INNER JOIN sys.query_store_query_text AS qsqt
    ON qsqt.query_text_id = qsq.query_text_id
WHERE 1=1
    --AND qsp.plan_id = ?
    --AND qsqt.query_sql_text like ('%sys.sql_modules%')
;
