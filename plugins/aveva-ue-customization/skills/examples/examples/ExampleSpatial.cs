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
    public class ExampleSpatial
    {
        public static void Run()
        {
            //Find items within a specified volume
            Position p1 = Position.Create(0.0, 0.0, 0.0);
            Position p2 = Position.Create(10000.0, 10000.0, 10000.0);
            LimitsBox limitsBox = LimitsBox.Create(p1, p2);

            DbElement[] eles = Spatial.Instance.ElementsInBox(limitsBox, false);
            int size = eles.Length;

            //Find items fully within a specified volum
            eles = Spatial.Instance.ElementsInBox(limitsBox, true);
            size = eles.Length;
            Console.WriteLine("Number of elements within limits box " + limitsBox.ToString() + " = " + size);

            //Find items within the 3D box of a given item
            eles = Spatial.Instance.ElementsInElementBox(Example.Instance.mEqui, false);
            size = eles.Length;
            Console.WriteLine("Number of elements within limits box of ExampleEqui = " + size);

            //Find items fully within the 3D box of a given item
            eles = Spatial.Instance.ElementsInElementBox(Example.Instance.mEqui, true);
            size = eles.Length;

            //Determine if the item lies within or intersects with the given 3D box
            bool bResult = Spatial.Instance.ElementInBox(Example.Instance.mEqui, limitsBox);

            //Determine if the item lies within or intersects with the given 3D box of a second element
            bResult = Spatial.Instance.ElementInElementBox(Example.Instance.mEqui, Example.Instance.mBran);
        }
    }
}
