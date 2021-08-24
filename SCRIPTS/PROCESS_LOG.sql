--таблица для логирования

CREATE TABLE dbo.PROCESS_LOG
	(ID int IDENTITY(1,1) NOT NULL --идентификатор записи в таблице
	,ProcessName varchar(255) NOT NULL --название процесса @@PROCID (~ object_id из sys.all_objects)
	,[Message] nvarchar(255) NOT NULL --здесь указывать SART, END, ERROR, название шага и т.п.
	,[Description] nvarchar(4000) NULL --дополнительное описание (типа время работы столько-то или описание ошибки из блока TRY/CATCH)
	,DateStart datetime NOT NULL CONSTRAINT DF_PROCESS_LOG_DateStart DEFAULT getdate() --дата и время добавления записи
	,DBName varchar(255) NULL --имя базы данных
	,SPID smallint NULL--ID сессии
	,[RowCount] int NULL--количество обработанных строк
	,Params varchar(4000) NULL--параметры процедуры (буду собирать c помощью for xml path())
	,UserName nvarchar(128) NOT NULL CONSTRAINT DF_PROCESS_LOG_UserName DEFAULT SYSTEM_USER --значение текущего имени входа, назначенного системой (в запросах лучше использовать SUSER_SNAME() для более корректной передачи логина)
	,HostName nvarchar(128) NOT NULL CONSTRAINT DF_PROCESS_LOG_HostName DEFAULT HOST_NAME() --имя рабочей станции
	,QueryPlan xml NULL --план запроса (заполняется только по флагу)
	);

	
	--можно допом добавить cpu_time, total_elapsed_time (Duration), logical_reads, writes из sys.dm_exec_requests
	--а можно просто записать эти параметры в [Description]