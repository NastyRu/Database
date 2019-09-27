USE TourAgency
GO

CREATE TABLE Location.Countries(
    [CountryId] [INT] IDENTITY(1,1) NOT NULL,
    [NameCountry] [VARCHAR](100) NOT NULL,
)
GO
 
CREATE TABLE Location.Cities(
    [CityId]  [INT] IDENTITY(1,1) NOT NULL,
    [NameCity] [VARCHAR](100) NOT NULL,
    [CountryId] [INT] NOT NULL,
)
GO

CREATE TABLE Agency.Hotels(
    [HotelId] [INT] IDENTITY(1,1) NOT NULL,
    [NameHotel] [VARCHAR](100) NOT NULL,
    [Stars] [INT] NULL,
    [Food] [VARCHAR](100) NOT NULL,
    [CityId]  [INT] NOT NULL,
)
GO

CREATE TABLE Agency.Tours(
    [TourId] [INT] IDENTITY(1,1) NOT NULL,
    [Price] [INT] NOT NULL,
    [HotelId] [INT] NOT NULL,
    [Days] [INT] NOT NULL,
    [BeginingDate] [DATETIME] NOT NULL,
)
GO

CREATE TABLE Agency.Clients(
    [ClientId] [INT] IDENTITY(1, 1) NOT NULL,
    [Surname] [VARCHAR](100) NOT NULL,
    [Name] [VARCHAR](100) NOT NULL,
    [PhoneNumber] [VARCHAR](15) NOT NULL,
    [Email] [VARCHAR](100) NOT NULL,
)
GO

CREATE TABLE Agency.ClientsTours(
    [ClientId] [INT] NOT NULL,
    [TourId] [INT] NOT NULL,
    [NumberAdults] [INT] NOT NULL,
    [NumberChildren] [INT] NULL,
)