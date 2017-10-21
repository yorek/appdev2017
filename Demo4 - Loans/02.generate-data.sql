use tempdb
go

truncate table dbo.original_data 
go

insert dbo.original_data values (1, '20180101', '20201231', 10000, 0.05, 6);
insert dbo.original_data values (2, '20170101', '20211231', 20000, 0.01, 3);
insert dbo.original_data values (3, '20190101', '20221231', 30000, 0.05, 6);
insert dbo.original_data values (4, '20190101', '20291231', 10000, 0.05, 1);
go

select * from dbo.original_data
go
