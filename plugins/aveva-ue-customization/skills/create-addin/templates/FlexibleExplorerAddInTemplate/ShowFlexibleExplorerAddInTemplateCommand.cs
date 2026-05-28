//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using Aveva.ApplicationFramework.Presentation;

namespace Aveva.Core.Samples
{
    /// <summary>
    /// Class to manage the visibility state of the FlexibleExplorer docked window
    /// This command should be associated with a StateButtonTool.
    /// </summary>
    public class ShowFlexibleExplorerAddInTemplateCommand : Command
    {
        private DockedWindow _window;
        /// <summary>
        /// Constructor for ShowFlexibleExplorerAddInTemplateCommand
        /// </summary>
        /// <param name="window">The docked window whose visibility state will be managed.</param>
        public ShowFlexibleExplorerAddInTemplateCommand(DockedWindow window)
        {
            // Set the command key
            this.Key = "Aveva.ShowFlexibleExplorerAddInTemplateCommand";
            // Save the docked window
            _window = window;
            // Create an event handler for the window closed event
            _window.Closed += new EventHandler(_window_Closed);
            // Create an event handler for the WindowLayoutLoaded event
            Aveva.ApplicationFramework.DependencyResolver.GetImplementationOf<IWindowManager>().WindowLayoutLoaded += new EventHandler(Instance_WindowLayoutLoaded);
        }

        void Instance_WindowLayoutLoaded(object sender, EventArgs e)
        {
            // Update the command state to match initial window visibility
            this.Checked = _window.Visible;
        }

        void _window_Closed(object sender, EventArgs e)
        {
            // Update the command state when the window is closed
            this.Checked = false;
        }

        /// <summary>
        /// Override the base class Execute method to show and hide the window
        /// </summary>
        public override void Execute()
        {
            if (this.Checked)
            {
                _window.Show();
            }
            else
            {
                _window.Hide();
            }
        }
    }
}
