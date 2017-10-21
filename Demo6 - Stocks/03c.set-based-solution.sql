use tempdb
go

-- How this works?
-- With SQL Server 2012 and later you can use FIRST_VALUE and LAST_VALUE functions
-- that will make the code even simpler. Performance will be the same as long as you use the ROW window and not the RANGE one

-- Open Price
select 		
	rn = row_number() over (partition by [SymbolID], [TransactionHour] order by [TransactionDateTime]),
	*
from 
	dbo.Ticks t 
where
	[SymbolID] = 1 and [TransactionHour] = 5
order by 
	[TransactionDateTime], rn

-- Close Price
select 		
	rn2 = row_number() over (partition by [SymbolID], [TransactionHour] order by [TransactionDateTime] desc),
	*
from 
	dbo.Ticks t 
where
	[SymbolID] = 1 and [TransactionHour] = 5
order by 
	[TransactionDateTime] desc, rn2

---

if (OBJECT_ID('dbo.stp_GetStockValues_SetBased') is not null)
	drop procedure [dbo].[stp_GetStockValues_SetBased]
go

create procedure [dbo].[stp_GetStockValues_SetBased]
@symbolidToShow int
as
with cte as 
(
	select 		
		rn = row_number() over (partition by [SymbolID], [TransactionHour] order by [TransactionDateTime]),
		rn2 = row_number() over (partition by [SymbolID], [TransactionHour] order by [TransactionDateTime] desc),
		*
	from 
		dbo.Ticks t 
	where
		SymbolID = @symbolidToShow	
)
select
	transaction_hour = c.[TransactionHour], 
	from_datetime = min(c.[TransactionDateTime]),
	to_datetime = max(c.[TransactionDateTime]),
	symbol_id = c.[SymbolID],
	high = max(c.[Price]),
	low = min(c.[Price]),
	volume = sum(c.[Volume]),
	[open] = max(case when c.rn = 1 then c.[Price] else null end),
	[close] = max(case when c.rn2 = 1 then c.[Price] else null end)
from
	cte c
group by 
	c.[TransactionHour], c.[SymbolID]
order by
	c.SymbolID, c.[TransactionHour];
go



