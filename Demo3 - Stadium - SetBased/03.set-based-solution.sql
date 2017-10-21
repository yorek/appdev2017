use tempdb
go

/*
	Generate Data
*/
exec dbo.stp_load_sample_data @rows = 12, @seats_per_row = 30

/*
	The Solution
*/

-- First Step
select
	row,
	seat,
	rn = row_number() over(partition by row order by seat),
	group_key = seat - row_number() over(partition by row order by seat)
from
	dbo.[Seats] as p 
where 
	taken = 0
and
	row = 5	
;
	
-- Final Solution
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
