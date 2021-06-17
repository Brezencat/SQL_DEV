--Это не 100% способ проверки
--проверяем по статистике обращения к индексу через системное представление sys.dm_db_index_usage_stats


--когда было последнее обращение к вьюхе (к таблицам из вьюхи)

SELECT	v.[name]
    ,	v.create_date
    ,	v.modify_date
    ,	DB_NAME(ius.database_id) AS [DATABASE] --из какой базы был запрос
    ,	MAX(CASE 
                WHEN ISNULL(ius.last_user_seek, '1900-01-01') > ISNULL(ius.last_user_scan, '1900-01-01') 
                    THEN CASE 
                        WHEN ISNULL(ius.last_user_seek, '1900-01-01') > ISNULL(ius.last_user_lookup, '1900-01-01') THEN ius.last_user_seek
                        ELSE ius.last_user_lookup
                    END
                ELSE CASE 
                        WHEN ISNULL(ius.last_user_scan, '1900-01-01') > ISNULL(ius.last_user_lookup, '1900-01-01') THEN ius.last_user_scan
                        ELSE ius.last_user_lookup
                    END          
            END) AS last_user_read
    ,	MAX(last_user_update) AS last_user_update
FROM sys.views AS v
LEFT JOIN sys.dm_db_index_usage_stats AS ius
    ON ius.[object_id] = v.[object_id]
GROUP BY v.[name]
    ,	 v.create_date
    ,	 v.modify_date
    ,	 DB_NAME(ius.database_id)
ORDER BY last_user_read
    ,	v.[name]


