use tempdb
go

/*
	View Data
*/
select * from dbo.machine_data order by [TimeStamp]

select * from dbo.machine_data 
where MachineId = 1 order by [TimeStamp]

/*
	Solution
*/

-- The Idea
select
	rn1 = ROW_NUMBER() over (order by MachineId, [Status], [TimeStamp]),
	rn2 = ROW_NUMBER() over (order by [TimeStamp]),
	*
from
	dbo.machine_data
where
	 MachineId = 1
order by 
	[TimeStamp];
	
-- The Implementation
with cte as
(
	select
		rn1 = ROW_NUMBER() over (order by MachineId, [Status], [TimeStamp]),
		rn2 = ROW_NUMBER() over (order by [TimeStamp]),
		*
	from
		dbo.machine_data
),
cte2 as 
(
	select
		gk = rn1-rn2,
		*
	from
		cte
)
select
	MachineId, 
	Status, 
	--Gk,
	TSFrom = MIN(TimeStamp), 
	TSTo = MAX(TimeStamp)
from
	cte2
group by
	MachineId, Status, Gk		
order by
	TSFrom, TSTo;

