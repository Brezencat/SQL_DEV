CREATE TABLE dbo.XEVENT_LOG
	([ID] 			int IDENTITY (1,1) NOT NULL
	,[XEVENT_NAME] 	varchar(255) NOT NULL --имя XEvent
	,[EVENT]		varchar(255) 	NOT NULL --имя собоытия из XML
	,[TIMESTAMP] 	datetime2 		NOT NULL --дата и время проишествия
	,[SERVER_NAME] 	varchar(255) 	NOT NULL --client_hostname
	,[DATABASE_ID] 	tinyint 		NOT NULL --smallint ???
	,[APP_NAME] 	varchar(255) 	NOT NULL --client_app_name
	,[USERNAME]		varchar(255) 	NOT NULL 
	,[SESSION_ID] 	smallint 		NOT NULL
	,[SQL_TEXT] 	varchar(4000) 	NULL --тексты запросов. exec процедуры
	,[session_id_query]		int		null --с какими сессиями взаимодействие для lock_deadlock_chain
	,[database_id_query]	tinyint	null --в каких базах эти сессии для lock_deadlock_chain
	,[deadlock_id]			int		null --нужен для группировки событий
	,[transaction_id_query]	int		null
	,[resource_type]			varchar(10)	null --какой тип блокировки наложен	
	,[VALUE] 		XML 			NULL --разные параметры
	)
;