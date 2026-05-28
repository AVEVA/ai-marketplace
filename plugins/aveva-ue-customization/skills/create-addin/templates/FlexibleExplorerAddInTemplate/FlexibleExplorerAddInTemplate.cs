//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;
using Aveva.Core.Database;

namespace Aveva.Core.Samples
{
    public class FlexibleExplorerAddInTemplate : IAddinInjected
    {
        private DockedWindow flexibleExplorerWindow;
        private MyFlexibleExplorerControl myFlexibleExplorerControl;
        private string addinKey = "Aveva.FlexibleExplorer.FlexibleExplorerAddInTemplate";
        private string addinTitle = "FlexibleExplorerAddInTemplate";
        #region IAddin Members

        public string Description
        {
            get
            {
                return "Provides a simple flexible explorer example";
            }
        }

        public string Name
        {
            get
            {
                return "FlexibleExplorerAddInTemplate";
            }
        }

        public void Start(IDependencyResolver resolver)
        {
            // Create Addins Window

            // Get the WindowManager service
            IWindowManager windowManager = DependencyResolver.GetImplementationOf<IWindowManager>();
            myFlexibleExplorerControl = new MyFlexibleExplorerControl(resolver);
            myFlexibleExplorerControl.AddFlexibleExplorer();
            // Create a docked window 
            flexibleExplorerWindow = windowManager.CreateDockedWindow(addinKey, addinTitle, myFlexibleExplorerControl, DockedPosition.Right);
            flexibleExplorerWindow.Width = 200;
            // Docked windows created at addin start should ensure their layout is saved between sessions.
            flexibleExplorerWindow.SaveLayout = true;

            // Create and register addins commands
            // Get the CommandManager
            ICommandManager commandManager = DependencyResolver.GetImplementationOf<ICommandManager>();
            ShowFlexibleExplorerAddInTemplateCommand showCommand = new ShowFlexibleExplorerAddInTemplateCommand(flexibleExplorerWindow);
            commandManager.Commands.Add(showCommand);

            // Add event handler for current element changed event.
            CurrentElement.CurrentElementChanged += new CurrentElementChangedEventHandler(CurrentElement_CurrentElementChanged);
        }

        public void Start(ServiceManager serviceManager)
        {
            
        }

        void CurrentElement_CurrentElementChanged(object sender, CurrentElementChangedEventArgs e)
        {
            //Add code here if required

        }

        public void Stop()
        {
        }

        #endregion
    }
}
