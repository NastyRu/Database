USE TourAgency

GO

BULK INSERT Location.Countries
FROM '\countries.txt'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '0x0a');

GO

BULK INSERT Location.Cities
FROM '\cities.txt'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '0x0a');

GO

BULK INSERT Agency.Hotels
FROM '\hotels.txt'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '0x0a');

GO

BULK INSERT Agency.Tours
FROM '\tours.txt'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '0x0a');

GO

BULK INSERT Agency.Clients
FROM '\clients.txt'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '0x0a');

GO

BULK INSERT Agency.ClientsTours
FROM '\clientstours.txt'
WITH (FIELDTERMINATOR = ';', ROWTERMINATOR = '0x0a');

GO