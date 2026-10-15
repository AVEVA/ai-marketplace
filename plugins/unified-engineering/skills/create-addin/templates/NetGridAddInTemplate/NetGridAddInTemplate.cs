//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;

namespace Aveva.Core.Samples
{
    /// <summary>
    /// NetGridAddInTemplate - A grid-based add-in template for AVEVA Unified Engineering
    /// </summary>
    public class NetGridAddInTemplate : IAddinInjected
    {
        private DockedWindow mAddinWindow;
        private StateButtonTool mAddinButton;
        private NetGridAddInTemplateControl mAddinControl;
        private ICommandBarManager mCommandBarManager;
        private IWindowManager mWindowManager;
        private string addinKey = "Aveva.NetGridAddInTemplate.NetGridAddInTemplate";

        public NetGridAddInTemplate()
        {
        }

        public void Start(IDependencyResolver resolver)
        {
            mWindowManager = DependencyResolver.GetImplementationOf<IWindowManager>();
            mCommandBarManager = DependencyResolver.GetImplementationOf<IWindowManager>().CommandBarManager;
            mCommandBarManager.RootTools.ToolAdded += new ToolEventHandler(RootTools_ToolAdded);

            //Set up the context menus
            ApplicationSettingsGetter menuCreator = new ApplicationSettingsGetter(mCommandBarManager);
            MenuTool selectedMenu;
            MenuTool headerMenu;
            menuCreator.GetApplicationSettings(out selectedMenu, out headerMenu);

            //Create an instance of Addin control
            mAddinControl = new NetGridAddInTemplateControl();

            //Create the Addin window
            mAddinWindow = (DockedWindow)mWindowManager.CreateDockedWindow(addinKey, addinKey, mAddinControl, DockedPosition.Left);
            mAddinWindow.Width = 225;
            mAddinWindow.SaveLayout = true;
            mAddinWindow.Closing += new System.ComponentModel.CancelEventHandler(mAddinWindow_Closing);

            //Hide the window
            mAddinWindow.Hide();

            // Create and register the show command
            ICommandManager commandManager = DependencyResolver.GetImplementationOf<ICommandManager>();
            ShowNetGridAddInTemplateCommand showCommand = new ShowNetGridAddInTemplateCommand(mAddinWindow);
            commandManager.Commands.Add(showCommand);

            //Load custom menus
            mCommandBarManager.UILoaded += new EventHandler(mCommandBarManager_UILoaded);
        }

        public void Start(ServiceManager serviceManager)
        {

        }

        public void Stop()
        {

        }

        public String Name
        {
            get
            {
                return "NetGridAddInTemplate";
            }
        }

        public String Description
        {
            get
            {
                return "Provides a grid control add-in template";
            }
        }

        private void ShowAddin_ToolClick(object sender, EventArgs e)
        {
            StateButtonTool tool = (StateButtonTool)sender;
            if (tool?.Key == null)
                return;

            string[] toolNameSplit = tool.Key.Split('.');
            string toolName = toolNameSplit[toolNameSplit.Length - 1];
            if (toolName.Equals(addinKey))
            {
                if (tool.Checked)
                {
                    mAddinWindow.Show();
                }
                else
                {
                    mAddinWindow.Hide();
                }
            }
        }

        private void mAddinWindow_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (mAddinButton != null)
            {
                mAddinButton.Checked = false;
            }
        }

        private void RootTools_ToolAdded(object sender, ToolEventArgs args)
        {
            ITool tool = mCommandBarManager.RootTools[args.Key];
            if (tool?.Key == null)
                return;

            string[] toolNameSplit = tool.Key.Split('.');
            string toolName = toolNameSplit[toolNameSplit.Length - 1];

            if (toolName.Equals(addinKey))
            {
                //Addin button
                mAddinButton = (StateButtonTool)tool;
                mAddinButton.Checked = mAddinWindow.Visible;
                mAddinButton.ToolClick += new EventHandler(ShowAddin_ToolClick);
            }
        }

        private void mCommandBarManager_UILoaded(object sender, EventArgs e)
        {
            //Load menus for selection and header
            String contextMenuKey = "AVEVA.NetGridAddInTemplate.SelectedMenu";
            if (mCommandBarManager.RootTools.Contains(contextMenuKey))
            {
                MenuTool menu = (MenuTool)mCommandBarManager.RootTools[contextMenuKey];
                mAddinControl.SelectionMenu = menu;
            }

            contextMenuKey = "AVEVA.NetGridAddInTemplate.HeaderMenu";
            if (mCommandBarManager.RootTools.Contains(contextMenuKey))
            {
                MenuTool menu = (MenuTool)mCommandBarManager.RootTools[contextMenuKey];
                mAddinControl.HeaderMenu = menu;
            }

            mAddinWindow.Show();
        }
    }

    /// <summary>
    /// ApplicationSettingsGetter
    /// </summary>
    public class ApplicationSettingsGetter
    {
        private ICommandBarManager mCommandBarManager;
        private MenuTool mSelectedMenu;
        private MenuTool mHeaderMenu;

        /// <summary>
        /// Application Settings Getter
        /// </summary>
        /// <param name="commandBarManager"></param>
        public ApplicationSettingsGetter(ICommandBarManager commandBarManager)
        {
            mCommandBarManager = commandBarManager;

            //Selected items menu
            mSelectedMenu = mCommandBarManager.RootTools.AddMenuTool("AVEVA.NetGridAddInTemplate.SelectedMenu", "", null, "");
            mSelectedMenu.IsContextMenu = true;

            //Main Header menu
            mHeaderMenu = mCommandBarManager.RootTools.AddMenuTool("AVEVA.NetGridAddInTemplate.HeaderMenu", "", null, "");
            mHeaderMenu.IsContextMenu = true;
        }

        private void AddMenusToSelection()
        {
            //Print Preview
            mCommandBarManager.RootTools.AddButtonTool("AVEVA.NetGridAddInTemplate.PrintPreview", "Print Preview", null, "AVEVA.Grid.PrintPreview");
            ITool menuButton = mSelectedMenu.Tools.AddTool("AVEVA.NetGridAddInTemplate.PrintPreview");
        }

        private void AddMenusToHeader()
        {
            //Export to Excel
            mCommandBarManager.RootTools.AddButtonTool("AVEVA.NetGridAddInTemplate.ExportToExcel", "Export to Excel", null, "AVEVA.Grid.ExportToExcel");
            ITool menuButton = mHeaderMenu.Tools.AddTool("AVEVA.NetGridAddInTemplate.ExportToExcel");

            //Outlook Style
            mCommandBarManager.RootTools.AddButtonTool("AVEVA.NetGridAddInTemplate.OutlookStyle", "Outlook Style", null, "AVEVA.Grid.OutlookStyle");
            menuButton = mHeaderMenu.Tools.AddTool("AVEVA.NetGridAddInTemplate.OutlookStyle");
        }

        /// <summary>
        /// Get application settings
        /// </summary>
        /// <param name="selectedMenu"></param>
        /// <param name="headerMenu"></param>
        public void GetApplicationSettings(out MenuTool selectedMenu, out MenuTool headerMenu)
        {
            //Selection
            AddMenusToSelection();
            selectedMenu = mSelectedMenu;

            //Header
            AddMenusToHeader();
            headerMenu = mHeaderMenu;
        }
    }
}