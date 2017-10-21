use tempdb
go

truncate table dbo.[machine_data]
go

set nocount on
go

insert into dbo.machine_data 
values
(1, 'A', 1000),
(1, 'A', 1001),
(1, 'B', 1002),
(1, 'B', 1003),
(2, 'A', 1004),
(2, 'A', 1005),
(2, 'A', 1006),
(2, 'B', 1007),
(2, 'A', 1008),
(2, 'A', 1009),
(1, 'A', 1011),
(1, 'A', 1012),
(1, 'B', 1013),
(1, 'B', 1014),
(1, 'B', 1015),
(2, 'A', 1016),
(2, 'B', 1017),
(2, 'C', 1018),
(2, 'C', 1019),
(2, 'C', 1020),
(2, 'C', 1021),
(2, 'B', 1022),
(1, 'A', 1023),
(1, 'A', 1024),
(1, 'A', 1025),
(1, 'B', 1026),
(2, 'B', 1027),
(1, 'B', 1028),
(1, 'B', 1050),
(1, 'B', 1051),
(2, 'B', 1052),
(2, 'C', 1053),
(2, 'D', 1054),
(2, 'D', 1055),
(2, 'D', 1056),
(1, 'C', 1057),
(1, 'C', 1058),
(1, 'D', 1059)
go



	