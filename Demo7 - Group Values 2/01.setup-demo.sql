use tempdb
go

if (OBJECT_ID('dbo.machine_data') is not null) drop table dbo.machine_data
go

CREATE TABLE [dbo].[machine_data]
(
	[Id] int identity not null primary key,
	[MachineId] [int] NOT NULL,
	[Status] [char](1) NOT NULL,
	[TimeStamp] [int] NOT NULL
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