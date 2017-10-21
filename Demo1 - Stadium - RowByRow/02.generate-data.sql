use tempdb
go

truncate table dbo.[Seats];

--seats: 12;
--seats_per_row: 30;

-- Create seats
with cte_rows as 
(
	select
		row = char(n+64)
	from
		dbo.fn_Nums(12) 
),
cte_seats as
(	
	select
		seat = n
	from
		dbo.fn_Nums(30) 
)
insert into
	dbo.[Seats]
select
	row, seat, taken = 0
from
	[cte_rows]
cross join
	[cte_seats];
go

--Set some random seats as taken
update 
	dbo.Seats 
set
	[taken] = 1
where
	row = CHAR((RAND() * 12 + 65))
and
	seat = CAST(RAND() * 30 as int)
go 100

-- Set some "known" seats on rows E and F as taken		
update dbo.Seats set [taken] = 0 where row in ('E', 'F')

update 
	dbo.Seats 
set
	[taken] = 1
where
	row = 'E'
and
	((seat between 10 and 15) or (seat between 18 and 22) or (seat between 26 and 30) or seat in (2,3));
		
update 
	dbo.Seats 
set
	[taken] = 1
where
	row = 'F'
and
	((seat between 3 and 8) or (seat between 11 and 18) or (seat between 20 and 22) or seat in (28,30));
go


-- Show data
select 
	*
from 
	(select row, seat, taken from dbo.Seats) s
pivot
(
	min(taken) for seat in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],[27],[28],[29],[30])
) p


