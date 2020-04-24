CREATE TABLE dbo.XEVENT_LIST
    ( ID            tinyint IDENTITY(1,1)	NOT NULL
     ,EVENT_NAME    varchar(255)			NOT NULL
     ,FILE_PATH	    varchar(255)			NULL
	 ,LAST_DATE		datetime2				NULL
     ,IS_ACTIVE	    bit						NULL
    )
;
GO

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Ид. номер по порядку',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'ID';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Название эвента в системе',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'EVENT_NAME';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Путь к файлу или название файла лога эвента',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'FILE_PATH';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Дата последней загрузки лога',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'LAST_DATE';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Статус активности эвента',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'IS_ACTIVE';  
GO 

--==========================================

--вставка данных в таблицу
-- INSERT INTO dbo.XEVENT_LIST
-- 	( EVENT_NAME
-- 	 ,FILE_PATH
-- 	 ,IS_ACTIVE
-- 	)
-- VALUES
-- 	('DEADLOCK_MONITOR', 'DEADLOCK_MONITOR*.xel', 1),
-- 	('LOGIN_APP_CONNECT', 'LOGIN_APP_CONNECT*.xel', 1),
-- 	('QUERY_IO', 'QUERY_IO*.xel', 1),
-- 	('QUERY_CPU', 'QUERY_CPU*.xel', 1)