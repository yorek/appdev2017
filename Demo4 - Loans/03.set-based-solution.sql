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

-- First, new need to be able to genereate a rows for each rate
declare @start_date date = '20180101';
declare @end_date date = '20201231';
declare @payment_frequency smallint = 6;

select 
	rate_num = n-1, 
	payment_date = dateadd(day, -1 , dateadd(month, (t2.n-1)*@payment_frequency, @start_date)) -- always the last day of month
from 
	dbo.fn_Nums(100) t2
where
	dateadd(day, -1 , dateadd(month, (t2.n-1)*@payment_frequency, @start_date)) between @start_date and @end_date
go	

-- Now is a simple "exotic" join
with cte as 
(	
	select
		*,
		num_of_months = datediff(month, start_date, end_date) + 1	
	from
		dbo.original_data
),
cte2 as
(
	select
		*,
		num_of_rates = num_of_months / payment_frequency
	from
		cte
)
select
	*,
	payment_date = dateadd(day, -1, dateadd(month, (t2.n-1)*t1.payment_frequency, t1.start_date)), -- always the last day of month
	--value_amount = t1.total_value / (num_of_months / t1.payment_frequency),
	--interests_amount = t1.total_value * interest_rate * (payment_frequency / 12.),
	total_rate_amount = ceiling(t1.total_value / (num_of_months / t1.payment_frequency) +  t1.total_value * interest_rate * (payment_frequency / 12.))
from
	cte2 t1
inner join
	dbo.fn_Nums(100) t2 on dateadd(day, -1, dateadd(month, (t2.n-1)*t1.payment_frequency, t1.start_date)) between t1.start_date and t1.end_date
order by
	t1.id, payment_date
go
	