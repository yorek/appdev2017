use tempdb
go

if (OBJECT_ID('dbo.stp_GetStockValues_RowByRow') is not null)
	drop procedure [dbo].[stp_GetStockValues_RowByRow]
go

create procedure [dbo].[stp_GetStockValues_RowByRow]
@symbolidToShow int
as
declare @prevhour int = 0
declare @hour int = 0
declare @prevsymbolid int
declare @symbolid int 
declare @from_datetime datetime2(0) 
declare @to_datetime datetime2(0) 
declare @datetime datetime2(0) 
declare @price decimal(13,4) 
declare @high decimal(13,4)
declare @low decimal(13,4) 
declare @open decimal(13,4)  
declare @close decimal(13,4)  
declare @volume int = 0
declare @sum_volume int = 0

create table #results
(
	[transaction_hour] int,
	[symbol_id] int,
	[from_datetime] datetime2(0),
	[to_datetime] datetime2(0),
	[high] decimal(13,4),
	[low] decimal(13,4),
	[open] decimal(13,4),
	[close] decimal(13,4),
	[volume] int	
)

begin try
	declare c cursor fast_forward for
	select
		[Hour] = [TransactionHour],
		[SymbolID],
		[TransactionDateTime],	
		[Price],
		[Volume]
	from
		dbo.Ticks
	where 
		SymbolID = @symbolidToShow		
	order by
		[SymbolId], [TransactionHour], [TransactionDateTime]
		
	open c
	fetch next from c into @hour, @symbolid, @datetime, @price, @volume

	set @prevhour = @hour
	set @prevsymbolid = @symbolid

	set nocount on

	while (@@fetch_status = 0)
	begin

		-- open
		if ((@from_datetime is null) or (@datetime < @from_datetime)) begin
			set @from_datetime = @datetime;
			set @open = @price;
		end
		
		-- close
		if ((@to_datetime is null) or (@datetime > @to_datetime)) begin
			set @to_datetime = @datetime;
			set @close = @price;
		end
		
		-- high
		if ((@high is null) or (@price > @high)) set @high = @price;
		
		-- low
		if ((@low is null) or (@price < @low)) set @low = @price;
		
		-- volume
		set @sum_volume += @volume

		fetch next from c into @hour, @symbolid, @datetime, @price, @volume;
		
		if  (@hour <> @prevhour)
		begin
			insert into #results  ([transaction_hour], [symbol_id], [from_datetime], [to_datetime], [high], [low], [open], [close], [volume])
			values (@prevhour, @prevsymbolid, @from_datetime, @to_datetime, @high, @low, @open, @close, @sum_volume);
		
			set @from_datetime = null;
			set @to_datetime = null;
			set @high = null;
			set @low = null;
			set @open = null;
			set @close = null; 
			set @sum_volume = 0;
		end

		set @prevhour = @hour
		set @prevsymbolid = @symbolid
	end

	insert into #results  ([transaction_hour], [symbol_id], [from_datetime], [to_datetime], [high], [low], [open], [close], [volume])
	values (@hour, @symbolid, @from_datetime, @to_datetime, @high, @low, @open, @close, @sum_volume);

	close c
	deallocate c

	-- Show table of results
	select 
		[transaction_hour],
		[from_datetime],
		[to_datetime],
		[symbol_id],
		[high],
		[low],
		[volume],
		[open],
		[close]
	from 
		#results
	order by
		[symbol_id], [transaction_hour]
	
end try
begin catch
	close c
	deallocate c
end catch
go