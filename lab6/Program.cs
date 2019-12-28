using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Linq;
using System.Data.Linq;
using System.Data.Linq.Mapping;
using System.Xml.Linq;
using System.Reflection;

namespace Countries
{
    [Table(Name = "Location.Countries")]
    public class Country
    {
        [Column(Name = "CountryId", IsDbGenerated = true)]
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
        [Column(Name = "CityId", IsDbGenerated = true)]
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
        [Column(Name = "HotelId", IsDbGenerated = true)]
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
        [Column(Name = "TourId", IsDbGenerated = true)]
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
        [Column(Name = "ClientId", IsDbGenerated = true, IsPrimaryKey = true)]
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

    public static void AddClient(ref DataContext db, string surname, string name, string phone, string email)
    {
        Console.WriteLine();
        Console.WriteLine("До добавления");
        Table<Clients.Client> clients = db.GetTable<Clients.Client>();

        foreach (var cl in db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).Take(5))
        {
            Console.WriteLine("{0} \t{1} \t{2} \t{3} \t{4}", cl.Id, cl.Surname, cl.Name, cl.Phone, cl.Email);
        }

        Clients.Client client = new Clients.Client { Surname = surname, Name = name, Phone = phone, Email = email };
        db.GetTable<Clients.Client>().InsertOnSubmit(client);
        db.SubmitChanges();

        Console.WriteLine();
        Console.WriteLine("После добавления");
        foreach (var cl in db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).Take(5))
        {
            Console.WriteLine("{0} \t{1} \t{2} \t{3} \t{4}", cl.Id, cl.Surname, cl.Name, cl.Phone, cl.Email);
        }
    }

    public static void ChangeClientEmail(ref DataContext db, string email)
    {
        Console.WriteLine();
        Console.WriteLine("До изменения");
        Table<Clients.Client> clients = db.GetTable<Clients.Client>();

        foreach (var cl in db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).Take(5))
        {
            Console.WriteLine("{0} \t{1} \t{2} \t{3} \t{4}", cl.Id, cl.Surname, cl.Name, cl.Phone, cl.Email);
        }

        Clients.Client client = db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).FirstOrDefault();
        client.Email = email;
        db.SubmitChanges();

        Console.WriteLine();
        Console.WriteLine("После изменения");
        foreach (var cl in db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).Take(5))
        {
            Console.WriteLine("{0} \t{1} \t{2} \t{3} \t{4}", cl.Id, cl.Surname, cl.Name, cl.Phone, cl.Email);
        }
    }

    public static void DeleteClient(ref DataContext db)
    {
        Console.WriteLine();
        Console.WriteLine("До удаления");
        Table<Clients.Client> clients = db.GetTable<Clients.Client>();

        foreach (var cl in db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).Take(5))
        {
            Console.WriteLine("{0} \t{1} \t{2} \t{3} \t{4}", cl.Id, cl.Surname, cl.Name, cl.Phone, cl.Email);
        }

        Clients.Client client = db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).FirstOrDefault();
        clients.DeleteOnSubmit(client);
        db.SubmitChanges();

        Console.WriteLine();
        Console.WriteLine("После удаления");
        foreach (var cl in db.GetTable<Clients.Client>().OrderByDescending(u => u.Id).Take(5))
        {
            Console.WriteLine("{0} \t{1} \t{2} \t{3} \t{4}", cl.Id, cl.Surname, cl.Name, cl.Phone, cl.Email);
        }
    }
}

public class UserDataContext : DataContext
{
    public UserDataContext(string connectionString) :base(connectionString) { }
    [Function(Name = "dbo.find_clients")]
    public int FindClients([Parameter(Name = "Num", DbType = "Int")] int Num,
                           [Parameter(Name = "CountClients", DbType = "Int")] ref int count)
    {
        IExecuteResult result = this.ExecuteMethodCall(this, ((MethodInfo)(MethodInfo.GetCurrentMethod())), Num, count);
        count = ((int)(result.GetParameterValue(1)));
        return ((int)(result.ReturnValue));
    }
}

public class SqlLinq
{
    public static void sql1(Table<Countries.Country> countries)
    {
        var res = countries.Where(u => u.Name.Contains("al"));

        foreach (var r in res)
        {
            Console.WriteLine("{0} \t{1}", r.Id, r.Name);
        }
    }

    public static void sql2(string str, Table<Countries.Country> countries, Table<Cities.City> cities)
    {
        var joined = countries.Join(cities,
            co => co.Id,
            ci => ci.CountryId,
            (co, ci) => new { Id = ci.Id, Name = ci.Name, CountryName = co.Name });

        var result = joined.Where(r => r.CountryName == str);

        foreach (var r in result)
           Console.WriteLine("{0} {1}", r.Id, r.Name);
    }

    public static void sql3(Table<Countries.Country> countries, Table<Cities.City> cities)
    {
        var joined = countries.Join(cities,
            co => co.Id,
            ci => ci.CountryId,
            (co, ci) => new { Id = ci.Id, Name = ci.Name, CountryName = co.Name });

        var query = joined.GroupBy(u => u.CountryName);
        foreach (var group in query)
        {
            Console.WriteLine("Страна: {0}", group.Key);
            foreach (var user in group)
                Console.WriteLine(user.Name);
            Console.WriteLine();
        }
    }

    public static void sql4(Table<Hotels.Hotel> hotels)
    {
        var res = hotels.Where(u => u.Stars > 4).OrderBy(u => u.Name);

        foreach (var r in res)
        {
            Console.WriteLine("{0} \t{1}", r.Id, r.Name);
        }
    }

    public static void sql5(Table<Tours.Tour> tours, Table<ClientsTours.ClientTour> clienttours)
    {
        var joined = tours.Join(clienttours,
            t => t.Id,
            tc => tc.TourId,
            (t, tc) => new { Id = t.Id, Adults = tc.Adults, Children = tc.Children, Price = t.Price });

        var res = joined.Max(u => (u.Adults + u.Children) * u.Price);

        Console.WriteLine(res);
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

        try
        {
            DataContext db = new DataContext(builder.ConnectionString);
            db.ObjectTrackingEnabled = true;
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

            Sql.AddClient(ref db, "AAA", "aaa", "88888888888", "aaaa@mail.ru");
            Sql.ChangeClientEmail(ref db, "aa@yandex.ru");
            Sql.DeleteClient(ref db);

            UserDataContext udb = new UserDataContext(builder.ConnectionString);
            int count = 0;
            udb.FindClients(2, ref count);
            Console.WriteLine("Клиенты сделавшие {0} заказа: {1}", 2, count);

            SqlLinq.sql1(countries);
            SqlLinq.sql2("Argentina", countries, cities);
            SqlLinq.sql3(countries, cities);
            SqlLinq.sql4(hotels);
            SqlLinq.sql5(tours, clienttour);
        }
        catch (SqlException e)
        {
            Console.WriteLine(e.ToString());
        }
    }
}
