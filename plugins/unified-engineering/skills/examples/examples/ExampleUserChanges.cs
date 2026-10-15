//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using System.Collections.Generic;
using System.Text;

using Aveva.Core.Database;
using Aveva.Core.Utilities.Messaging;
using Aveva.Core.Database.Filters;
using Aveva.Core.Geometry;
using Aveva.Core.Presentation;

namespace Aveva.Core.Samples
{
    public class ExampleUserChanges
    {
        public static void Run()
        {
            //add database changes event handler
            DatabaseService.Changes += new DbChangesEventHandler(DatabaseService_Changes);

            //
            // Element Creation, Deletion, Re-order, Include, Copy
            //
            DbElement nozz1 = Example.Instance.mEqui.CreateFirst(DbElementTypeInstance.NOZZLE);
            Core.Utilities.CommandLine.Command.Update();

            DbElement nozz2 = Example.Instance.mEqui.CreateLast(DbElementTypeInstance.NOZZLE);
            Core.Utilities.CommandLine.Command.Update();

            nozz1.Copy(Example.Instance.mNozz1); // Copy element
            nozz1.SetAttribute(DbAttributeInstance.DESC, "nozzle"); // Change only one part
            Core.Utilities.CommandLine.Command.Update(); // Make sure these changes are ignored
            nozz1.Copy(Example.Instance.mNozz1); // Re-Copy element - should indicate only the description part has changed
            Core.Utilities.CommandLine.Command.Update();

            nozz1.InsertAfterLast(Example.Instance.mEqui);
            Core.Utilities.CommandLine.Command.Update();

            nozz1.Delete();
            Core.Utilities.CommandLine.Command.Update();
        }

        static void DatabaseService_Changes(object sender, DbChangesEventArgs e)
        {
            try
            {
                DbElement[] creations = e.ChangeList.GetCreations();
                DbElement[] deletions = e.ChangeList.GetDeletions();
                DbElement[] memberChanges = e.ChangeList.GetMemberChanges();
                DbElement[] modifications = e.ChangeList.GetModified();
            }
            catch (InvalidOperationException ex)
            {
                // Change list access failed due to invalid state
                Console.WriteLine("Error accessing change list: Invalid operation - " + ex.Message);
            }
            catch (Exception ex)
            {
                // Last resort - log unexpected errors
                Console.WriteLine("Unexpected error processing user changes: " + ex.GetType().Name);
            }
        }
    }
}
