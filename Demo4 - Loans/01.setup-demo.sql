use tempdb
go

if (OBJECT_ID('dbo.original_data') is not null) drop table dbo.original_data
go

create table dbo.original_data
(
	id int not null primary key,
	[start_date] date not null,
	end_date date not null,
	total_value decimal(15,6) not null,
	interest_rate decimal(5,2) not null,
	payment_frequency smallint not null	
)
go

if (object_id('dbo.fn_Nums') is not null)
	drop function dbo.fn_Nums
go

create function dbo.fn_Nums(@m as bigint) returns table
as
return
	with
	t0 as (select n = 1 union all select n = 1),
	t1 as (select n = 1 from t0 as a, t0 as b),
	t2 as (select n = 1 from t1 as a, t1 as b),
	t3 as (select n = 1 from t2 as a, t2 as b),
	t4 as (select n = 1 from t3 as a, t3 as b),
	t5 as (select n = 1 from t4 as a, t4 as b),
	result as (select row_number() over (order by n) as n from t5)
	select n from result where n <= @m
go


