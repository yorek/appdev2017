use tempdb
go

if (OBJECT_ID('dbo.machine_data') is not null) drop table dbo.machine_data
go

GO
CREATE TABLE [dbo].[machine_data]
(
	[Id] int identity not null primary key,
	[MachineId] [int] NOT NULL,
	[Status] [char](1) NOT NULL,
	[Date] [datetime] NOT NULL
)
go
