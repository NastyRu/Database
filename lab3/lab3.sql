use TourAgency

-- Скалярная функция
-- Количество человек, заказавших отель
CREATE FUNCTION dbo.count_clients (@Hotel AS VARCHAR(100))
RETURNS INT
BEGIN
    DECLARE @Count numeric

    SELECT @Count = SUM(C2.NumberAdults + C2.NumberChildren)
    FROM (Agency.Tours AS C1 JOIN Agency.Hotels AS C3 on C1.HotelId = C3.HotelId)
                  JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId
    WHERE C3.NameHotel = @Hotel

    RETURN @Count
END

GO

declare @i int
SET @i = dbo.count_clients('HELENA PARK')
print @i

SELECT dbo.count_clients('HELENA PARK') AS 'Count clients'

-- Подставляемая табличная функция
-- Количество отелей звездности
CREATE FUNCTION dbo.star_hotels (@stars INT)
RETURNS TABLE AS
RETURN
(
    SELECT *
    FROM Agency.Hotels
    WHERE Stars = @stars
);

GO

SELECT * FROM dbo.star_hotels(5)

-- Многооператорная табличная функция
-- Выбор отеля по количеству звезд или типу питания
CREATE FUNCTION dbo.find_hotels (@Stars int, @Food VARCHAR(100))
RETURNS @findHotels TABLE
(
    [HotelId] [INT] primary key NOT NULL,
    [NameHotel] [VARCHAR](100) NOT NULL,
    [Stars] [INT] NULL,
    [Food] [VARCHAR](100) NOT NULL,
    [CityId]  [INT] NOT NULL
)
AS
BEGIN
WITH OTV(HoteId, NameHotel, Stars, Food, CityId)
    AS (
        SELECT *
        FROM Agency.Hotels
        WHERE Stars = @Stars

        UNION

        SELECT *
        FROM Agency.Hotels
        WHERE Food = @Food
        )

   INSERT @findHotels
   SELECT HoteId, NameHotel, Stars, Food, CityId
   FROM OTV
   RETURN
END

GO

SELECT *
FROM dbo.find_hotels (5, 'UAI')

GO

-- Рекурсивная функция или функция с рекурсивным ОТВ
-- Текущее время
CREATE FUNCTION dbo.find_time(@City VARCHAR(100))
RETURNS @findtime TABLE
(
    [CityId] [INT] primary key NOT NULL,
    [NameCity] [VARCHAR](100) NOT NULL,
    [CountryId] [INT] NOT NULL,
    [TimeZone] [VARCHAR](100) NULL,
    [Now] [INT] NOT NULL
)
AS
BEGIN
WITH Time(CityId, NameCity, CountryId, TimeZone, Now)
    AS
    (
        SELECT CityId, NameCity, CountryId, TimeZone, CAST(FORMAT(GETDATE(),'hh') AS INT) AS Now
        FROM Location.Cities WHERE TimeZone IS NULL

        UNION ALL
        SELECT C1.CityId, C1.NameCity, C1.CountryId, C1.TimeZone, C2.Now + 1
        FROM Location.Cities AS C1 JOIN Time AS C2 ON C1.TimeZone = C2.CityId
    )
    INSERT @findtime
    SELECT CityId, NameCity, CountryId, TimeZone, Now
    FROM Time
    WHERE NameCity = @City
    RETURN
END

SELECT *
FROM dbo.find_time('Moscow')

-- Хранимая процедура без параметров или с параметрами
-- Клиенты сделавшие заказов
CREATE PROCEDURE dbo.find_clients
    @Num INT,
    @CountClients INT OUTPUT
AS
    SELECT @CountClients = Count(*)
    FROM (
             SELECT C2.ClientId, Name, Surname, COUNT(C1.TourId) AS Count
             FROM (Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId)
                      JOIN Agency.Clients AS C3 on C2.ClientId = C3.ClientId
             GROUP BY C2.ClientId, Name, Surname
             HAVING COUNT(C1.TourId) > @Num
         ) AS M
GO


declare @i int
EXEC dbo.find_clients 2, @i OUTPUT
print @i

-- Рекурсивная хранимая процедура или хранимая процедур с рекурсивным ОТВ
-- Вывод клиентов с именами из диапазона
CREATE PROCEDURE dbo.find_clients_names(@first VARCHAR, @second VARCHAR)
AS
    DECLARE @F INT
    DECLARE @E INT
    SET @F = ASCII(@first)
    SET @E = ASCII(@second)

    WHILE @first != @second
    BEGIN
        SELECT *
        FROM Agency.Clients
        WHERE Name LIKE @first + '%'
        SET @first = CHAR(ASCII(@first) + 1)
    END

    SELECT *
        FROM Agency.Clients
        WHERE Name LIKE @first + '%'
GO

dbo.find_clients_names 'A', 'B'

-- Хранимая процедура с курсором
-- Вывод городов из страны
CREATE PROCEDURE dbo.find_cities(@Country VARCHAR(100))
AS
    DECLARE @city VARCHAR(100)
    DECLARE city_cursor CURSOR
        LOCAL
        FORWARD_ONLY
        STATIC
    FOR
    SELECT NameCity
    FROM Location.Cities JOIN Location.Countries ON Cities.CountryId = Countries.CountryId
    WHERE NameCountry = @Country

    OPEN city_cursor
    FETCH NEXT FROM city_cursor
        INTO @city
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        PRINT @city
        FETCH NEXT FROM city_cursor
            INTO @city
    END

    CLOSE city_cursor
    DEALLOCATE city_cursor
GO

dbo.find_cities 'Russia'

-- Хранимая процедура доступа к метаданным
CREATE PROCEDURE access_to_metadata(@TableName VARCHAR(100))
WITH EXECUTE AS OWNER
AS
    BEGIN
        SELECT name, object_id, schema_id, type
        FROM sys.objects
        WHERE name = @TableName
    END
GO

access_to_metadata Tours

-- Триггер AFTER
CREATE TRIGGER wow
ON Agency.Clients
AFTER INSERT
AS
    BEGIN
        SELECT * FROM inserted
        PRINT 'New client!!!'
    END
GO

INSERT Agency.Clients VALUES ('Ivanov', 'Ivan', '89992346510', 'ivanovivan@mail.ru')

-- Триггер INSTEAD OF
CREATE TRIGGER no_insert
ON Location.Countries
INSTEAD OF INSERT, UPDATE, DELETE
AS
    BEGIN
        SELECT * FROM inserted
        SELECT * FROM deleted
        RAISERROR ('No able to insert!', 16, 10)
    END

INSERT Location.Countries VALUES ('Aaa')

UPDATE Location.Countries
SET NameCountry = 'aaa'
WHERE CountryId = 1

DELETE Location.Countries
WHERE CountryId = 1