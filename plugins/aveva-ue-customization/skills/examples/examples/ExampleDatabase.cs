//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

using Aveva.Core.Database;
using Aveva.Core.Utilities.Messaging;
using Aveva.Core.Database.Filters;
using Aveva.Core.Geometry;

namespace Aveva.Core.Samples
{
    public class ExampleDatabase
    {
        // db example
        public static void Run()
        {
            //Iterate thru all design db's in mdb
            Db[] dbs = MDB.CurrentMDB.GetDBArray(DbType.Design);
            foreach (Db db in dbs)
            {
                Console.WriteLine(db.Name);
            }
        }
    }
}
