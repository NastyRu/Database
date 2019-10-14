create database kot
use kot
create table kot_table (
    [id] [int] NOT NULL
)

select * from kot_table

insert into kot_table values
(10), (-2),(3),(-4),(5),(10)

delete from kot_table;

select round(exp(sum(log(IIF([id] < 0, [id] * (-1), (IIF([id] <> 0,[id],1)))))),0) * IIF(sum(IIF([id] = 0, 1, 0)) = 0, 1, 0) * power(-1, (sum(IIF([id] < 0, 1, 0) % 2)))
from kot_table