USE TourAgency

CREATE TABLE Countries(
	[CountryId] [INT] IDENTITY(1,1) NOT NULL,
	[NameCointry] [VARCHAR](100) NOT NULL,
)

GO
 
CREATE TABLE Cities(
	[CityId]  [INT] IDENTITY(1,1) NOT NULL,
	[NameCity] [VARCHAR](100) NOT NULL,
	[CountryId] [INT] NOT NULL,
)

GO

CREATE TABLE Hotels(
	[HotelId] [INT] IDENTITY(1,1) NOT NULL,
	[NameHotel] [VARCHAR](100) NOT NULL,
	[Stars] [INT] NULL,
	[Food] [VARCHAR](100) NOT NULL,
	[CityId]  [INT] NOT NULL,
)

GO

CREATE TABLE Tour(
	[TourId] [INT] IDENTITY(1,1) NOT NULL,
	[Price] [INT] NOT NULL,
	[HotelId] [INT] NOT NULL,
	[Days] [INT] NOT NULL,
	[BeginnigDate] [DATETIME] NOT NULL,
	[NumberAdults] [INT] NOT NULL,
	[NumberChildren] [INT] NULL,
)

GO

CREATE TABLE Client(
	[ClientId] [INT] IDENTITY(1, 1) NOT NULL,
	[Surname] [VARCHAR](100) NOT NULL,
	[Name] [VARCHAR](100) NOT NULL,
	[PhoneNumber] [INT] NOT NULL,
	[Email] [VARCHAR](100) NOT NULL,
	[TourId] [INT] NOT NULL,
)