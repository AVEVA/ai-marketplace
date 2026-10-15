//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;

namespace Aveva.Core.Samples
{
    /// <summary>
    /// Command class for showing/hiding the NetGridAddInTemplate window
    /// </summary>
    public class ShowNetGridAddInTemplateCommand : Command
    {
        private DockedWindow mDockedWindow;

        public ShowNetGridAddInTemplateCommand(DockedWindow dockedWindow)
        {
            mDockedWindow = dockedWindow;
            base.Key = "Aveva.ShowNetGridAddInTemplateCommand";
        }

        public override void Execute()
        {
            if (mDockedWindow.Visible)
            {
                mDockedWindow.Hide();
            }
            else
            {
                mDockedWindow.Show();
            }
        }
    }
}