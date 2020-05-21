CREATE TABLE dbo.XEVENT_XML_BUFFER
    ( ID 			int IDENTITY (1,1) 	NOT NULL
     ,XEVENT_NAME 	varchar(255)		NOT NULL --имя эвента
     ,[EVENT]		varchar(255) 		NOT NULL --имя события
     ,[UTCDATE]     datetime2 			NOT NULL --дата и время события 
     ,[VALUE] 		XML 				NOT NULL --xml с данными события
    );