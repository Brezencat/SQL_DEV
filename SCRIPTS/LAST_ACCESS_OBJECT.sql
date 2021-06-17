--Это не 100% способ проверки
--проверяем по статистике обращения к индексу через системное представление sys.dm_db_index_usage_stats


--когда было последнее обращение к вьюхе (к таблицам из вьюхи)

select	'masterdata' as DB_NAME_VIEW
	,	v.[name]
	,	v.create_date
	,	v.modify_date
	--,	DB_NAME(ius.database_id) AS DATABASE_QUERY --из какой базы был запрос (при использовании закоментить outer apply)
	,	oa.LIST_DB_NAME AS DATABASE_QUERY --список баз, из которой был запрос
	,	CAST(MAX(CASE 
				WHEN ISNULL(ius.last_user_seek, '1900-01-01') > ISNULL(ius.last_user_scan, '1900-01-01') 
					THEN CASE 
						WHEN ISNULL(ius.last_user_seek, '1900-01-01') > ISNULL(ius.last_user_lookup, '1900-01-01') THEN ius.last_user_seek
						ELSE ius.last_user_lookup
					END
				ELSE CASE 
						WHEN ISNULL(ius.last_user_scan, '1900-01-01') > ISNULL(ius.last_user_lookup, '1900-01-01') THEN ius.last_user_scan
						ELSE ius.last_user_lookup
					END          
			END) as date) AS last_user_read
	,	CAST(MAX(last_user_update) as date) AS last_user_update
from sys.views as v
left join sys.dm_db_index_usage_stats as ius
	on ius.[object_id] = v.[object_id]
outer apply (select distinct DB_NAME(us.database_id) + ', '
			 from sys.dm_db_index_usage_stats as us
			 where us.[object_id] = v.[object_id]
			 for xml path ('')
			) as oa(LIST_DB_NAME)
group by v.[name]
	,	 v.create_date
	,	 v.modify_date
	--,	 DB_NAME(ius.database_id) --(при использовании закоментить outer apply)
	,	oa.LIST_DB_NAME


