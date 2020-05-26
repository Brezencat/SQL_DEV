CREATE TABLE dbo.XEVENT_XML_VIEW
    ( [ID] 				int IDENTITY (1,1) 	NOT NULL
     ,[XEVENT_NAME] 	varchar(255) 		NOT NULL
     ,[EVENT]			varchar(255) 		NOT NULL
     ,[UTCDATE]	 		datetime2 			NOT NULL --!!! именно UTC +0
     ,[SERVER_NAME] 	varchar(255) 		NULL
     ,[DATABASE_ID] 	tinyint 			NULL --??? smallint
     ,[APP_NAME] 		varchar(255) 		NULL
     ,[USERNAME]		varchar(255) 		NULL 
     ,[SESSION_ID] 		smallint 			NULL
     ,[SQL_TEXT] 		varchar(4000) 		NULL
     ,[VALUE] 			varchar(4000) 		NULL
    );
GO

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Ид. номер по порядку',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'ID';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Название эвента в системе',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'XEVENT_NAME';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Название отслеживаемого события',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'EVENT';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Дата и время возникновения события в формате UTC +0',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'UTCDATE';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Сервер, на котором произошло событие (client_hostname в эвентах)',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'SERVER_NAME';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Идентификатор базы данных',
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'DATABASE_ID';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Приложение, подключённое к БД, в котором произошло событие (client_app_name в эвентах)',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'APP_NAME';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Логин пользователя, который вызвал событие (если nt_username отсутсвует, то username в эвентах)',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'USERNAME';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Ид. сессии в которой произошло событие',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'SESSION_ID';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Текст запроса из события',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'SQL_TEXT';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Прочие параметры. Для дедлоков указаны заблокированные ресурсы и пометка (KILL) для убитой сессии',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_XML_VIEW',  
    @level2type = N'COLUMN', @level2name = 'VALUE';  
GO 