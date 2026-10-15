//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

using Aveva.Core.Presentation;
using Aveva.Core.Database;
using Aveva.Core.Utilities.Messaging;
using Aveva.Core.Database.Filters;
using Aveva.Core.Geometry;

namespace Aveva.Core.Samples
{
    public class ExampleCE
    {
        //follow current element changes
        public static void Run()
        {
            //add event handler for CE changes
            CurrentElement.CurrentElementChanged += new CurrentElementChangedEventHandler(CurrentElement_CurrentElementChanged);

            //change CE
            CurrentElement.Element = Example.Instance.mWorld;
            CurrentElement.Element = Example.Instance.mEqui;
        }

        static void CurrentElement_CurrentElementChanged(object sender, CurrentElementChangedEventArgs e)
        {
            Console.WriteLine("CE changed to: " + e.Element);
        }
    }
}
