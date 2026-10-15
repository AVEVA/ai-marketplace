//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using System.Collections.Generic;
using System.Text;

using Aveva.Core.Database;
using Aveva.Core.Geometry;
using Aveva.Core3D.Clasher;

// only for this example class library there is a conflict between
// namespace Aveva.Core.Samples and namespace Aveva.Core3D.Clasher
// resolved using an alias or fully qualifying Clasher class
using CLASHER = Aveva.Core3D.Clasher.Clasher;

namespace Aveva.Core.Samples
{
    class ExampleClasher
    {
        public static void Run()
        {
            //
            // Spatial Maps
            //
            // Check spatial maps for every DB
            Db[] dbChk = MDB.CurrentMDB.GetDBArray(DbType.Design);
            foreach (Db db in dbChk)
            {
                SpatialMapStatus stat = SpatialMap.Instance.CheckSpatialMap(db);
            }

            // Build spatial maps for MDB
            try
            {
                SpatialMap.Instance.BuildSpatialMap();
            }
            catch (InvalidOperationException ex)
            {
                // Spatial map building failed due to invalid state
                Console.WriteLine("Spatial map build failed: Invalid operation - " + ex.Message);
            }
            catch (OutOfMemoryException ex)
            {
                // Insufficient memory for spatial map
                Console.WriteLine("Spatial map build failed: Insufficient memory - " + ex.Message);
            }
            catch (Exception ex)
            {
                // Last resort - log unexpected errors
                Console.WriteLine("Unexpected error building spatial map: " + ex.GetType().Name);
            }

            //
            // Clasher
            //
            // CheckAll
            ClashOptions opt = ClashOptions.Create();
            opt.IncludeTouches = true;
            opt.Clearance = 10.0;

            ObstructionList obst = ObstructionList.Create();
            ClashSet cs = ClashSet.Create();

            bool bResult = CLASHER.Instance.CheckAll(opt, obst, cs);
            if (bResult)
            {
                // inspect clashes
                Clash[] aClashes = cs.Clashes;
                Console.WriteLine("Number of clashes: " + aClashes.Length);
                for (int i = 0; i < aClashes.Length; i++)
                {
                    DbElement first = aClashes[i].First;
                    DbElement second = aClashes[i].Second;
                    ClashType ctp = aClashes[i].Type;
                    Position pos = aClashes[i].ClashPosition;
                }
            }
        }
    }
}
