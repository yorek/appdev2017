------------------------------------------------------------------------
-- Script:			03.set-based-solution.sql
-- Author:			Davide Mauri (Solid Quality Mentors)
-- Credits:			-
-- Copyright:		Attribution-NonCommercial-ShareAlike 2.5
-- Target Version:	SQL Server 2008 RTM
-- Tab/indent size:	4
-- Notes:			-
------------------------------------------------------------------------
use tempdb
go

--
-- SET BASED SOLUTION
--

set nocount on
set statistics io on
go

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
	row
	
	
