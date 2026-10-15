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
    public class ExampleAttributes
    {
        //Set/Get attributes
        public static void Run()
        {
            DbAttribute att;

            //string
            att = DbAttributeInstance.DESC;
            Example.Instance.mPipe.SetAttribute(att, "Example description");
            string desc = Example.Instance.mPipe.GetString(att);

            //bool
            att = DbAttributeInstance.BUIL;
            Example.Instance.mPipe.SetAttribute(att, true);
            bool built = Example.Instance.mPipe.GetBool(att);

            //integer
            att = DbAttributeInstance.REV;
            Example.Instance.mPipe.SetAttribute(att, 3);
            int rev = Example.Instance.mPipe.GetInteger(att);

            //double
            att = DbAttributeInstance.PRES;
            Example.Instance.mPipe.SetAttribute(att, 60.0);
            double press = Example.Instance.mPipe.GetDouble(att);

            //element
            att = DbAttributeInstance.HREF;
            DbElement href = Example.Instance.mBran.GetElement(att);
            Console.WriteLine("Example Branch Head Ref = " + href.ToString());

            //word
            att = DbAttributeInstance.LNTP;
            Example.Instance.mPipe.SetAttribute(att, "XXX");
            string lntp = Example.Instance.mPipe.GetString(att);

            //direction
            att = DbAttributeInstance.HDIR;
            Direction dir = Example.Instance.mBran.GetDirection(att);
            Example.Instance.mBran.SetAttribute(att, dir);
            Console.WriteLine("Example Branch Head Direct = " + dir.ToString());

            //position
            att = DbAttributeInstance.POS;
            Position pos = Example.Instance.mEqui.GetPosition(att);
            Example.Instance.mEqui.SetAttribute(att, pos);
            Console.WriteLine("Example Equipment Position = " + pos.ToString());

            //orientation
            att = DbAttributeInstance.ORI;
            Aveva.Core.Geometry.Orientation ori = Example.Instance.mEqui.GetOrientation(att);
            Example.Instance.mEqui.SetAttribute(att, ori);
            Console.WriteLine("Example Equipment Orientation = " + ori.ToString());
        }
    }
}
