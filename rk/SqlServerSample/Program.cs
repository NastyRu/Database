using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Linq;
using System.Data.Linq;
using System.Data.Linq.Mapping;

namespace Workers
{
    [Table(Name = "Workers")]
    public class Worker
    {
        [Column(IsPrimaryKey = true, IsDbGenerated = true)]
        public int id { get; set; }
        [Column(Name = "Fio")]
        public string fio { get; set; }
        [Column(Name = "BirthDate")]
        public DateTime age { get; set; }
        [Column]
        public string department { get; set; }
    }
}

namespace Times
{
    [Table(Name = "Time")]
    public class Time
    {
        [Column(Name = "Id")]
        public int id { get; set; }
        [Column(Name = "Data")]
        public DateTime data { get; set; }
        [Column(Name = "WeekDay")]
        public string weekDay { get; set; }

        [Column(Name = "Type")]
        public int type { get; set; }

        private TimeSpan? _time;
        [Column(DbType = "TIME(7) NOT NULL")]
        public TimeSpan? time
        {
          get { return this._time; }
          set { this._time = value; }
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
        builder.Password = "password";
        builder.InitialCatalog = "RK2";

// отделы, в которых хоть один ни разу не опоздал за всю историю учета
        string sqlExpression3 =
"SELECT Department " +
"FROM Workers "+
"WHERE Department NOT IN ( "+
         "SELECT Department "+
         "FROM ( "+
                  "SELECT Time.Id, "+
                         "Department, "+
                         "( "+
                            " SELECT MIN(Time) "+
                             "FROM Time AS T "+
                            " WHERE Type = 1 "+
                               "AND T.Id = Time.Id "+
                               "AND T.Data = Time.Data "+
                         ") AS BeginDay "+
                  "FROM Time "+
                          " JOIN Workers ON Time.Id = Workers.Id "+
                  "GROUP BY Time.Id, Data, Department "+
              ") AS T "+
         "WHERE BeginDay > '09:00:00' "+
         "GROUP BY Department "+
     ") "+
"GROUP BY Department ";

// отделы, в которых хоть один сотрудник опаздывал каждый день в течение 10 дней
      string sqlExpression1 =
"SELECT Department "+
"FROM ( "+
         "SELECT Count(Id) AS Number, Id, Department "+
         "FROM ( "+
                  "SELECT Time.Id, "+
                         "Department, "+
                         "Data, "+
                         "( "+
                             "SELECT MIN(Time) "+
                             "FROM Time AS T "+
                             "WHERE Type = 1 "+
                               "AND T.Id = Time.Id "+
                               "AND T.Data = Time.Data "+
                         ") AS BeginDay "+
                  "FROM Time "+
                           "JOIN Workers ON Time.Id = Workers.Id "+
                  "GROUP BY Time.Id, WeekDay, Data, Department "+
              ") AS T "+
         "WHERE BeginDay > '09:00:00' AND DATEDIFF(year, Data, GETDATE()) < 10 "+
         "GROUP BY Id, Department "+
     ") AS Late "+
"WHERE Number = 10 "+
"GROUP BY Department ";

// Чотрудники, чаще всего выходящие с рабочего места в течение рабочего дня
        string sqlExpression2 =
"SELECT Fio, Data, MAX(C) "+
"FROM ( "+
         "SELECT W.Fio, Data, Count(*) AS C "+
         "FROM Workers AS W "+
                "  JOIN Time AS T ON T.Id = W.Id "+
         "GROUP BY T.Id, Data, T.Time, W.Fio "+
         "HAVING T.Time > "+
                "( "+
                    "SELECT MIN(Time) "+
                    "FROM Time "+
                    "WHERE Type = 1 "+
                      "AND T.Id = Time.Id "+
                      "AND T.Data = Time.Data "+
                ") "+
            "AND T.Time < "+
              "  ( "+
                  "  SELECT MAX(Time) "+
                  "  FROM Time "+
                  "  WHERE Type = 1 "+
                  "    AND T.Id = Time.Id "+
                  "    AND T.Data = Time.Data "+
                ") "+
     ") AS Out "+
"GROUP BY Data, Fio ";

        using (SqlConnection connection = new SqlConnection(builder.ConnectionString))
        {
            connection.Open();
            SqlCommand command1 = new SqlCommand(sqlExpression1, connection);
            SqlDataReader reader1 = command1.ExecuteReader();
            if (reader1.HasRows)
            {
                Console.WriteLine("{0}", reader1.GetName(0));

                while (reader1.Read())
                {
                    object department = reader1.GetValue(0);

                    Console.WriteLine("{0}", department);
                }
            }
            reader1.Close();

            SqlCommand command2 = new SqlCommand(sqlExpression2, connection);
            SqlDataReader reader2 = command2.ExecuteReader();
            if (reader2.HasRows)
            {
                Console.WriteLine("{0} \t{1} \t{2}", reader2.GetName(0), reader2.GetName(1), reader2.GetName(2));

                while (reader2.Read())
                {
                    object fio = reader2.GetValue(0);
                    object dat = reader2.GetValue(1);
                    object num = reader2.GetValue(2);

                    Console.WriteLine("{0} \t{1} \t{2}", fio, dat, num);
                }
            }
            reader2.Close();

            SqlCommand command3 = new SqlCommand(sqlExpression3, connection);
            SqlDataReader reader3 = command3.ExecuteReader();
            if (reader3.HasRows)
            {
                Console.WriteLine("{0}", reader3.GetName(0));

                while (reader3.Read())
                {
                    object department = reader3.GetValue(0);

                    Console.WriteLine("{0}", department);
                }
            }
            reader3.Close();
        }

        try
        {
            DataContext db = new DataContext(builder.ConnectionString);
            Table<Workers.Worker> workers = db.GetTable<Workers.Worker>();
            Table<Times.Time> times = db.GetTable<Times.Time>();

            var result = workers.Join(times,
                 w => w.id,
                 t => t.id,
                 (w, t) => new { id = w.id, fio = w.fio, age = w.age, department = w.department,  data = t.data, weekDay = t.weekDay, time = t.time, type = t.type});

             var min = times.Where(r => r.type == 1).GroupBy(r => new {r.id, r.data}).Select(g => new {g.Key, m = g.Min(r => r.time)});
             var max = times.Where(r => r.type == 2).GroupBy(r => new {r.id, r.data}).Select(g => new {g.Key, m = g.Max(r => r.time)});

             // нахождение отделов где никто не опоздал
             List<string> departments = new List<string>();
             foreach (var res in result)
             {
               if (-1 == departments.IndexOf(res.department))
                  departments.Add(res.department);
             }

             var resmin = workers.Join(min,
                  w => w.id,
                  t => t.Key.id,
                  (w, t) => new { id = w.id, fio = w.fio, age = w.age, department = w.department, data = t.Key.data, time = t.m });

             foreach (var r in resmin)
             {
               if (r.time > TimeSpan.Parse("09:00:00"))
                  departments.Remove(r.department);
             }

             foreach (var d in departments)
                Console.WriteLine(d);

            // отдел где хоть один сотрудник опаздывал каждый день в течение 10 дней
            List<int> works = new List<int>();
            works.AddRange(new int[] { 0, 0, 0, 0 });

            foreach (var s in resmin)
            {
              if (s.time > TimeSpan.Parse("09:00:00"))
                 works[s.id]++;
            }
            foreach (var w in works)
            {
              if (w == 10)
              // отдел
                Console.WriteLine(w);
            }

        }
        catch (SqlException e)
        {
            Console.WriteLine(e.ToString());
        }
    }
}
