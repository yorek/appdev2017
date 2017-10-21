use tempdb
go

truncate table [dbo].[Ticks]
go

declare @num_of_stocks int = 100;
declare @num_of_transactions_per_stock int = 10000;

with cte as 
(
	select 
		TransactionTime = right('00' + cast(abs(checksum(newid())) % 24 as varchar(2)),2) + ':' + right('00' + cast(abs(checksum(newid())) % 60 as varchar(2)),2) + ':' + right('00' + cast(abs(checksum(newid())) % 60 as varchar(2)), 2),
		Price = 3. + abs(checksum(newid())) % 600 / 100.,
		Volume = abs(checksum(newid())) % 5000
	from
		dbo.fn_nums(@num_of_transactions_per_stock) n
)
insert into 
	[dbo].[Ticks]
select
	[SymbolID] = t2.n,
	[TransactionDateTime] = dateadd(day, n-1, (cast('20170101' as datetime))) + cast(TransactionTime as datetime),
	[Price],
	[Volume]
from
	cte t1 
cross join
	dbo.fn_nums(@num_of_stocks) t2
go
	
create clustered index ixc__Ticks 
on dbo.Ticks([SymbolId], [TransactionHour], [TransactionDateTime])
--with drop_existing 
go

select 
	* 
from 
	dbo.Ticks 
where 
	[SymbolId] = 1 and [TransactionHour] = 5 
order by 
	[TransactionDateTime]
go
