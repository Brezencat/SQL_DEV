--FUNNY

declare @num tinyint = 10;

raiserror('Start Hacking...',10,1) with nowait;

waitfor delay '00:00:01';

while @num < 100
BEGIN
	raiserror('Hacking FBI ... %d%s',10,1,@num,'%') with nowait;
	
	set @num += 20;
	
	waitfor delay '00:00:01';
END;

raiserror('FBI Hacked Successfully',10,1) with nowait;