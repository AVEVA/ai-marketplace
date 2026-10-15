using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;
using Aveva.Core.Database;

namespace WebEndpointAddInTemplate
{
    public class WebEndpointAddInTemplate : IAddinInjected
    {
        private DockedWindow _window;
        private WebEndpointAddInTemplateControl _control;
        private ShowWebEndpointAddInTemplateCommand _showCommand;
        private const string AddinKey = "WebEndpointAddInTemplate.DockedWindow";

        public string Description => "WebEndpointAddInTemplate scaffold for UE";

        public string Name => "WebEndpointAddInTemplate";

        public void Start(IDependencyResolver resolver)
        {
            // Resolve window manager and create an empty docked window
            IWindowManager windowManager = DependencyResolver.GetImplementationOf<IWindowManager>();
            _control = new WebEndpointAddInTemplateControl(resolver);
            _window = windowManager.CreateDockedWindow(AddinKey, "WebEndpointAddInTemplate", _control, DockedPosition.Right);
            _window.Width = 300;
            _window.SaveLayout = true;

            // Register command to show/hide the docked window
            ICommandManager commandManager = DependencyResolver.GetImplementationOf<ICommandManager>();
            _showCommand = new ShowWebEndpointAddInTemplateCommand(_window);
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
