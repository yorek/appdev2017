use tempdb
go

if (object_id('dbo.stp_load_sample_data') is not null) drop procedure dbo.stp_load_sample_data
go

create procedure dbo.stp_load_sample_data
@rows int, 
@seats_per_row int
as

truncate table dbo.[Seats];

with cte_rows as 
(
	select
		row = n
	from
		dbo.fn_Nums(@rows) 
),
cte_seats as
(	
	select
		seat = n
	from
		dbo.fn_Nums(@seats_per_row) 
)
insert into
	dbo.[Seats]
select
	row, seat, taken = 0
from
	[cte_rows]
cross join
	[cte_seats];

--Set some random seats as taken
with cte as
(
select distinct
	row = ABS(CHECKSUM(NEWID())) % @rows,
	seat = ABS(CHECKSUM(NEWID())) % @seats_per_row
from
	dbo.fn_nums((@rows * @seats_per_row)/10)
)
merge into 
	dbo.[Seats] tgt
using 
	cte src on tgt.row = src.row and tgt.seat = src.seat	
when matched then
	update set taken = 1		
;

-- Set some "known" seats on rows E and F as taken		
update dbo.Seats set [taken] = 0 where row in (5, 6)

update 
	dbo.Seats 
set
	[taken] = 1
where
	row = 5
and
	((seat between 10 and 15) or (seat between 18 and 22) or (seat between 26 and 30) or seat in (2,3));
		
update 
	dbo.Seats 
set
	[taken] = 1
where
	row = 6
and
	((seat between 3 and 8) or (seat between 11 and 18) or (seat between 20 and 22) or seat in (28,30));
go
	
if (object_id('dbo.stp_row_by_row') is not null) drop procedure dbo.stp_row_by_row
go

create procedure dbo.stp_row_by_row
as

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

select * from #result

drop table #result
go

if (object_id('dbo.stp_set_based') is not null) drop procedure dbo.stp_set_based
go

create procedure dbo.stp_set_based
as
with cte as 
(
select
	row,
	seat,
	rn = row_number() over(partition by row order by seat),
	group_key = seat - row_number() over(partition by row order by seat)
from
	dbo.[Seats] as p 
where 
	taken = 0
)
select
	row, 
	[from] = min(seat),
	[to] = max(seat),
	total_free_near_seats = max(seat) - min(seat) + 1
from
	cte c1
group by
	row, group_key
order by 
	row, [from]
go	
	