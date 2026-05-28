using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;
using Aveva.Core.Database;

namespace DockedFormAddInTemplate
{
    public class DockedFormAddInTemplate : IAddinInjected
    {
        private DockedWindow _window;
        private DockedFormAddInTemplateControl _control;
        private ShowDockedFormAddInTemplateCommand _showCommand;
        private const string AddinKey = "DockedFormAddInTemplate.DockedWindow";

        public string Description => "DockedFormAddInTemplate scaffold for UE";

        public string Name => "DockedFormAddInTemplate";

        public void Start(IDependencyResolver resolver)
        {
            // Resolve window manager and create an empty docked window
            IWindowManager windowManager = DependencyResolver.GetImplementationOf<IWindowManager>();
            _control = new DockedFormAddInTemplateControl(resolver);
            _window = windowManager.CreateDockedWindow(AddinKey, "DockedFormAddInTemplate", _control, DockedPosition.Right);
            _window.Width = 300;
            _window.SaveLayout = true;

            // Register command to show/hide the docked window
            ICommandManager commandManager = DependencyResolver.GetImplementationOf<ICommandManager>();
            _showCommand = new ShowDockedFormAddInTemplateCommand(_window);
            commandManager.Commands.Add(_showCommand);
        }

        public void Start(ServiceManager serviceManager)
        {
            // Not used; required by IAddinInjected
        }

        public void Stop()
        {
            // Cleanup hook if needed
        }
    }
}

