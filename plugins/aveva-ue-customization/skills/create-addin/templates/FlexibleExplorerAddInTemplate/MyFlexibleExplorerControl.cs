//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Security;
using System.Text;
using System.Windows.Forms;
using System.Xml;
using Aveva.ApplicationFramework;
using Aveva.Core.FlexibleExplorer;

namespace Aveva.Core.Samples
{
    public partial class MyFlexibleExplorerControl : UserControl
    {
        /// <summary>
        /// The flexible explorer.
        /// </summary>
        private FlexibleExplorer.FlexibleExplorer _flexibleExplorer;

        /// <summary>
        /// The dependency resolver.
        /// </summary>
        private readonly IDependencyResolver _dependencyResolver;

        /// <summary>
        ///  A panel to host the control   
        /// </summary>
        private Panel panel1;

        /// <summary>
        /// The example XML file.
        /// </summary>
        public static string ExampleXml = "FlexibleExplorerAddInTemplate.xml";

        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="dependencyResolver">The dependency resolver.</param>
        public MyFlexibleExplorerControl(IDependencyResolver dependencyResolver)
        {
            _flexibleExplorer = null;
            _dependencyResolver = dependencyResolver;

            InitializeComponent();
        }

        /// <summary>
        /// Adds the Flexible Explorer to the panel.
        /// </summary>
        internal void AddFlexibleExplorer()
        {
            panel1.Controls.Add(InitialiseFlexibleExplorer(ExampleXml));
        }

        /// <summary>
        /// Loads XML content securely with XXE protection.
        /// </summary>
        /// <param name="xmlFilePath">The path to the XML file.</param>
        /// <returns>The XML content as a string.</returns>
        private string LoadXmlSecurely(string xmlFilePath)
        {
            // Create secure XML reader settings (XXE Protection)
            var xmlReaderSettings = new XmlReaderSettings
            {
                DtdProcessing = DtdProcessing.Prohibit,  // Disable DTD processing
                XmlResolver = null,  // Disable external entity resolution
                MaxCharactersFromEntities = 1024,  // Limit entity expansion
                MaxCharactersInDocument = 10485760  // 10MB limit
            };

            var xmlDoc = new XmlDocument();

            // Load XML using secure settings
            using (var xmlReader = XmlReader.Create(xmlFilePath, xmlReaderSettings))
            {
                xmlDoc.Load(xmlReader);
            }

            // Return the safely loaded XML content
            return xmlDoc.OuterXml;
        }

        /// <summary>
        /// Validates a file path to prevent directory traversal attacks.
        /// </summary>
        /// <param name="filePath">The file path to validate.</param>
        /// <param name="baseDirectory">The base directory that the file must reside within.</param>
        /// <returns>The validated full path.</returns>
        /// <exception cref="SecurityException">Thrown if path traversal is detected.</exception>
        private string ValidatePath(string filePath, string baseDirectory)
        {
            if (string.IsNullOrWhiteSpace(filePath))
            {
                throw new ArgumentException("File path cannot be null or empty.", nameof(filePath));
            }

            if (string.IsNullOrWhiteSpace(baseDirectory))
            {
                throw new ArgumentException("Base directory cannot be null or empty.", nameof(baseDirectory));
            }

            // Get the full canonical paths
            string fullPath = Path.GetFullPath(filePath);
            string fullBaseDirectory = Path.GetFullPath(baseDirectory);

            // Ensure the resolved path is within the base directory (prevent traversal)
            if (!fullPath.StartsWith(fullBaseDirectory, StringComparison.OrdinalIgnoreCase))
            {
                // Security logging: Path traversal attempt
                Trace.TraceWarning(
                    "[SECURITY] Path traversal attempt detected. File: '{0}', Base: '{1}', Resolved: '{2}'",
                    filePath, baseDirectory, fullPath);
                
                throw new SecurityException(
                    $"Path traversal attempt detected. File path '{filePath}' " +
                    $"resolves outside the allowed directory '{baseDirectory}'.");
            }

            // Additional check: ensure the file exists and is a file (not a directory or symlink)
            if (!File.Exists(fullPath))
            {
                throw new FileNotFoundException($"File not found: {fullPath}", fullPath);
            }

            return fullPath;
        }

        /// <summary>
        /// Initialises the Flexible Explorer.
        /// </summary>
        /// <param name="rootNode">The root node.</param>
        /// <returns>
        /// A FlexibleExplorer.
        /// </returns>
        private FlexibleExplorer.FlexibleExplorer InitialiseFlexibleExplorer(string xmlFileName)
        {
            if (_flexibleExplorer != null)
            {
                
            }
            else
            {
                _flexibleExplorer = new FlexibleExplorer.FlexibleExplorer(_dependencyResolver, null, true);

                _flexibleExplorer.Dock = DockStyle.Fill;
                _flexibleExplorer.BorderStyle = BorderStyle.FixedSingle;

                _flexibleExplorer.DisplayCheckBox = false;
                _flexibleExplorer.DisplayLockIndicator = false;
                _flexibleExplorer.DisplayClaimIndicator = false;
                _flexibleExplorer.DisplayReadOnlyIndicator = false;

                // Set custom refresh manager
                _flexibleExplorer.CustomRefreshManager = new MyCustomRefreshManager();

                _flexibleExplorer.MultiSelect(true);

                try
                {
                    // Get the base directory (add-in assembly location)
                    string baseDirectory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
                    
                    // Construct the expected XML file path
                    string expectedXmlPath = Path.Combine(baseDirectory, xmlFileName);
                    
                    // locate the config file alongside to this assembly
                    var xmlFile = XmlDefinitionProvider.GetLocalFile(expectedXmlPath);

                    if (xmlFile == null)
                    {
                        Log.Logger().MessageFormat("XML file not found: {0}", xmlFileName);
                        return null;
                    }

                    // Validate the path to prevent directory traversal attacks
                    string validatedPath = ValidatePath(xmlFile, baseDirectory);

                    // Load XML securely with XXE protection
                    string xmlContent = LoadXmlSecurely(validatedPath);
                    
                    var definitionProvider = new XmlDefinitionProvider(xmlContent, xmlFileName);

                    _flexibleExplorer.CreateRoots(definitionProvider.RootDefinitions, false);
                }
                catch (SecurityException ex)
                {
                    // Handle path traversal attempts
                    Trace.TraceWarning("[SECURITY] Security exception loading XML '{0}': {1}", xmlFileName, ex.Message);
                    Log.Logger().MessageFormat("Security error loading {0}: {1}", xmlFileName, ex.Message);
                    ApplicationFramework.Presentation.MessageBoxEx.Show(
                        $"Security policy violation: {ex.Message}",
                        "Security Error",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                }
                catch (XmlException ex)
                {
                    // Handle XML parsing errors
                    Log.Logger().MessageFormat("XML parsing error in {0}: {1}", xmlFileName, ex.Message);
                    ApplicationFramework.Presentation.MessageBoxEx.Show(
                        $"Failed to load XML configuration: {ex.Message}",
                        "Configuration Error",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                }
                catch (FileNotFoundException ex)
                {
                    // Handle missing file errors
                    Log.Logger().MessageFormat("File not found: {0}", ex.Message);
                    ApplicationFramework.Presentation.MessageBoxEx.Show(
                        $"Configuration file not found: {ex.Message}",
                        "File Not Found",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                }
                catch (Utilities.Messaging.PdmsException ex)
                {
                    ApplicationFramework.Presentation.MessageBoxEx.Show(ex.Error.MessageText());
                }
                catch (Exception ex)
                {
                    // Last resort - log full exception details for troubleshooting (secured)
                    Trace.TraceError("Unexpected error initializing Flexible Explorer: {0}", ex);
                    Log.Logger().MessageFormat("Unexpected error initializing Flexible Explorer: {0}", ex.GetType().Name);
                    
                    // Show generic message to user (no sensitive details)
                    ApplicationFramework.Presentation.MessageBoxEx.Show(
                        "An unexpected error occurred while initializing the explorer. Please contact support if the problem persists.",
                        "Initialization Error",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                }
            }
            
            return _flexibleExplorer;
        }

        private void InitializeComponent()
        {
            this.panel1 = new Panel();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Dock = DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(364, 471);
            this.panel1.TabIndex = 0;
            // 
            // MyFlexibleExplorerControl
            // 
            this.Controls.Add(this.panel1);
            this.Name = "MyFlexibleExplorerControl";
            this.Size = new System.Drawing.Size(364, 471);
            this.ResumeLayout(false);
        }
        
    }
}
