using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;
using Aveva.Core.Database;

namespace WebpageAddInTemplate
{
    public class WebpageAddInTemplate : IAddinInjected
    {
        private DockedWindow _window;
        private WebpageAddInTemplateControl _control;
        private ShowWebpageAddInTemplateCommand _showCommand;
        private const string AddinKey = "WebpageAddInTemplate.DockedWindow";

        public string Description => "WebpageAddInTemplate scaffold for UE with web browser viewer";

        public string Name => "WebpageAddInTemplate";

        public void Start(IDependencyResolver resolver)
        {
            // Resolve window manager and create an empty docked window
            IWindowManager windowManager = DependencyResolver.GetImplementationOf<IWindowManager>();
            _control = new WebpageAddInTemplateControl(resolver);
            _window = windowManager.CreateDockedWindow(AddinKey, "Webpage Viewer", _control, DockedPosition.Right);
            _window.Width = 800;
            _window.SaveLayout = true;

            // Register command to show/hide the docked window
            ICommandManager commandManager = DependencyResolver.GetImplementationOf<ICommandManager>();
            _showCommand = new ShowWebpageAddInTemplateCommand(_window);
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
