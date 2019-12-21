CREATE DATABASE RK2;
USE RK2;

CREATE TABLE Time (
    [Id] [INT] NOT NULL,
    [Data] [DATE] NOT NULL,
    [WeekDay] CHAR(10) NOT NULL,
    [Time] [TIME] NOT NULL,
    [Type] [INT] NOT NULL
);

CREATE TABLE Workers (
    [Id] [INT] IDENTITY(1,1) NOT NULL,
    [Fio] CHAR(100) NOT NULL,
    [BirthDate] [DATE] NOT NULL,
    [Department] CHAR(100) NOT NULL
);

ALTER TABLE Workers ADD
    CONSTRAINT [PK_Workers] PRIMARY KEY (Id)
GO

ALTER TABLE Time ADD
    CONSTRAINT [FK_Time_Workers] FOREIGN KEY (Id) REFERENCES Workers (Id)
GO

INSERT INTO Workers VALUES
('Ivanov','1990-09-25','IT'),
('Petrov','1987-11-12','Accounting'),
('Sidorov','1980-01-16','IT'),
('Smirnov','1970-03-31','Accounting')

INSERT INTO Time VALUES
(1,'2019-12-15','Saturday','9:00:00',1),
(1,'2019-12-15','Saturday','9:20:00',2),
(1,'2019-12-15','Saturday','9:25:00',1),
(1,'2019-12-15','Saturday','17:25:00',2),
(1,'2019-12-16','Sunday','9:00:00',1),
(1,'2019-12-16','Sunday','19:20:00',2),
(1,'2019-12-17','Monday','9:00:00',1),
(1,'2019-12-17','Monday','18:20:00',2),
(1,'2019-12-18','Tuesday','9:00:00',1),
(1,'2019-12-18','Tuesday','9:20:00',2),
(1,'2019-12-18','Tuesday','10:00:00',1),
(1,'2019-12-18','Tuesday','19:00:00',2),
(1,'2019-12-19','Wednesday','9:20:00',1),
(1,'2019-12-19','Wednesday','19:25:00',2),
(1,'2019-12-20','Thursday','9:20:00',1),
(1,'2019-12-20','Thursday','13:00:00',2),
(1,'2019-12-21','Friday','9:00:00',1),
(1,'2019-12-21','Friday','19:25:00',2),

(2,'2019-12-15','Saturday','9:00:00',1),
(2,'2019-12-15','Saturday','19:20:00',2),
(2,'2019-12-16','Sunday','9:00:00',1),
(2,'2019-12-16','Sunday','19:20:00',2),
(2,'2019-12-17','Monday','9:00:00',1),
(2,'2019-12-17','Monday','13:00:00',2),
(2,'2019-12-18','Tuesday','9:05:00',1),
(2,'2019-12-18','Tuesday','18:30:00',2),
(2,'2019-12-19','Wednesday','9:20:00',1),
(2,'2019-12-19','Wednesday','19:25:00',2),
(2,'2019-12-20','Thursday','9:00:00',1),
(2,'2019-12-20','Thursday','18:25:00',2),
(2,'2019-12-21','Friday','9:20:00',1),
(2,'2019-12-21','Friday','11:25:00',2),

(3,'2019-12-17','Monday','9:00:00',1),
(3,'2019-12-17','Monday','19:00:00',2),
(3,'2019-12-18','Tuesday','9:05:00',1),
(3,'2019-12-18','Tuesday','18:00:00',2),
(3,'2019-12-19','Wednesday','9:00:00',1),
(3,'2019-12-19','Wednesday','19:25:00',2),
(3,'2019-12-19','Thursday','9:00:00',1),
(3,'2019-12-19','Thursday','18:25:00',2),
(3,'2019-12-20','Friday','9:00:00',1),
(3,'2019-12-20','Friday','19:00:00',2),
(3,'2019-12-15','Saturday','9:10:00',1),
(3,'2019-12-15','Saturday','19:20:00',2),
(3,'2019-12-16','Sunday','9:00:00',1),
(3,'2019-12-16','Sunday','19:20:00',2)

(4,'2019-12-15','Saturday','9:00:00',1),
(4,'2019-12-15','Saturday','19:20:00',2),
(4,'2019-12-16','Sunday','9:00:00',1),
(4,'2019-12-16','Sunday','19:20:00',2),
(4,'2019-12-17','Monday','9:00:00',1),
(4,'2019-12-17','Monday','18:00:00',2),
(4,'2019-12-18','Tuesday','8:50:00',1),
(4,'2019-12-18','Tuesday','18:30:00',2),
(4,'2019-12-19','Wednesday','9:00:00',1),
(4,'2019-12-19','Wednesday','19:25:00',2),
(4,'2019-12-20','Thursday','9:00:00',1),
(4,'2019-12-20','Thursday','18:25:00',2),
(4,'2019-12-21','Friday','8:55:00',1),
(4,'2019-12-21','Friday','18:25:00',2)

CREATE FUNCTION dbo.avg_lates(@Day AS DATE)
RETURNS INT
BEGIN
    DECLARE @Avg numeric
    SET @Avg = 0

    SELECT @Avg = AVG(2019 - DATEPART(year, BirthDate))
    FROM
        (
            SELECT Time.Id, BirthDate, Department,
            (
                SELECT MIN(Time)
                FROM Time AS T
                WHERE Type = 1 AND T.Id = Time.Id AND T.Data = Time.Data
            ) AS BeginDay
            FROM Time JOIN Workers ON Time.Id = Workers.Id
            WHERE Data = @Day
            GROUP BY Time.Id, WeekDay, Fio, Data, BirthDate, Department
        ) AS T
    WHERE BeginDay > '09:00:00' AND Department = 'IT'

    RETURN @Avg
END

SELECT dbo.avg_lates('2019-12-20') AS 'Average age'