//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using System.Collections.Generic;
using System.Text;

using Aveva.Core.Database;
using Aveva.Core.Utilities.Messaging;
using Aveva.Core.Database.Filters;
using Aveva.Core.Geometry;

namespace Aveva.Core.Samples
{
    public class ExampleNameTable
    {
        public static void Run()
        {
            Db[] dbs = MDB.CurrentMDB.GetDBArray(DbType.Design);
            foreach (Db db in dbs)
            {
                NameTable ntable = NameTable.GetNameTable(db, DbAttributeInstance.NAME, "/Example", "");
                foreach (DbElement e in ntable)
                {
                    string elementName = e.GetString(DbAttributeInstance.NAME);
                }
            }
        }
    }
}
