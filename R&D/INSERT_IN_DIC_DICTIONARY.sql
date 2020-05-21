USE MIT 
GO
BEGIN TRY
	BEGIN TRAN

	DECLARE 
		@DICTIONARY_NAME varchar(100) = 'Список эвентов для отслеживания', --�������� �����������
		@ID_DICTIONARY int;

	--���������� ������ ��� �������
	DROP TABLE IF EXISTS #DICTIONARY_ATTR_VALUE;

	SELECT CONCAT('XEVENT_NAME ' --�������� ������ (����� ������������ �������� �������), ��������� �� �������
					, + ATTR_VALUE) AS ROW_NAME, ATTR_VALUE, DATE_FROM, DATE_TO
	INTO #DICTIONARY_ATTR_VALUE
	FROM (values
			('DEADLOCK_MONITOR', '19000101', '22000101'),
			('LOGIN_APP_CONNECT', '19000101', '22000101')
		 ) AS x ( ATTR_VALUE, DATE_FROM, DATE_TO)
	;
		print '���������� ������ ��� �������, �������� #DICTIONARY_ATTR_VALUE. ���������� ' + cast(@@ROWCOUNT as varchar(10));

	--������� � ������ �������
	--������� ����������
	INSERT INTO dbo.DIC_DICTIONARY (CAPTION)
	SELECT @DICTIONARY_NAME
	WHERE not exists (select 1 from dbo.DIC_DICTIONARY where CAPTION = @DICTIONARY_NAME)
	;
		SET @ID_DICTIONARY = SCOPE_IDENTITY()
			--print @ID_DICTIONARY
	;
		print '������� ���������� ID_DICTIONARY=' + cast(@ID_DICTIONARY as varchar(10));

	--������� ������� �����������
	INSERT INTO dbo.DIC_DICTIONARY_ATTR (ID_DICTIONARY, COLUMN_NAME, DESCRIPTION, DATA_TYPE, NULLABLE, IS_FK_COLUMN, VIEW_SCHEMA, VIEW_TABLE, VIEW_ALIAS)
	VALUES  (@ID_DICTIONARY, 'XEVENT_NAME', 'Наименование эвента', 'varchar(255)', 1, 0, 'sys', 'dm_xe_sessions', 't1')
	;
		print '������� ������� �����������. ���������� ' + cast(@@ROWCOUNT as varchar(10));

	--������� ������ ����������� � ������� ���� �� ��������
	INSERT INTO dbo.TBL_DICTIONARY_ROW (ID_DICTIONARY, NAME, DATE_FROM, DATE_TO)
	SELECT @ID_DICTIONARY, ROW_NAME, DATE_FROM, DATE_TO
	FROM #DICTIONARY_ATTR_VALUE
	;
		print '������� ������ ����������� � ���� ��������. ���������� ' + cast(@@ROWCOUNT as varchar(10));

	--������� �������� ��� ����������� ����� �����
	INSERT INTO dbo.TBL_DICTIONARY_ATTR_VALUE (ID_ROW, ID_DICTIONARY_ATTR, VALUE)
	select r.ID_ROW, a.ID_DICTIONARY_ATTR, v.ATTR_VALUE
	from #DICTIONARY_ATTR_VALUE AS v
	join dbo.DIC_DICTIONARY_ATTR AS a ON a.ID_DICTIONARY=@ID_DICTIONARY and a.COLUMN_NAME='XEVENT_NAME'
	join dbo.TBL_DICTIONARY_ROW AS r ON r.ID_DICTIONARY=@ID_DICTIONARY and r.NAME = v.ROW_NAME
	;
		print '�������� �����. ���������� ' + cast(@@ROWCOUNT as varchar(10));

	--���������� ���������� (������ MIT)
	declare @TABLE_NAME varchar(256) = concat('DIC_DICTIONARY_', @ID_DICTIONARY);
		exec INTERFACE.PREPARE_TABLE_INFO;
		exec INTERFACE.PREPARE_COLUMN_INFO
			@SCHEMA_NAME = '___',			--"___" - ������ ��� ??? - �������� � ������ �����; ��� ��������
			@TABLE_NAME	 = @TABLE_NAME;
		print '���������� ���������� (������ MIT) ' + @TABLE_NAME;
	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK;
	THROW;
END CATCH