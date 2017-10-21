use tempdb
go

set nocount on
go

/*
	Make sure MAXDOP = 1
*/
EXEC sys.sp_configure N'show advanced options', N'1'  
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'max degree of parallelism', N'1'
RECONFIGURE WITH OVERRIDE
GO


/*
	Load Data
*/

exec dbo.stp_load_sample_data @rows = 100, @seats_per_row = 30000


/*
	Benchmark
*/
exec dbo.stp_row_by_row


/*
	Re-Enable Intra-Query Parallelism
*/
EXEC sys.sp_configure N'show advanced options', N'1'  
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'max degree of parallelism', N'0'
RECONFIGURE WITH OVERRIDE
GO

/*
	Benchmark
*/
exec dbo.stp_row_by_row

