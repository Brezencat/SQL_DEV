# [SQL](https://ru.wikipedia.org/wiki/SQL)
Скрипты, тесты, обучение, домашняя работа по SQL

### [SCRIPTS](./SCRIPTS/)
* [exist_column_in_table](./SCRIPTS/exist_column_in_table.sql) - Есть ли столбец в таблице. Несколько способов проверки существования столбца в таблице
* [EXTENDED_PROPERTIES](./SCRIPTS/EXTENDED_PROPERTIES.sql) - Описание объектов и колонок БД с помощью расширенных свойств
* [FOR_INDEXES](./SCRIPTS/FOR_INDEXES.sql) - скрипт для просмотра индексов (используемые, недостающие)
* [FOR_STATISTICS](./SCRIPTS/FOR_STATISTICS.sql) - статистика таблицы, удаление автостатистики
* [INFO_FOR_SERVER](./SCRIPTS/INFO_FOR_SERVER.sql) - знакомство с сервером
* [LAST_ACCESS_OBJECT](./SCRIPTS/LAST_ACCESS_OBJECT.sql) - обращения к объектам БД (когда было последнее обращение). Это не 100% способ проверки на основе sys.dm_db_index_usage_stats
* [other](./SCRIPTS/other.sql) - разные скрипты и их куски
* [PARTITIONS_TABLE](./SCRIPTS/PARTITIONS_TABLE.sql) - партиции секционированной таблицы
* [REVIEW_QUERY_STORE](./SCRIPTS/REVIEW_QUERY_STORE.sql) - просмотр планов и текстов запросов из Query Store
* [script-templates](./SCRIPTS/templates.sql) - шаблоны скриптов для расчётов
* [SEARCH_IN_CACHE_PLANS](./SCRIPTS/SEARCH_IN_CACHE_PLANS.sql) - поиск запроса по его части в кэше планов
* [SERVER_SITUATION](./SCRIPTS/SERVER_SITUATION.sql) - ситуация на сервере (активные сессии, блокировки)
* [SPACE_USED](./SCRIPTS/SPACE_USED.sql) - сколько места занимаем БД (объекты в БД)
* [USED_OBJECT_OR_COLUMN](./SCRIPTS/USED_OBJECT_OR_COLUMN.sql) - где используется объект или колонка
* [XACT_ABORT](./SCRIPTS/XACT_ABORT.sql) - определение статуса xact_abort


### [EDUCATION](./EDUCATION/) 
* Рекурсия календарь и фильтрованный индекс
* Рекурсия с датами
* [решение т.з. РТС-Трейдинг](./EDUCATION/решение%20т.з.%20РТС-Трейдинг.sql) - тестовое задание и его решение по SQL после прохождения собеседования в РТС-Трейдинг
* [тестовое задание SQL РТС-Трейдинг](./EDUCATION/тестовое%20задание%20SQL%20РТС-Трейдинг.sql) - само тестовое задание
* [Cbk_trans_arn](./EDUCATION/Cbk_trans_arn.sql) - формирование отчёта по чарджбекам на основании идентификаторов оригинальных транзакций (Oraccle).
* [count_groups.sql](./EDUCATION/count_groups.sql) - пример работы группировки на примере агрегатной функции count()
* [cross_apply](./EDUCATION/cross_apply.sql) - пример использования CROSS_APPLY и разница с JOIN
* [CTE рекурсия](./EDUCATION/CTE%20рекурсия.sql) - примеры рекурсивного запроса CTE
* EVENT SESSION SQL_batch_statement_by_TSQL2012
* [Exam70-461_solutions](./EDUCATION/Exam70-461_solutions.sql) - решения заданий из книги "Учебный курс Microsoft SQL Server 2012 Exam 70-461"
* EXISTS_NOT_EXISTS_FOR_JOIN
* foot.MATCH
* [interview_questions](./EDUCATION/interview_questions.sql) - вопросы для собеседования
* OVER and PIVOT
* rally.DAKAR
* test.RUN
* [types_of_joins](./EDUCATION/types_of_joins.sql) - пример видов соединений (join)
* [work_and_or](./EDUCATION/work_and_or.sql) - интересный пример на обработку AND и OR
* [float_exponent.sql](./EDUCATION/float_exponent.sql) - пример работы с типом данных float и обработка экспоненты. Сравнение с decimal в части знаков после запятой.


### [postgresql](/postgresql/)
- [notes.sql](./postgresql/notes.sql) - мои заметки при работе с PostgreSQL
- [storage-rows.sql](./postgresql/storage-rows.sql) - как Postgres хранит строки

### [other](./other/)
- [Hacking_FBI](./Hacking_FBI.sql) - FUNNY скрипт взлома ФБР


### [R&D](./R&D/) (Research & Development - командные задачи из Trello)
* [dbo.WhoIsActiveLog](./dbo.WhoIsActiveLog.sql) - таблица для записи лога вывода процедуры WhoIsActive, пример запуска процедуры для возврата метаданных таблицы и запуск процедуры с записью вывода в таблицу лога


### [XEvents](./XEvents/)
_Задача: Настройка extended event и сервис просмотра логов_  
* Список операция для мониторинга
  * Deadlock
  * Межсерверные запросы
  * Какое приложение кроме студии подключается к БД
  * Под каким логином идёт подключение к серверу
  * Тяжелых запросов по логическим чтениям
  * Тяжелые запросы по CPU
* дальнейшее описание

