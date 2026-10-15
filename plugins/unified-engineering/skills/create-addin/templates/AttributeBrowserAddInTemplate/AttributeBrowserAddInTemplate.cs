//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using System.Collections.Generic;
using System.Text;
// Add additional using statements
using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;
using Aveva.Core.Presentation;
using Aveva.Core.Database;

namespace Aveva.Core.Samples
{
    public class AttributeBrowserAddInTemplate : IAddinInjected
    {
        private DockedWindow attributeListWindow;
        private AttributeListControl attributeListControl;
        private string addinKey = "Aveva.AttributeBrowser.AttributeList";
        private string addinTitle = "Attributes";
        #region IAddin Members

        public string Description
        {
            get
            {
                return "Provides a simple attribute browser";
            }
        }

        public string Name
        {
            get
            {
                return "AttributeBrowserAddInTemplate";
            }
        }

        public void Start(IDependencyResolver resolver)
        {
            // Create Addins Windows
            // Get the WindowManager service
            IWindowManager windowManager = DependencyResolver.GetImplementationOf<IWindowManager>();
            attributeListControl = new AttributeListControl();
            // Create a docked window to host an AttributeListControl
            attributeListWindow = windowManager.CreateDockedWindow(addinKey, addinTitle, attributeListControl, DockedPosition.Right);
            attributeListWindow.Width = 200;
            // Docked windows created at addin start should ensure their layout is saved between sessions.
            attributeListWindow.SaveLayout = true;


            // Create and register addins commands
            // Get the CommandManager
            ICommandManager commandManager = DependencyResolver.GetImplementationOf<ICommandManager>();
            ShowAttributeBrowserAddInTemplateCommand showCommand = new ShowAttributeBrowserAddInTemplateCommand(attributeListWindow);
            commandManager.Commands.Add(showCommand);

            // Add event handler for current element changed event.
            CurrentElement.CurrentElementChanged += new CurrentElementChangedEventHandler(CurrentElement_CurrentElementChanged);
        }

        public void Start(ServiceManager serviceManager)
        {
            
        }

        void CurrentElement_CurrentElementChanged(object sender, CurrentElementChangedEventArgs e)
        {
            // Set the window title to the name of the element.
            string windowTitle = "Attributes of element " + CurrentElement.Element.GetAsString(DbAttributeInstance.FLNM);
            attributeListWindow.Title = windowTitle;
            // Clear attribute list
            attributeListControl.Clear();
            // Populate the attribute list with attributes of the current element
            foreach (DbAttribute attribute in CurrentElement.Element.GetAttributes())
            {
                
                try
                {
                    string elAsString = CurrentElement.Element.GetAsString(attribute);
                    attributeListControl.AddAttribute(attribute.Name, elAsString); 
                }
                catch (InvalidOperationException)
                {
                    // Attribute cannot be read in current state
                    attributeListControl.AddAttribute(attribute.Name, "<Unavailable>");
                }
                catch (NotSupportedException)
                {
                    // Attribute type not supported for string conversion
                    attributeListControl.AddAttribute(attribute.Name, "<Not supported>");
                }
                catch (Exception ex)
                {
                    // Last resort - log and show error
                    System.Diagnostics.Trace.WriteLine($"Error reading attribute {attribute.Name}: {ex.GetType().Name}");
                    attributeListControl.AddAttribute(attribute.Name, "<Error reading attribute>");
                }
            }

        }

        public void Stop()
        {
        }

        #endregion

        
    }
}
