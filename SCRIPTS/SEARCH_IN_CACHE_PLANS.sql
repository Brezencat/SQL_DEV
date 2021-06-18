--поиск по тексту запроса в кеше планов

SELECT  cp.plan_handle
    ,   st.text  
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text (cp.plan_handle) AS st  
WHERE st.[text] LIKE N'%sql_modules%'
; 