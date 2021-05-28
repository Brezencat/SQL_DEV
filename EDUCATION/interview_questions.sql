--Вопросы для собеседования

--1. что вернёт запрос?
--вопрос на внимательность, понимание важности алиасов и какие область вилимости подзапроса (какие столбцы он может использовать)
USE tempdb;

DROP TABLE IF EXISTS #TMP1;
CREATE TABLE #TMP1 
	(a int);
INSERT INTO #TMP1 
	(a)
SELECT 1
UNION ALL SELECT 2
UNION ALL SELECT 3;

DROP TABLE IF EXISTS #TMP2;
CREATE TABLE #TMP2 
	(b int);
INSERT INTO #TMP2
	(b)
SELECT 4
UNION ALL SELECT 5
UNION ALL SELECT 6;

SELECT * FROM #TMP1 WHERE a in (select a from #TMP2);

--вернёт все значения из таблицы #TMP1, так как в подзапросе используется её колонка. Ошибки нет (отсутсвие такой колонки в таблице #TMP2), потому что в область видимости подзапроса попадают столбцы основного запроса.


--2. что вернёт запрос?
--вопрос на понимание NULL значения и его использование в равенстве/неравенстве

;WITH CTE AS 
(
SELECT NULL AS b
)
SELECT 1
FROM CTE
WHERE b = COALESCE(NULL, b);

--не вернёт никакого значения, потому что NULL не равен NULL

