using System;
using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;

namespace DockedFormAddInTemplate
{
    /// <summary>
    /// Manages visibility of the DockedFormAddInTemplate docked window. Designed for a StateButtonTool binding.
    /// </summary>
    public class ShowDockedFormAddInTemplateCommand : Command
    {
        private readonly DockedWindow _window;

        public ShowDockedFormAddInTemplateCommand(DockedWindow window)
        {
            Key = "DockedFormAddInTemplate.ShowWindow";
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

