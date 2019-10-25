USE TourAgency

-- 1. Инструкция SELECT, использующая предикат сравнения
-- Города Аргентины
SELECT DISTINCT C1.NameCountry, C2.NameCity
FROM Location.Countries AS C1 JOIN Location.Cities AS C2 ON C2.CountryId = C1.CountryId
WHERE C1.NameCountry = 'Argentina'
ORDER BY C1.NameCountry, C2.NameCity

-- 2. Инструкция SELECT, использующая предикат BETWEEN
-- Получить список клиентов, заказавшим тур между '2018-01-01' и '2018-12-31'
SELECT DISTINCT C2.ClientId, C1.BeginingDate
FROM Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId
WHERE BeginingDate BETWEEN '2018-01-01' AND '2018-01-31'

-- 3. Инструкция SELECT, использующая предикат LIKE
-- Получить список стран, где в названии городов присутствует 'Al'
SELECT DISTINCT NameCountry
FROM Location.Countries AS C1 JOIN Location.Cities AS C2 ON C1.CountryId = C2.CountryId
WHERE C2.NameCity LIKE '%Al%'

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Получить список туров в Токио
SELECT TourId, HotelId
FROM Agency.Tours
WHERE HotelId IN
      (
          SELECT C1.HotelId
          FROM Agency.Hotels AS C1 JOIN Location.Cities AS C2 ON C1.CityId = C2.CityId
          WHERE C2.NameCity = 'Tokyo'
      )

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- Получить список российских 5-звездочных отелей
SELECT HotelId, NameHotel
FROM Agency.Hotels AS C
WHERE Stars = 5 AND
    EXISTS
        (
            SELECT C1.HotelId, C1.NameHotel
            FROM Agency.Hotels AS C1 JOIN Location.Cities AS C2 ON C1.CityId = C2.CityId
            WHERE C2.CountryId IN
                  (
                      SELECT CountryId
                      FROM Location.Countries
                      WHERE NameCountry = 'Russia'
                  )
              AND C.HotelId = C1.HotelId
        )

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором общности (ALL).
-- Получить список туров в отель 1, цена которых больше цены любого тура в отель 2
SELECT TourId, Price
FROM Agency.Tours
WHERE Price > ALL
      (
          SELECT Price
          FROM Agency.Tours
          WHERE HotelId = 1
      ) AND HotelId = 2

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- Средняя стоимость туров
SELECT AVG(TotalPrice) AS 'Actual AVG',
       SUM(TotalPrice) / COUNT(HotelId) AS 'Calc AVG'
FROM (
         SELECT HotelId, SUM(Price * (NumberAdults + NumberChildren)) AS TotalPrice
         FROM Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId
         GROUP BY HotelId
     ) AS TotOrders

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- Средняя и минимальная стоимость на туры в Россию
SELECT CityId, NameCity,
       (
           SELECT AVG(Price)
           FROM Agency.Tours AS C1
           WHERE C1.HotelId IN
                 (
                     SELECT Hotels.HotelId
                     FROM Agency.Hotels
                     WHERE Hotels.CityId = C.CityId
                 )
       ) AS AvgPrice,
       (
           SELECT MIN(Price)
           FROM Agency.Tours AS C1
           WHERE C1.HotelId IN
                 (
                     SELECT Hotels.HotelId
                     FROM Agency.Hotels
                     WHERE Hotels.CityId = C.CityId
                 )
       ) AS MinPrice
FROM Location.Cities AS C
WHERE CountryId IN
    (
        SELECT CountryId
        FROM Location.Countries
        WHERE NameCountry = 'Russia'
    )

-- 9. Инструкция SELECT, использующая простое выражение CASE
-- Когда были заказы тура и какими клиентами
SELECT C1.TourId, C2.ClientId, Name, Surname,
       CASE YEAR(BeginingDate)
           WHEN YEAR(GETDATE()) THEN 'This Year'
           WHEN YEAR(GETDATE()) - 1 THEN 'Last year'
           ELSE IIF(YEAR(GETDATE()) > YEAR(BeginingDate), CAST(DATEDIFF(year, BeginingDate, Getdate()) AS varchar(5)) + ' years ago',
           CAST(-DATEDIFF(year, BeginingDate, Getdate()) AS varchar(5)) + ' years after')
       END AS 'When'
FROM (Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId)
                  JOIN Agency.Clients AS C3 on C2.ClientId = C3.ClientId
ORDER BY TourId

-- 10. Инструкция SELECT, использующая поисковое выражение CASE
-- Деление туров по цене
SELECT TourId,
    CASE
        WHEN Price < 200 THEN 'Inexpensive'
        WHEN Price < 500 THEN 'Fair'
        WHEN Price < 800 THEN 'Expensive'
        ELSE 'Very Expensive'
    END AS Price
FROM Agency.Tours

-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
-- Туры в Россию
SELECT TourId, HotelId, Days, Price
INTO #ToursRussia
FROM Agency.Tours
WHERE HotelId IN
      (
          SELECT C1.HotelId
          FROM Agency.Hotels AS C1 JOIN Location.Cities AS C2 ON C1.CityId = C2.CityId
          WHERE CountryId IN
                (
                    SELECT CountryId
                    FROM Location.Countries
                    WHERE NameCountry = 'Russia'
                )
      )
SELECT * FROM #ToursRussia
DROP TABLE #ToursRussia

-- 12. Инструкция SELECT, использующая вложеные коррелированные подзапросы в качестве производных таблиц в предложении FROM
-- Туры с максимальной и минимальной стоимостью
SELECT 'MAX' AS Criteria, C.TourId, SQ AS 'Price'
FROM Agency.Tours AS C JOIN
    (
        SELECT TOP 1 C1.TourId, SUM(Price * (NumberAdults + NumberChildren)) AS SQ
        FROM (Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId)
        GROUP BY C1.TourId
        ORDER BY SQ DESC
    ) AS OD ON OD.TourId = C.TourId
UNION
SELECT 'MIN' AS Criteria, C.TourId, SQ
FROM Agency.Tours AS C JOIN
    (
        SELECT TOP 1 C1.TourId, SUM(Price * (NumberAdults + NumberChildren)) AS SQ
        FROM (Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId)
        GROUP BY C1.TourId
        ORDER BY SQ
    ) AS OD ON OD.TourId = C.TourId

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3
-- Туры с максимальной и минимальной стоимостью
SELECT 'MAX' AS Criteria, C.TourId
FROM Agency.Tours AS C
WHERE TourId =
    (
        SELECT C1.TourId
        FROM Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId
        GROUP BY C1.TourId
        HAVING SUM(Price * (NumberAdults + NumberChildren)) =
               (
                    SELECT MAX(SQ)
                    FROM
                    (
                        SELECT SUM(Price * (NumberAdults + NumberChildren)) AS SQ
                        FROM Agency.Tours JOIN Agency.ClientsTours ON Tours.TourId = ClientsTours.TourId
                        GROUP BY Tours.TourId
                    ) AS OD
                )
    )
UNION
SELECT 'MIN' AS Criteria, C.TourId
FROM Agency.Tours AS C
WHERE TourId =
    (
        SELECT C1.TourId
        FROM Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId
        GROUP BY C1.TourId
        HAVING SUM(Price * (NumberAdults + NumberChildren))=
               (
                    SELECT MIN(SQ)
                    FROM
                    (
                        SELECT SUM(Price * (NumberAdults + NumberChildren))AS SQ
                        FROM Agency.Tours JOIN Agency.ClientsTours ON Tours.TourId = ClientsTours.TourId
                        GROUP BY Tours.TourId
                    ) AS OD
                )
    )

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- Для каждого тура получить его среднюю цену и минимальную цену
SELECT C1.TourId,
       AVG(Price * (NumberAdults + NumberChildren)) AS AvgPrice,
       MIN(Price * (NumberAdults + NumberChildren)) AS MinPrice
FROM (Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId)
GROUP BY C1.TourId

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- Получить список туров, средняя цена которых больше общей средней
SELECT C.TourId,
       AVG(Price * (NumberAdults + NumberChildren)) AS AvgPrice
FROM (Agency.Tours AS C JOIN Agency.ClientsTours ON C.TourId = ClientsTours.TourId)
GROUP BY C.TourId
HAVING AVG(Price * (NumberAdults + NumberChildren)) >
    (
        SELECT AVG(C1.Price * (C2.NumberAdults + C2.NumberChildren)) AS MPrice
        FROM (Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId)
    )

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
INSERT INTO Agency.Clients VALUES
('Stepanov', 'Alexander', '89993456510', 'aaaaa@mail.ru')

SELECT * FROM Agency.Clients

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса
INSERT Agency.ClientsTours
SELECT (
    SELECT MAX(ClientId)
    FROM Agency.Clients
    ), TourId, 2, 0
FROM TourAgency.Agency.Tours
WHERE HotelId = 8

SELECT * FROM Agency.ClientsTours

-- 18. Простая инструкция UPDATE.
SELECT * FROM Agency.Tours

UPDATE Agency.Tours
SET Price = Price / 1.5
WHERE TourId = 1

SELECT * FROM Agency.Tours

-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
SELECT * FROM Agency.Tours

UPDATE Agency.Tours
SET Price =
    (
        SELECT AVG(Price)
        FROM Agency.Tours
    )
WHERE TourId = 1

SELECT * FROM Agency.Tours

-- 20. Простая инструкция DELETE.
DELETE Agency.Hotels
WHERE Stars IS NULL

-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
INSERT INTO Agency.ClientsTours VALUES
(1,1,1,NULL)

DELETE FROM Agency.ClientsTours
WHERE ClientId IN
(
    SELECT TOP 1 ClientId
    FROM Agency.ClientsTours
    WHERE NumberChildren IS NULL
    ORDER BY ClientId DESC
)

-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
-- Табличное выражение продаж туров по годам
WITH Sales_CTE(SalesYear, SalesCount, SalesPrice)
AS
    (
        SELECT YEAR(BeginingDate) AS SalesYear, COUNT(C1.TourId), SUM(Price * (NumberChildren + NumberAdults))
        FROM Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId
        GROUP BY YEAR(BeginingDate)
    )
SELECT * FROM Sales_CTE
ORDER BY SalesYear

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
-- Замена всех слов, чтоб начинались с заглавной буквы

-- ASCII код первой буквы
WITH Ascii_code AS
(
    SELECT ASCII('A') AS code
),
-- для регистронезависимых баз данных символы 'a' и 'A' не различаются (замена символов, идущих после пробела, перебор A-Z
Repl(Name, Code, Rep) AS
(
    SELECT NameCountry AS Name,
           Code,
           -- первая буква заглавная, остальные строчные и замена всех А (после пробела) на заглавные
           REPLACE(UPPER(LEFT(NameCountry, 1)) + LOWER(SUBSTRING(NameCountry, 2, LEN(NameCountry) - 1)),' ' + CHAR(Code),' ' + CHAR(Code)) AS Rep
    FROM Ascii_code, Location.Countries

    UNION ALL

    SELECT name,
           Code + 1 AS Code,
           -- перебор всех оставшихся букв B-Z
           REPLACE(Rep, ' ' + CHAR(Code + 1), ' ' + CHAR(Code + 1)) AS Rep
    FROM Repl
    -- выполняем пока не дошли до Z
    WHERE Code < ASCII('Z')
)
SELECT Name, Rep
FROM Repl
WHERE Code = ASCII('Z')

-- Часовые пояса
ALTER TABLE Location.Cities ADD TimeZone INT NULL
UPDATE Location.Cities
SET Cities.TimeZone = ABS(CHECKSUM(NEWID()) % (CityId - 1)) + 1
WHERE Cities.TimeZone IS NOT NULL

SELECT * FROM Location.Cities

UPDATE Location.Cities
SET Cities.TimeZone = NULL
WHERE Cities.CityId = 1

WITH Time(CityId, NameCity, CountryId, TimeZone, Now)
AS
(
    SELECT CityId, NameCity, CountryId, TimeZone, CAST(FORMAT(GETDATE(),'hh') AS INT) AS Now
    FROM Location.Cities WHERE TimeZone IS NULL

    UNION ALL
    SELECT C1.CityId, C1.NameCity, C1.CountryId, C1.TimeZone, C2.Now + 1
    FROM Location.Cities AS C1 JOIN Time AS C2 ON C1.TimeZone = C2.CityId
)
SELECT * FROM Time

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
-- Для каждого заказанного тура выводи среднее, максимальное и минимальное
SELECT P.TourId,
       P.Price * (NumberChildren + NumberAdults) AS Price,
       AVG(P.Price * (NumberChildren + NumberAdults)) OVER(PARTITION BY P.TourId) AS AvgPrice,
       MIN(P.Price * (NumberChildren + NumberAdults)) OVER(PARTITION BY P.TourId) AS MinPrice,
       MAX(P.Price * (NumberChildren + NumberAdults)) OVER(PARTITION BY P.TourId) AS MaxPrice
INTO SomeTable
FROM Agency.Tours P JOIN Agency.ClientsTours OD ON OD.TourId = P.TourId

-- 25. Устранить дублирующиеся строки с использованием функции ROW_NUMBER()
WITH cte AS
    (
        SELECT
            RN = ROW_NUMBER() OVER(PARTITION BY TourId, Price, AvgPrice, MinPrice, MaxPrice ORDER BY TourId)
        FROM SomeTable
    )
DELETE TOP (1000) FROM cte WHERE RN > 1;
SELECT * FROM SomeTable
