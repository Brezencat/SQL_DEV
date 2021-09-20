--таблицы с PK (сначала будут таблицы без ключей, столбец PK_NAME = null)
SELECT  o.name AS TABLE_NAME
    ,   kc.name AS PK_NAME
    ,   o.create_date AS TABLE_CREATE
    ,   kc.create_date AS PK_CREATE
FROM sys.objects AS o
LEFT JOIN sys.key_constraints AS kc
    ON kc.parent_object_id = o.object_id
    AND kc.type = 'PK'
WHERE o.is_ms_shipped = 0
    AND o.type = 'U'
ORDER BY kc.name, o.name;