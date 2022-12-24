
-- IDENTITY
-- отрицательные не поддерживает, если не указан максимум, то ограничен типом данных
-- для принудительной вставки в поле определенного как GENERATED ALWAYS AS IDENTITY необходимо после инструкции INSERT INTO использовать указание OVERRIDING system/user VALUE
log_id integer GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT  BY 1 ) CONSTRAINT pk_process_log_id PRIMARY KEY,