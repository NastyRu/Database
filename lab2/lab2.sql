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

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
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
         FROM (Agency.Tours AS C1 JOIN Agency.ClientsTours AS C2 ON C1.TourId = C2.TourId)
                  JOIN Agency.Clients AS C3 on C2.ClientId = C3.ClientId
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