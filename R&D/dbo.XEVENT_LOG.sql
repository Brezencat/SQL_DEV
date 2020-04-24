CREATE TABLE dbo.XEVENT_LOG
	(ID int IDENTITY (1,1) NOT NULL
	,SEANS_NAME varchar(255) NOT NULL --имя XEvent
	,EVENT_NAME varchar(255) NOT NULL --имя собоытия из XML
	,SERVER_NAME varchar(255) NOT NULL --client_hostname
	,DATABASE_ID tinyint NOT NULL --smallint ???
	,APP_NAME varchar(255) NOT NULL --client_app_name
	,USERNAME varchar(255) NOT NULL 
	,SESSION_ID smallint NOT NULL
	,SQL_TEXT varchar(4000) NULL --тексты запросов
	,[VALUE] XML NULL --разные параметры
	,[TIMESTAMP] datetime2 NOT NULL --дата и время проишествия
	)
;