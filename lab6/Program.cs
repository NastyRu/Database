using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Linq;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Xml.Linq;

namespace Countries
{
    [Table(Name = "Location.Countries")]
    public class Country
    {
        [Column(Name = "CountryId")]
        public int Id { get; set; }
        [Column(Name = "NameCountry")]
        public string Name { get; set; }
    }
}

namespace Cities
{
    [Table(Name = "Location.Cities")]
    public class City
    {
        [Column(Name = "CityId")]
        public int Id { get; set; }
        [Column(Name = "NameCity")]
        public string Name { get; set; }
        [Column(Name = "CountryId")]
        public int CountryId { get; set; }
    }
}

namespace Hotels
{
    [Table(Name = "Agency.Hotels")]
    public class Hotel
    {
        [Column(Name = "HotelId")]
        public int Id { get; set; }
        [Column(Name = "NameHotel")]
        public string Name { get; set; }
        [Column(Name = "Stars")]
        public int Stars { get; set; }
        [Column(Name = "Food")]
        public string Food { get; set; }
        [Column(Name = "CityId")]
        public int CityId { get; set; }
    }
}

namespace Tours
{
    [Table(Name = "Agency.Tours")]
    public class Tour
    {
        [Column(Name = "TourId")]
        public int Id { get; set; }
        [Column(Name = "Price")]
        public int Price { get; set; }
        [Column(Name = "HotelId")]
        public int HotelId { get; set; }
        [Column(Name = "Days")]
        public int Days { get; set; }
        [Column(Name = "BeginingDate")]
        public DateTime BeginDate { get; set; }
    }
}

namespace Clients
{
    [Table(Name = "Agency.Clients")]
    public class Client
    {
        [Column(Name = "ClientId")]
        public int Id { get; set; }
        [Column(Name = "Surname")]
        public string Surname { get; set; }
        [Column(Name = "Name")]
        public string Name { get; set; }
        [Column(Name = "PhoneNumber")]
        public string Phone { get; set; }
        [Column(Name = "Email")]
        public string Email { get; set; }
    }
}

namespace ClientsTours
{
    [Table(Name = "Agency.ClientsTours")]
    public class ClientTour
    {
        [Column(Name = "ClientId")]
        public int ClientId { get; set; }
        [Column(Name = "TourId")]
        public int TourId { get; set; }
        [Column(Name = "NumberAdults")]
        public int Adults { get; set; }
        [Column(Name = "NumberChildren")]
        public int Children { get; set; }
    }
}

public class XML
{
    public static void CreateXmlCountry(Table<Countries.Country> countries)
    {
        XDocument doc = new XDocument();
        XElement library = new XElement("library");
        doc.Add(library);
        foreach (var country in countries)
        {
            XElement newCountry = new XElement("country");
            newCountry.Add(new XAttribute("Id", country.Id));
            newCountry.Add(new XAttribute("Name", country.Name));
            doc.Root.Add(newCountry);
        }
        doc.Save("file.xml");
    }

    public static void ReadXmlCountry()
    {
        string fileName = "file.xml";
        XDocument doc = XDocument.Load(fileName);
        foreach (XElement el in doc.Root.Elements())
        {
            Console.WriteLine("{0} {1}", el.Attribute("Id").Value, el.Attribute("Name").Value);
        }
    }

    public static void ChangeXmlCountry()
    {
        string fileName = "file.xml";
        XDocument doc = XDocument.Load(fileName);
        foreach (XElement el in doc.Root.Elements())
        {
            int id = Int32.Parse(el.Attribute("Id").Value);
            el.SetAttributeValue("Id", ++id);
        }
        doc.Save("newfile.xml");
    }

    public static void AddXmlCountry()
    {
        string fileName = "newfile.xml";
        XDocument doc = XDocument.Load(fileName);

        int maxId = doc.Root.Elements("country").Max(t => Int32.Parse(t.Attribute("Id").Value));

        XElement newCountry = new XElement("country");
        newCountry.Add(new XAttribute("Id", ++maxId));
        newCountry.Add(new XAttribute("Name", "NewCountry"));

        doc.Root.Add(newCountry);
        doc.Save(fileName);
    }
}

public class Sql
{
    public static void NStarsHotels(Table<Hotels.Hotel> hotels, int n)
    {
        var result = hotels.Where(r => r.Stars == n);

        foreach (var r in result)
           Console.WriteLine("{0} {1}", r.Id, r.Name);
    }

    public static void CitiesFromCountry(Table<Countries.Country> countries, Table<Cities.City> cities, string str)
    {
        var joined = countries.Join(cities,
            co => co.Id,
            ci => ci.CountryId,
            (co, ci) => new { Id = ci.Id, Name = ci.Name, CountryName = co.Name });

        var result = joined.Where(r => r.CountryName == str);

        foreach (var r in result)
           Console.WriteLine("{0} {1}", r.Id, r.Name);
    }

    public static void AddClient(string Surname, string Name, string Phone, string Email)
    {

      [Column(Name = "ClientId")]
      public int Id { get; set; }
      [Column(Name = "Surname")]
      public string Surname { get; set; }
      [Column(Name = "Name")]
      public string Name { get; set; }
      [Column(Name = "PhoneNumber")]
      public string Phone { get; set; }
      [Column(Name = "Email")]
      public string Email { get; set; }

        User user1 = new User { FirstName = "Ronald", Age = 34 };
        // добавляем его в таблицу Users
        db.GetTable<User>().InsertOnSubmit(user1);
        db.SubmitChanges();

        Console.WriteLine();
        Console.WriteLine("После добавления");
        foreach (var user in db.GetTable<User>().OrderByDescending(u => u.Id).Take(5))
        {
            Console.WriteLine("{0} \t{1} \t{2}", user.Id, user.FirstName, user.Age);
        }
    }
}

class Program
{
    static void Main(string[] args)
    {
        SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();
        builder.DataSource = "localhost";
        builder.UserID = "sa";
        builder.Password = "Marvel1405potteR";
        builder.InitialCatalog = "TourAgency";
        Console.WriteLine("Hello World!");

        try
        {
            DataContext db = new DataContext(builder.ConnectionString);
            Table<Countries.Country> countries = db.GetTable<Countries.Country>();
            Table<Cities.City> cities = db.GetTable<Cities.City>();
            Table<Hotels.Hotel> hotels = db.GetTable<Hotels.Hotel>();
            Table<Tours.Tour> tours = db.GetTable<Tours.Tour>();
            Table<Clients.Client> clients = db.GetTable<Clients.Client>();
            Table<ClientsTours.ClientTour> clienttour = db.GetTable<ClientsTours.ClientTour>();

            XML.CreateXmlCountry(countries);
            XML.ReadXmlCountry();
            XML.ChangeXmlCountry();
            XML.AddXmlCountry();

            // пятизвездочные отели
            Sql.NStarsHotels(hotels, 5);
            // города России
            Sql.CitiesFromCountry(countries, cities, "Russia");


        }
        catch (SqlException e)
        {
            Console.WriteLine(e.ToString());
        }
    }
}
