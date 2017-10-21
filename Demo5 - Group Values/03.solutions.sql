use tempdb
go

-- I/O info, please :-)
set statistics io on
go

-- Show sample data
select 
	* 
from 
	dbo.machine_data 
where 
	MachineId = 1 
order by 
	[Date] Desc
go


/*

	Get the lastest Status value of each machine
	
*/

-- Looks-like a nice solution....
with b as
(
	select 
		distinct [MachineId]
	from 
		dbo.[machine_data]
)
select 
	a.MachineID, a.[Status], a.[Date]
from 
	b
cross apply
(
	select top 1 
		*
	from 
		dbo.[machine_data] a
	where 
		a.[MachineId] = b.[MachineId]
	order by [Date] desc
) a 
order by 
	[MachineId]
go


-- Creating another solution is easy, we just need to
-- "extract" the hidded information of first row position in time.
-- This help has to easy find the first rows no matter the [Date] value is
select
	n = row_number() over (partition by [MachineId] order by [Date] desc),       
    [MachineId],
    [Status],
    [Date]
from
	dbo.[machine_data]
where
	[MachineId] = 1
go


-- Now is just a matter of filtering only the first rows
with cte as
(
	select
		n = row_number() over (partition by [MachineId] order by [Date] desc),       
		[MachineId],
		[Status],
		[Date]
	from
		dbo.[machine_data]
)
select
	[MachineId],
	[Status],
	[Date]
from
	[cte]
where
	n = 1
order by 
	[MachineId]
go


/* this would work too from sql server 2012, just be aware to use ROWS and not RANGE, which is the default option! */
select
	n = last_value([Status]) over (partition by [MachineId] order by [Date] desc rows between unbounded preceding and current row),       
	[MachineId],
	[Status],
	[Date]
from
	dbo.[machine_data]
;

/* not so good */
select
	n = last_value([Status]) over (partition by [MachineId] order by [Date]),    
	-- n = last_value([Status]) over (partition by [MachineId] order by [Date] range between unbounded preceding and current row), 
	[MachineId],
	[Status],
	[Date]
from
	dbo.[machine_data]
;

/*

	BONUS

	Now I want the most frequently reported status in time.
	If two or more status happened an equal number of times, return the
	one with the highest level (A=lower, Z=higher)
	
	Note: Open and run SQL Profiler
	
*/

-- Create a UDF to help

if (object_id('dbo.GetMostFrequentStatus') is not null) drop function dbo.GetMostFrequentStatus
go
create function [dbo].[GetMostFrequentStatus] (@machine_id int)
returns char(1)
as
begin
	declare @r char(1)
	
    set @r = 
    (
		select top 1 
			[Status]
		from 
			dbo.[machine_data]
		where
			MachineId = @machine_id
		group by
			[Status]
		order by
			count(*) desc, [Status] desc 		
	)
	
	return @r
end
go

-- Simple query that uses UDF. 
select distinct 
	MachineId,
	[MostFrequentStatus] = [dbo].[GetMostFrequentStatus](MachineId)
from
	dbo.[machine_data]
order by
	MachineId

-- Now let's use the same approach used before to create a real 
-- set based solution
with cte as
(
	select
		[MachineId],
		[Status],
		[NumOfTimesReported] = count(*)
	from
		dbo.[machine_data]
	group by
		[MachineId], [Status]
),
cte2 as
(
	select
		rn = row_number() over (partition by MachineId order by NumOfTimesReported desc, [Status] desc),
		*
	from
		cte
)
select
	[MachineId],
	MostFrequentStatus = [Status],
	[NumOfTimesReported]
from
	[cte2]
where
	rn = 1
order by 
	[MachineId]
go
