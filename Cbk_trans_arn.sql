SELECT  t1.number_world AS NW,     
        coalesce(t2.number, t1.number) AS N, /*coalesce смотрим, если в таблице t2 поле NUMBER не заполнено, то заполняем его из таблицы t1*/
        coalesce(fn.func.function_name(t2.info,'provider_number'), (select dbo.provider_numbe from dbo.provider as p where fn.func.function_name(t2.info,'provider_id')=p.id)) AS PN,
        SUBSTR(t2.number_user,0,6)||'*****'||SUBSTR(t2.number_user,13,4) AS NU,
        To_char(trunc(T1.user_date,'dd'), 'dd.mm.yyyy') AS User_Date, /*через to_char задаём нужный нам формат даты, trunc помогает, если формат не меняется.*/
        t2.amount AS Amount,
        (select cc.name from dbo.currcode as cc where cc.is_active='A' and cc.CODE=t2.amount_cur) AS Cur, /*обращаемся к таблице с кодами валют и заменяем значение кода на наименование валюты.*/
        t1.amount2 AS Amount2,
        (select cc.name from dbo.currcode as cc where cc.is_active='A' and cc.CODE=t1.amount2_cur)  AS Cur2, /*обращаемся к таблице с кодами валют и заменяем значение кода на наименование валюты.*/
        To_char(trunc(t1.system_date,'dd'), 'dd.mm.yyyy') AS System_Date, /*через to_char задаём нужный нам формат даты, trunc помогает, если формат не меняется.*/
        (select t.name as t from dbo.type as t where t.is_active='A' and t.id=t1.type) AS Type_Name, /*обращаемся к таблицн с типом и меняем цифровой код на наименование.*/
        case when substr(t1.code,1,2)='AB' then substr(t.code,3) else t1.code end) AS Code, /* убираем из кода первые два буквенных символа и оставляем всё остальное с третьего символа.*/
        (select m.name from dbo.message as m where m.is_active='A' and m.code=t1.message) AS Message /* из таблицы сообщений берем значение кода и вместо кода выводим название.*/    
from
        dbo.table t1,
        dbo.table t2
where
        t1.is_active='A'
        and t1.number_world  in
(
'01234********************567',
'12345********************678',
'23456********************789',
'34567********************890'
)
        and t1.number_world=tb2.number_world(+)
        and t2.is_active='A'
        and t2.type in (7,10,30) and t2.category='B'
        and (t1.type not in (7,10,30) or t1.category<>'B')
        and (t1.type not in (7,10) or t1.category<>'C' or t1.code is not null)
;
