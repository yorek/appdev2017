use tempdb
go

-- Show Data
select 
	*
from 
	(select row, seat, taken from dbo.Seats where row = 'E') s
pivot
(
	min(taken) for seat in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30])
) p


--
-- ROW BY ROW SOLUTION
-- (Show also Profiler Execution)
--

set nocount on
set statistics io on
go

declare @row char(1)
declare @row_prev char(1)
declare @seat smallint
declare @seat_prev smallint
declare @seat_from smallint
declare @counter smallint

declare c cursor fast_forward for
select row, seat from dbo.seats where taken = 0 order by row, seat

create table #result
(
	row char(1),
	[from] smallint,
	[to] smallint,
	total_free_near_seats smallint
)

set @counter = 0

open c
fetch next from c into @row, @seat

set @seat_from = @seat

while (@@fetch_status = 0)
begin
	if (@seat_prev is not null)
	begin
	
		if (@seat - @seat_prev = 1) 
		begin 			
			set @counter = @counter + 1
		end else begin
			insert into #result values (@row, @seat_from, @seat_prev, @counter + 1)
			set @seat_from = @seat
			set @counter = 0
		end
	end

	set @row_prev = @row
	set @seat_prev = @seat

	fetch next from c into @row, @seat
	
	if (@row_prev <> @row) begin	
		insert into #result values (@row_prev, @seat_from, @seat_prev, @counter + 1)
		set @counter = 0		
		set @seat_from = @seat
		set @seat_prev = null
	end
end

if (@counter > 0) begin
	insert into #result values (@row, @seat_from, @seat_prev, @counter + 1)
end

close c
deallocate c

select * from #result where row = 'E'

drop table #result

	