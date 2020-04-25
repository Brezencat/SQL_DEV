CREATE TABLE dbo.XEVENT_LOG
	(ID 			int IDENTITY (1,1) NOT NULL
	,XEVENT_NAME 	varchar(255) NOT NULL --имя XEvent
	,[EVENT]		varchar(255) 	NOT NULL --имя собоытия из XML
	,SERVER_NAME 	varchar(255) 	NOT NULL --client_hostname
	,DATABASE_ID 	tinyint 		NOT NULL --smallint ???
	,[APP_NAME] 		varchar(255) 	NOT NULL --client_app_name
	,USERNAME 		varchar(255) 	NOT NULL 
	,[SESSION_ID] 	smallint 		NOT NULL
	,SQL_TEXT 		varchar(MAX) 	NULL --тексты запросов. exec процедуры
	,[STATEMENT]	varchar(4000) 	NULL --запрос, вызвавший событие. Запрос из процедуры
	,CPU_TIME 		int 			NULL
	,LOGICAL_READS 	int 			NULL
	,ROW_COUNT 		int 			NULL
	,[VALUE] 		XML 			NULL --разные параметры
	,[TIMESTAMP] 	datetime2 		NOT NULL --дата и время проишествия
	)
;