use tempdb
go

/*

	Reset System & Warm Up Cache

*/
dbcc dropcleanbuffers
dbcc freeproccache
go
exec [dbo].[stp_GetStockValues_RowByRow] 1;
exec [dbo].[stp_GetStockValues_NotReallySetBased] 1;
exec [dbo].[stp_GetStockValues_SetBased] 1;
go

-- Test Stored Procedures 
-- while using Profiler to capture performance data 

-- Get SPID to be used with Profiler to filter out uneeded data
select @@SPID
go

exec [dbo].[stp_GetStockValues_RowByRow] 1;
go

exec [dbo].[stp_GetStockValues_NotReallySetBased] 1;
go

exec [dbo].[stp_GetStockValues_SetBased] 1;
go


 