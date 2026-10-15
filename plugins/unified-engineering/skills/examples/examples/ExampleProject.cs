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
    public class ExampleProject
    {
        public static void Run()
        {
            //Project name
            string projName = Project.CurrentProject.Name;
            Console.WriteLine("Project Name: " + projName);

            //User name
            string userName = Project.CurrentProject.UserName;
            Console.WriteLine("UserName: " + userName);

            //MDB name
            string MDBName = MDB.CurrentMDB.Name;
            Console.WriteLine("MDB: " + MDBName);
        }
    }
}
