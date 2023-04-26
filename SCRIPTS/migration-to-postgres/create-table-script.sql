DECLARE @source_table_name varchar(128) = 'buf_realization';

--времянка для типов данных
DECLARE @data_type TABLE
	(ms_sql varchar(128)
	,postgresql varchar(128)
	);

--сопоставленные типы
INSERT INTO @data_type
	(ms_sql, postgresql)
VALUES 
     ('bigint','int8')
    ,('binary','bytea')
    ,('varbinary','bytea')
    ,('rowversion','bytea')
    ,('image','bytea')
    ,('fieldhierarchyid','bytea')
    ,('bit','boolean')
    ,('char','text')
    ,('nchar','text')
    ,('varchar','varchar')
    ,('nvarchar','nvarchar')
    ,('text','text')
    ,('ntext','text')
    ,('float','float8')
    ,('smallmoney','money')
    ,('money','money')
    ,('int','int4')
    ,('smallint','int2')
    ,('numeric','numeric')
    ,('decimal','decimal')
    ,('tinyint','int2')
    ,('real','float4')
    ,('uniqueidentifier','uuid')
    ,('date','date')
    ,('time','time')
    ,('datetime','timestamp(3)')
    ,('datetime2','timestamp(3)')
    ,('datetimeoffset','timestamptz')
    ,('smalldatetime','timestamp(0)')
    ,('xml','xml')
    ,('json','json');

--сбор данных и сопоставление
WITH CTE AS
(
    SELECT	o.[name] AS TABLE_NAME
        ,	c.[name] AS COLUMN_NAME
        ,	t.[name] + 
            CASE 
                WHEN c.max_length = -1 THEN '(MAX)' 
                WHEN t.[name] in ('nvarchar', 'nchar') THEN '(' + ISNULL(CAST(c.max_length / 2 as nvarchar),'') + ')'
                WHEN t.[name] in ('bigint', 'int', 'smallint', 'tinyint', 'bit', 'uniqueidentifier', 'datetime') THEN ''
                WHEN t.[name] = 'decimal' THEN '(' + CAST(c.precision as nvarchar(3)) + ',' + CAST(c.scale as nvarchar(3)) + ')'
                ELSE ISNULL('(' + CAST(c.max_length as nvarchar) + ')','') 
            END AS DATA_TYPE
        ,	IIF(c.is_nullable = 0, 'not null', 'null') AS NULLABLE
        ,	dt.postgresql + 
            CASE
                WHEN dt.postgresql in ('decimal', 'numeric') THEN '(' + CAST(c.precision as nvarchar(3)) + ',' + CAST(c.scale as nvarchar(3)) + ')'
                ELSE '' 
            END AS DATA_TYPE_PGSQL
    FROM sys.objects AS o
    INNER JOIN sys.all_columns AS c
        ON c.object_id = o.object_id
    INNER JOIN sys.types AS t
        ON t.user_type_id = c.user_type_id
    LEFT JOIN @data_type AS dt
        ON dt.ms_sql = t.name
    WHERE o.[name] = @source_table_name
)
--компановка
, CTE2 AS 
(
    SELECT	TABLE_NAME
        ,	CONCAT(', ', LOWER(COLUMN_NAME), ' ', DATA_TYPE_PGSQL, ' ', NULLABLE, CHAR(10)) AS COLUMN_SCRIPT
    FROM CTE
)
--заворачиваем в скрипт
SELECT	TABLE_NAME
	,	'CREATE TABLE ' + LOWER(TABLE_NAME)
		+ CHAR(10) +
		'(' + STUFF(STRING_AGG (COLUMN_SCRIPT, ''), 1, 1, '') + ');' AS PLPGSQL_SCRIPT
FROM CTE2
GROUP BY TABLE_NAME
;
