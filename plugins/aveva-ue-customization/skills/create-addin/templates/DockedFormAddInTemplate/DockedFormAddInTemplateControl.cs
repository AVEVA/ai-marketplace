using System.Windows.Forms;
using Aveva.ApplicationFramework;

namespace DockedFormAddInTemplate
{
    public class DockedFormAddInTemplateControl : UserControl
    {

        /// <summary>
        /// The dependency resolver.
        /// </summary>
        private readonly IDependencyResolver _dependencyResolver;

        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="dependencyResolver">The dependency resolver.</param>
        public DockedFormAddInTemplateControl(IDependencyResolver dependencyResolver)
        {
            _dependencyResolver = dependencyResolver;

            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.SuspendLayout();
            // 
            // DockedFormAddInTemplateControl
            // 
            this.Name = "DockedFormAddInTemplateControl";
            this.Size = new System.Drawing.Size(300, 700);
            this.ResumeLayout(false);

        }
    }
}

