USE TourAgency
GO

ALTER TABLE Location.Countries ADD
    CONSTRAINT [PK_Country] PRIMARY KEY (CountryId),
    CONSTRAINT [UK_Country] UNIQUE (NameCountry)
GO

ALTER TABLE Location.Cities ADD
    CONSTRAINT [PK_City] PRIMARY KEY (CityId),
    CONSTRAINT [FK_City_Country] FOREIGN KEY (CountryId) REFERENCES Location.Countries (CountryId)
GO

ALTER TABLE Agency.Hotels ADD
    CONSTRAINT [PK_Hotel] PRIMARY KEY (HotelId),
    CONSTRAINT [FK_Hotel_City] FOREIGN KEY (CityId) REFERENCES Location.Cities (CityId)
GO

ALTER TABLE Agency.Clients ADD
    CONSTRAINT [PK_Client] PRIMARY KEY CLUSTERED (ClientId ASC)
GO

ALTER TABLE Agency.Tours ADD
    CONSTRAINT [PK_Tour] PRIMARY KEY (TourId),
    CONSTRAINT [FK_Tour_Hotel] FOREIGN KEY (HotelId) REFERENCES Agency.Hotels (HotelId)
GO

ALTER TABLE Agency.ClientsTours ADD
    CONSTRAINT [PK_ClientTour] PRIMARY KEY (ClientId, TourId),
    CONSTRAINT [FK_ClientTour_Client] FOREIGN KEY (ClientId) REFERENCES Agency.Clients (ClientId),
    CONSTRAINT [FK_ClientTour_Tour] FOREIGN KEY (TourId) REFERENCES Agency.Tours (TourId)
GO

ALTER TABLE Agency.Hotels ADD
    CONSTRAINT [CH_Stars] CHECK (Stars BETWEEN 1 AND 5)
GO

ALTER TABLE Agency.Hotels ADD
    CONSTRAINT [CH_Food] CHECK ((Food='RO' OR Food='BB' OR Food='HB' OR Food='FB' OR Food='AI' OR Food='UAI'))
GO