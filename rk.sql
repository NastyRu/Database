-- Рубежный контроль 2
-- Сиденко Анастасия
-- ИУ7-53Б
-- Вариант файла - 2
-- Мой вариант - 2

-- Создание базы данных
CREATE DATABASE RK2
GO

USE RK2

-- Создание таблиц
CREATE TABLE Candies(
    [Id] [INT] IDENTITY(1,1) NOT NULL,
    [NameCandy] [VARCHAR](100) NOT NULL,
    [Composition] [VARCHAR](100) NOT NULL,
    [Description] [VARCHAR](100) NOT NULL,
)
GO

CREATE TABLE Provider(
    [Id]  [INT] IDENTITY(1,1) NOT NULL,
    [NameProvider] [VARCHAR](100) NOT NULL,
    [INN] [VARCHAR](100) NOT NULL,
    [Address] [VARCHAR](100) NOT NULL,
)
GO

CREATE TABLE Outlets(
    [Id]  [INT] IDENTITY(1,1) NOT NULL,
    [NameOutlet] [VARCHAR](100) NOT NULL,
    [Address] [VARCHAR](100) NOT NULL,
    [Data] [DATETIME] NOT NULL,
    [Rating] [INT] NOT NULL,
)
GO

CREATE TABLE CandiesProviders(
    [IdCandies] [INT] NOT NULL,
    [IdProviders] [INT] NOT NULL,
)
GO

CREATE TABLE ProvidersOutlets(
    [IdOutlet] [INT] NOT NULL,
    [IdProviders] [INT] NOT NULL,
)
GO

CREATE TABLE CandiesOutlets(
    [IdOutlets] [INT] NOT NULL,
    [IdCandies] [INT] NOT NULL,
)
GO

-- Добавление ограничений
ALTER TABLE Candies ADD
    CONSTRAINT [PK_Candies] PRIMARY KEY (Id)
GO

ALTER TABLE Provider ADD
    CONSTRAINT [PK_Provider] PRIMARY KEY (Id)
GO

ALTER TABLE Outlets ADD
    CONSTRAINT [PK_Outlets] PRIMARY KEY (Id)
GO

ALTER TABLE CandiesProviders ADD
    CONSTRAINT [PK_CandiesProviders] PRIMARY KEY (IdCandies, IdProviders),
    CONSTRAINT [FK_CandiesProviders_Candy] FOREIGN KEY (IdCandies) REFERENCES Candies (Id),
    CONSTRAINT [FK_CandiesProviders_Provider] FOREIGN KEY (IdProviders) REFERENCES Provider (Id)
GO

ALTER TABLE ProvidersOutlets ADD
    CONSTRAINT [PK_ProvidersOutlets] PRIMARY KEY (IdOutlet, IdProviders),
    CONSTRAINT [FK_ProvidersOutlets_Outlet] FOREIGN KEY (IdOutlet) REFERENCES Outlets (Id),
    CONSTRAINT [FK_ProvidersOutlets_Provider] FOREIGN KEY (IdProviders) REFERENCES Provider (Id)
GO

ALTER TABLE CandiesOutlets ADD
    CONSTRAINT [PK_CandiesOutlets] PRIMARY KEY (IdCandies, IdOutlets),
    CONSTRAINT [FK_CandiesOutlets_Candy] FOREIGN KEY (IdCandies) REFERENCES Candies (Id),
    CONSTRAINT [FK_CandiesOutlets_Outlet] FOREIGN KEY (IdOutlets) REFERENCES Outlets (Id)
GO

-- Добавление данных
INSERT INTO Candies VALUES
('A','AAAAAAA','aaaaaaa'),
('B','BBBBBBB','bbbbbbb'),
('C','CCCCCCC','ccccccc'),
('D','DDDDDDD','ddddddd'),
('E','EEEEEEE','eeeeeee')

INSERT INTO Provider VALUES
('A','1111111','aaaaaaa'),
('B','2222222','bbbbbbb'),
('C','3333333','ccccccc'),
('D','4444444','ddddddd'),
('E','5555555','eeeeeee')

INSERT INTO Outlets VALUES
('A','A1','2010-01-30',2),
('B','B2','2011-03-03',3),
('C','C3','2013-02-11',3),
('D','D4','2015-10-10',5),
('E','E5','2018-08-21',4)

INSERT INTO CandiesProviders VALUES
(1,5),
(2,3),
(2,1),
(1,3),
(4,3)

INSERT INTO CandiesOutlets VALUES
(1,3),
(2,4),
(3,1),
(2,3),
(5,3)

INSERT INTO ProvidersOutlets VALUES
(1,1),
(2,2),
(2,3),
(1,3),
(4,3),
(1,2)

-- Select, использующий предикат сравнения
-- В магазине по какому адресу продается сладость с именем = A
SELECT DISTINCT C1.NameCandy, C3.NameOutlet, C3.Address
FROM Candies AS C1 JOIN CandiesOutlets AS C2 ON C2.IdCandies = C1.Id
JOIN Outlets AS C3 ON C3.Id = C2.IdOutlets
WHERE C1.NameCandy = 'A'

-- С оконной функцией
-- Вывод самого высокого рейтинга магазина для каждой сладости
SELECT DISTINCT C1.NameCandy,
       MAX(C3.Rating) OVER(PARTITION BY C1.Id) AS Best
INTO SomeTable
FROM Candies AS C1 JOIN CandiesOutlets AS C2 ON C2.IdCandies = C1.Id
JOIN Outlets AS C3 ON C3.Id = C2.IdOutlets

SELECT * FROM SomeTable

-- Select, использующий вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM
-- Вывод поставщиков с наименьшим и наибольшим количеством существующих точек и количество точек(обязательно точки есть)
SELECT 'MAX' AS Criteria, C.Id, C.NameProvider, SQ AS 'Number of outlets'
FROM Provider AS C JOIN
    (
        SELECT TOP 1 C1.Id, C1.NameProvider, COUNT(IdOutlet) AS SQ
        FROM (Provider AS C1 JOIN ProvidersOutlets AS C2 ON C1.Id = C2.IdProviders
            JOIN Outlets C3 on C3.Id = C2.IdOutlet)
        GROUP BY C1.Id, C1.NameProvider
        ORDER BY SQ DESC
    ) AS OD ON OD.Id = C.Id
UNION
SELECT 'MIN' AS Criteria, C.Id, C.NameProvider, SQ AS 'Number of outlets'
FROM Provider AS C JOIN
    (
        SELECT TOP 1 C1.Id, C1.NameProvider, COUNT(IdOutlet) AS SQ
        FROM (Provider AS C1 JOIN ProvidersOutlets AS C2 ON C1.Id = C2.IdProviders
            JOIN Outlets C3 on C3.Id = C2.IdOutlet)
        GROUP BY C1.Id, C1.NameProvider
        ORDER BY SQ
    ) AS OD ON OD.Id = C.Id

-- Хранимая процедура с входным параметром, которая выводит имена и описания типа объектов
-- (хранимых процедур и скалярных функций), в тексте которых встречается строка задаваемая параметром процедуры

-- процедура для тестирования

CREATE PROCEDURE access_to_metadata
WITH EXECUTE AS OWNER
AS
    BEGIN
        SELECT *
        FROM sys.sql_modules
    END
GO

-- функция для тестирования

CREATE FUNCTION rating (@rate INT)
RETURNS TABLE AS
RETURN
(
    SELECT *
    FROM Outlets
    WHERE Rating = @rate
);

-- процедура вывода необходимых

CREATE PROCEDURE metadata_string(@String VARCHAR(100))
WITH EXECUTE AS OWNER
AS
    BEGIN
        SELECT C1.object_id, OBJECT_NAME(C1.object_id) AS object_name, C2.type
        FROM sys.sql_modules AS C1 JOIN sys.objects AS C2 ON C2.object_id = C1.object_id
        WHERE definition LIKE '%' + @String + '%'
    END
GO

drop procedure metadata_string;

-- выведет 2 процедуры
metadata_string 'END';

-- выведет все ( 2 процедуры и функцию)
metadata_string 'SELECT';

-- ничего не подходит
metadata_string 'aaaa';

