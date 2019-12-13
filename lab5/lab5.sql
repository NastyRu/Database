USE TourAgency
GO

-- Извлечь данные с помощью конструкции FOR XML
SELECT C.NameCity
FROM Location.Cities AS C JOIN Location.Countries AS P ON C.CountryId = P.CountryId
WHERE P.NameCountry = 'Portugal'
FOR XML AUTO;

-- С помощью функции OPENXML и OPENROWSET выполнить загрузку и сохранение
-- XML-документа в таблице базы данных

DECLARE @idoc int, @doc xml;
SELECT @doc = C FROM OPENROWSET(BULK '/hotels.xml', SINGLE_BLOB) AS TEMP(C)
EXEC sp_xml_preparedocument @idoc OUTPUT, @doc;
INSERT INTO Agency.Hotels
SELECT *
FROM OPENXML(@idoc, '/ROOT/C', 1)
WITH Agency.Hotels;

SELECT * FROM Agency.Hotels
