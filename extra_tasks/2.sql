create table table1 (
    ID int,
    tariff char(1),
    begin_date date,
    end_date date
)

create table table2 (
    ID int,
    surname char(10),
    begin_date date,
    end_date date
)

insert into table1 values
(1,'A','2017-01-02','2018-01-01'),
(1,'B','2018-01-02','2019-01-01'),
(1,'C','2019-01-02','5999-01-01'),
(2,'B','2017-01-02','2018-01-01'),
(2,'C','2018-01-02','2019-01-01'),
(2,'A','2019-01-02','5999-01-01'),
(10,'A','2018-01-01','2019-01-01'),
(10,'B','2019-01-01','2019-01-01'),
(10,'C','2019-01-01','5999-01-01')

insert into table2 values
(1,'Ivanov','2010-01-30','2017-06-01'),
(1,'Sidorov','2017-06-02','2019-01-01'),
(1,'Petrov','2019-01-02','5999-02-01'),
(2,'Sidorov','2016-01-30','2017-01-01'),
(2,'Petrov','2017-01-02','2018-06-01'),
(2,'Ivanov','2018-06-02','5999-02-01'),
(10,'A','2018-01-01','2020-01-01'),
(10,'B','2020-01-02','5999-01-01')

drop table table1
drop table table2

select * from
table1 as t1 join table2 as t2 on t1.id = t2.id

select t1.ID, tariff, surname,
        begindate = (case
           when t1.begin_date > t2.begin_date then t1.begin_date
           else t2.begin_date end),
        enddate = (case
           when t1.end_date < t2.end_date then t1.end_date
           else t2.end_date end)
from table1 as t1 join table2 as t2 on t1.id = t2.id
where t1.begin_date < t2.end_date and t1.end_date > t2.begin_date