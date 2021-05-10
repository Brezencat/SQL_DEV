--MSSQL Server
--секции таблицы

declare @TableName nvarchar(200) = N'dbo.TABLE_NAME';

select 	p.partition_id
	,	p.partition_number
	,	schema_name(o.schema_id) + '.' + object_name(i.object_id) as table_name
	,	ps.name as partition_scheme_name
	,	fg.name as filegroup
	,	f.name as partition_function_name
	,	tp.name as partition_function_type
	,	c.name as partition_column_name
	,	case boundary_value_on_right
			when 1
			then 'less than'
			else 'less than or equal to'
		end as comparison
	,	rv.value
	,	p.rows
	,	au.total_pages as pages
	,	convert(varchar(6), convert(int, substring(au.first_page, 6, 1) + substring(au.first_page, 5, 1))) + ':' + convert(varchar(20), convert(int, substring(au.first_page, 4, 1) + substring(au.first_page, 3, 1) + substring(au.first_page, 2, 1) + substring(au.first_page, 1, 1))) as first_page
	,	p.data_compression_desc
from sys.partitions	as p
inner join sys.objects	as o
	on p.object_id = o.object_id
inner join sys.indexes	as i
	on p.object_id = i.object_id
	and p.index_id = i.index_id
inner join sys.index_columns as ic
	on ic.object_id = i.object_id
	and ic.index_id = i.index_id
	and ic.partition_ordinal >= 1 -- because 0 = non-partitioning column   
inner join sys.columns as c	
	on c.object_id = o.object_id
	and c.column_id = ic.column_id
inner join sys.partition_schemes as ps
	on ps.data_space_id = i.data_space_id
inner join sys.partition_functions as f
	on f.function_id = ps.function_id
left  join sys.partition_range_values as rv
	on f.function_id = rv.function_id
	and p.partition_number = rv.boundary_id
inner join sys.partition_parameters	as pp
	on pp.function_id = f.function_id
inner join sys.types as tp
	on tp.user_type_id = pp.user_type_id
inner join sys.destination_data_spaces as dds
	on dds.partition_scheme_id = ps.data_space_id
	and dds.destination_id = p.partition_number
inner join sys.filegroups as fg	
	on dds.data_space_id = fg.data_space_id
inner join sys.system_internals_allocation_units as au
	on p.partition_id = au.container_id
where i.index_id in (0, 1)
	and o.object_id = object_id(@TableName)
order by rv.value desc
;
