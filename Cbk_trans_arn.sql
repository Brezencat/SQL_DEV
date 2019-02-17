select  dc.acq_ref_number as ARN,     
        coalesce(dc2.ret_ref_number, dc.ret_ref_number) as RRN, /*coalesce смотрим, если в таблице dc2 поле RRN не заполнено, то заполняем его из таблицы dc*/
        coalesce(bwx.rpr.get_tag_value(dc2.add_info,'RRN_IPSP'), (select rp.RRN_IPSP from reporter.accb_ext_data rp where bwx.rpr.get_tag_value(dc2.add_info,'ID_ACCB_EXT_DATA')=rp.id)) as RRN_IPSP,
        SUBSTR(dc2.target_number,0,6)||'*****'||SUBSTR(dc2.target_number,13,4) as Karta,
        To_char(trunc(dc.trans_date,'dd'), 'dd.mm.yyyy') as Trans_Date, /*через to_char задаём нужный нам формат даты, trunc помогает, если формат не меняется.*/
        dc2.trans_amount as Amount,
        (select currcode.name from bwx.currency currcode where currcode.amnd_state='A' and currcode.CODE=dc2.trans_curr) as Cur, /*обращаемся к таблице с кодами валют и заменяем значение кода на наименование валюты.*/
        dc.settl_amount as Cbk_Amount,
        (select currcode.name from bwx.currency currcode where currcode.amnd_state='A' and currcode.CODE=dc.settl_curr)  as Cbk_curr, /*обращаемся к таблице с кодами валют и заменяем значение кода на наименование валюты.*/
        To_char(trunc(dc.posting_date,'dd'), 'dd.mm.yyyy') as Posting_Date, /*через to_char задаём нужный нам формат даты, trunc помогает, если формат не меняется.*/
        (select trntype.name  trntype from bwx.trans_type trntype where trntype.amnd_state='A' and trntype.id=dc.trans_type) as Trans_type, /*обращаемся к таблицн с транс типом и меняем цифровой код на наименование.*/
        case when substr(dc.reason_code,1,2)='VC' then substr(dc.reason_code,3) else dc.reason_code end) as reason_code, /* убираем из ризон кода Visa первые два символа, которые соответсвуют VC и оставляем всё остальное с третьего символа.*/
        (select mesch.name from BWX.mess_channel mesch where mesch.amnd_state='A' and mesch.code=dc.source_channel) as System /* из таблицы каналов берем значение кода и вместо буквы выводим название канала.*/    
from
        bwx.doc dc,
        bwx.doc dc2
where
        dc.amnd_state='A'
        and dc.acq_ref_number  in
(
'01234********************567',
'12345********************678',
'23456********************789',
'34567********************890'
)
        and dc.acq_ref_number=dc2.acq_ref_number(+)
        and dc2.amnd_state='A'
        and dc2.trans_type in (5,50,15/*Credit*/) and dc2.request_category='P'/*Advice*/
        and (dc.trans_type not in (5,50,15,26/*Retail Retr*/,51/*Unique 2Prs*/,55/*Unique 2Cbk*/,7/*Retail 2Prs*/,20/*Retail 2Cbk*/) or dc.request_category!='P'/*Advice*/)
        and (dc.trans_type not in (5,50) or dc.request_category!='R'/*Reversal*/
        or dc.reason_code is not null)
;