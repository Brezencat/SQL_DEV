CREATE TABLE dbo.XEVENT_XML_BUFFER
    ( ID 			int IDENTITY (1,1) 	NOT NULL
     ,XEVENT_NAME 	varchar(255)		NOT NULL
     ,[EVENT]		varchar(255) 		NOT NULL
     ,[UTCDATE]     datetime2 			NOT NULL
     ,[VALUE] 		XML 				NOT NULL
    );
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
    @level2type = N'COLUMN', @level2name = 'XEVENT_NAME';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Название отслеживаемого события',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'EVENT';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'Дата и время возникновения события в формате UTC +0',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'UTCDATE';  
GO 

exec sp_addextendedproperty 
    @name = N'MS_Description',   
    @value = 'XML с данными эвента из файла лога',  
    @level0type = N'SCHEMA', @level0name = 'dbo',  
    @level1type = N'TABLE',  @level1name = 'XEVENT_LIST',  
    @level2type = N'COLUMN', @level2name = 'VALUE';  
GO 