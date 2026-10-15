using System;
using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;

namespace WebpageAddInTemplate
{
    /// <summary>
    /// Manages visibility of the WebpageAddInTemplate docked window. Designed for a StateButtonTool binding.
    /// </summary>
    public class ShowWebpageAddInTemplateCommand : Command
    {
        private readonly DockedWindow _window;

        public ShowWebpageAddInTemplateCommand(DockedWindow window)
        {
            Key = "WebpageAddInTemplate.ShowWindow";
            _window = window;
            _window.Closed += OnWindowClosed;
            DependencyResolver.GetImplementationOf<IWindowManager>().WindowLayoutLoaded += OnWindowLayoutLoaded;
        }

        private void OnWindowLayoutLoaded(object sender, EventArgs e)
        {
            Checked = _window.Visible;
        }

        private void OnWindowClosed(object sender, EventArgs e)
        {
            Checked = false;
        }

        public override void Execute()
        {
            if (Checked)
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
