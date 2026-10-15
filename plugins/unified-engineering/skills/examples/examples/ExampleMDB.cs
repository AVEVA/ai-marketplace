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
    public class ExampleMDB
    {
        public static void Run()
        {
            //First world
            DbElement el = MDB.CurrentMDB.GetFirstWorld(DbType.Design);
            string firstWorldName = el.GetString(DbAttributeInstance.NAME);
            Console.WriteLine("Design world name: " + firstWorldName);

            //Get name
            string name = MDB.CurrentMDB.Name;
            Console.WriteLine("Current MDB name: " + name);

            //Save work
            Example.Instance.mEqui.InsertAfterLast(Example.Instance.mZone);
            MDB.CurrentMDB.SaveWork("Moved /ExampleEqui to be the last element in parent zone.");
            MDB.CurrentMDB.CloseMDB();

            //Quit work
            Example.Instance.mEqui.InsertAfterLast(Example.Instance.mZone);
            MDB.CurrentMDB.QuitWork();		
        }
    }
}
