use tempdb
go

if (OBJECT_ID('dbo.fn_GetStockPriceAtTime') is not null)
	drop function [dbo].[fn_GetStockPriceAtTime]
go

create function dbo.[fn_GetStockPriceAtTime](@symbol_id int, @datetimePoint datetime2(0))
returns [decimal](13,4)
as
begin
	declare @price as [decimal](13,4)
	
	select 
		@price = Price 
	from 
		dbo.Ticks
	where 
		SymbolID = @symbol_id
	and 
		[TransactionDateTime] = @datetimePoint
	
	return @price
end
go
	

if (OBJECT_ID('dbo.stp_GetStockValues_NotReallySetBased') is not null)
	drop procedure [dbo].[stp_GetStockValues_NotReallySetBased]
go

create procedure [dbo].[stp_GetStockValues_NotReallySetBased]
@symbolidToShow int
as
select
	transaction_hour = [TransactionHour], 
	from_datetime = min([TransactionDateTime]),
	to_datetime = max([TransactionDateTime]),
	symbol_id = [SymbolID],
	high = max([Price]),
	low = min([Price]),
	volume = sum([Volume]),
	[open] = dbo.[fn_GetStockPriceAtTime]([SymbolID], min([TransactionDateTime])),
	[close] = dbo.[fn_GetStockPriceAtTime]([SymbolID], max([TransactionDateTime]))
from
	dbo.Ticks 
where
	SymbolID = @symbolidToShow	
group by 
	[TransactionHour], [SymbolID]
order by
	SymbolID, [TransactionHour];
go