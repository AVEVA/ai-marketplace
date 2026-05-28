using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Security;
using System.Threading.Tasks;
using System.Windows.Forms;
using Aveva.ApplicationFramework;
using Microsoft.Web.WebView2.WinForms;
using Microsoft.Web.WebView2.Core;

namespace WebpageAddInTemplate
{
    public class WebpageAddInTemplateControl : UserControl
    {
        private Button btnLoad;
        private TextBox txtUrl;
        private WebView2 webView;
        private Label lblUrl;
        private bool _isInitialized = false;

        /// <summary>
        /// Allowlist of permitted domains for navigation (SSRF protection).
        /// Add your trusted domains here.
        /// </summary>
        private static readonly HashSet<string> AllowedDomains = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "www.aveva.com",
            "aveva.com",
            "docs.aveva.com",
            "community.aveva.com"
            // Add additional trusted domains as needed
        };

        /// <summary>
        /// The dependency resolver.
        /// </summary>
        private readonly IDependencyResolver _dependencyResolver;

        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="dependencyResolver">The dependency resolver.</param>
        public WebpageAddInTemplateControl(IDependencyResolver dependencyResolver)
        {
            _dependencyResolver = dependencyResolver;

            InitializeComponent();
            InitializeWebView();
        }

        private async void InitializeWebView()
        {
            try
            {
                await webView.EnsureCoreWebView2Async(null);
                _isInitialized = true;
                
                // Configure security settings
                if (webView.CoreWebView2 != null)
                {
                    // Disable developer tools in production (comment out for development)
                    // webView.CoreWebView2.Settings.AreDevToolsEnabled = false;
                    
                    // Configure default security settings
                    webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = true;
                    webView.CoreWebView2.Settings.IsStatusBarEnabled = true;
                    webView.CoreWebView2.Settings.IsZoomControlEnabled = true;
                }
                
                // Load the default URL after initialization
                LoadUrl(txtUrl.Text);
            }
            catch (System.IO.FileNotFoundException ex)
            {
                // WebView2 Runtime not found
                Trace.TraceError("WebView2 Runtime not found: {0}", ex.Message);
                
                MessageBox.Show("Microsoft Edge WebView2 Runtime is not installed. Please install it from:\nhttps://developer.microsoft.com/microsoft-edge/webview2/", 
                    "WebView2 Runtime Missing", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (System.Runtime.InteropServices.COMException ex)
            {
                // COM initialization failure
                Trace.TraceError("WebView2 COM initialization failed: {0}", ex.Message);
                
                MessageBox.Show("WebView2 component initialization failed. Please restart the application.", 
                    "Initialization Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            catch (UnauthorizedAccessException ex)
            {
                // Permission denied for WebView2 data folder
                Trace.TraceError("WebView2 access denied: {0}", ex.Message);
                
                MessageBox.Show("Access denied initializing WebView2. Please check your permissions.", 
                    "Access Denied", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
            catch (Exception ex)
            {
                // Last resort - log full exception details for troubleshooting (secured)
                Trace.TraceError("Unexpected error initializing WebView2: {0}", ex);
                
                // Show generic message to user (no sensitive details)
                MessageBox.Show("Error initializing WebView2. Please ensure Microsoft Edge WebView2 Runtime is installed.\n\nIf the problem persists, contact support.", 
                    "Initialization Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void InitializeComponent()
        {
            this.lblUrl = new System.Windows.Forms.Label();
            this.txtUrl = new System.Windows.Forms.TextBox();
            this.btnLoad = new System.Windows.Forms.Button();
            this.webView = new Microsoft.Web.WebView2.WinForms.WebView2();
            ((System.ComponentModel.ISupportInitialize)(this.webView)).BeginInit();
            this.SuspendLayout();
            // 
            // lblUrl
            // 
            this.lblUrl.AutoSize = true;
            this.lblUrl.Location = new System.Drawing.Point(12, 15);
            this.lblUrl.Name = "lblUrl";
            this.lblUrl.Size = new System.Drawing.Size(32, 13);
            this.lblUrl.TabIndex = 0;
            this.lblUrl.Text = "URL:";
            // 
            // txtUrl
            // 
            this.txtUrl.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtUrl.Location = new System.Drawing.Point(50, 12);
            this.txtUrl.Name = "txtUrl";
            this.txtUrl.Size = new System.Drawing.Size(570, 20);
            this.txtUrl.TabIndex = 1;
            this.txtUrl.Text = "https://www.aveva.com/en/about/news/press-releases/";
            this.txtUrl.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtUrl_KeyPress);
            // 
            // btnLoad
            // 
            this.btnLoad.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnLoad.Location = new System.Drawing.Point(626, 10);
            this.btnLoad.Name = "btnLoad";
            this.btnLoad.Size = new System.Drawing.Size(75, 23);
            this.btnLoad.TabIndex = 2;
            this.btnLoad.Text = "Load";
            this.btnLoad.UseVisualStyleBackColor = true;
            this.btnLoad.Click += new System.EventHandler(this.btnLoad_Click);
            // 
            // webView
            // 
            this.webView.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.webView.Location = new System.Drawing.Point(12, 40);
            this.webView.Name = "webView";
            this.webView.Size = new System.Drawing.Size(689, 600);
            this.webView.TabIndex = 3;
            this.webView.ZoomFactor = 1D;
            // 
            // WebpageAddInTemplateControl
            // 
            this.Controls.Add(this.webView);
            this.Controls.Add(this.btnLoad);
            this.Controls.Add(this.txtUrl);
            this.Controls.Add(this.lblUrl);
            this.Name = "WebpageAddInTemplateControl";
            this.Size = new System.Drawing.Size(713, 652);
            ((System.ComponentModel.ISupportInitialize)(this.webView)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            LoadUrl(txtUrl.Text);
        }

        private void txtUrl_KeyPress(object sender, KeyPressEventArgs e)
        {
            // Load URL when Enter key is pressed
            if (e.KeyChar == (char)Keys.Enter)
            {
                LoadUrl(txtUrl.Text);
                e.Handled = true; // Prevent the beep sound
            }
        }

        private async void LoadUrl(string url)
        {
            try
            {
                if (!_isInitialized)
                {
                    MessageBox.Show("WebView2 is still initializing. Please wait a moment and try again.", 
                        "Not Ready", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    return;
                }

                if (string.IsNullOrWhiteSpace(url))
                {
                    MessageBox.Show("Please enter a valid URL.", "Invalid URL", 
                        MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Validate URL format
                if (!Uri.TryCreate(url, UriKind.Absolute, out Uri uri))
                {
                    // Try adding https:// if no scheme is present
                    if (!Uri.TryCreate("https://" + url, UriKind.Absolute, out uri))
                    {
                        MessageBox.Show("Invalid URL format. Please enter a valid URL.", "Invalid URL", 
                            MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        return;
                    }
                    url = "https://" + url;
                    txtUrl.Text = url;
                }

                // Enforce HTTPS only (SSRF Protection)
                if (uri.Scheme != Uri.UriSchemeHttps)
                {
                    Trace.TraceWarning("[SECURITY] Non-HTTPS URL blocked: {0}", url);
                    MessageBox.Show("Only HTTPS URLs are allowed for security reasons.", "Security Policy", 
                        MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // Check against allowlist
                if (!AllowedDomains.Contains(uri.Host))
                {
                    Trace.TraceWarning(
                        "[SECURITY] Navigation to untrusted domain '{0}' requested. Awaiting user confirmation.",
                        uri.Host);
                    
                    var result = MessageBox.Show(
                        $"The domain '{uri.Host}' is not in the trusted list.\n\n" +
                        $"Allowed domains:\n{string.Join("\n", AllowedDomains.OrderBy(d => d))}\n\n" +
                        $"Do you want to navigate to this untrusted domain anyway?",
                        "Untrusted Domain",
                        MessageBoxButtons.YesNo,
                        MessageBoxIcon.Warning);

                    if (result != DialogResult.Yes)
                    {
                        Trace.TraceWarning(
                            "[SECURITY] User declined navigation to untrusted domain '{0}'",
                            uri.Host);
                        return;
                    }
                    else
                    {
                        Trace.TraceWarning(
                            "[SECURITY] User approved navigation to untrusted domain '{0}'",
                            uri.Host);
                    }
                }

                // Block private IP ranges (SSRF Protection)
                try
                {
                    IPAddress[] ipAddresses = await Dns.GetHostAddressesAsync(uri.Host);
                    foreach (var ip in ipAddresses)
                    {
                        if (IsPrivateIP(ip))
                        {
                            Trace.TraceWarning(
                                "[SECURITY] SSRF attempt blocked - Private IP detected for host '{0}': {1}",
                                uri.Host, ip);
                            
                            MessageBox.Show(
                                "Access to private IP ranges is forbidden for security reasons.",
                                "Security Policy",
                                MessageBoxButtons.OK,
                                MessageBoxIcon.Error);
                            return;
                        }
                    }
                }
                catch (SocketException)
                {
                    MessageBox.Show($"Unable to resolve host '{uri.Host}'. Please check the URL and try again.", 
                        "DNS Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                btnLoad.Enabled = false;
                btnLoad.Text = "Loading...";

                webView.Source = uri;
            }
            catch (ArgumentException ex)
            {
                MessageBox.Show($"Invalid URL: {ex.Message}", "Invalid Input", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                btnLoad.Text = "Load";
                btnLoad.Enabled = true;
            }
            catch (SecurityException ex)
            {
                // SecurityException messages are controlled by our validation code - safe to show
                MessageBox.Show($"Security Error: {ex.Message}", "Access Denied", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                btnLoad.Text = "Load";
                btnLoad.Enabled = true;
            }
            catch (UriFormatException ex)
            {
                // Invalid URL format
                Trace.TraceWarning("Invalid URL format: {0}", ex.Message);
                
                MessageBox.Show("Invalid URL format. Please enter a valid HTTPS URL.", "Invalid URL", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                btnLoad.Text = "Load";
                btnLoad.Enabled = true;
            }
            catch (System.Net.Http.HttpRequestException ex)
            {
                // Network or HTTP error
                Trace.TraceWarning("HTTP request failed: {0}", ex.Message);
                
                MessageBox.Show("Unable to load the page. Please check your network connection and try again.", "Connection Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                btnLoad.Text = "Load";
                btnLoad.Enabled = true;
            }
            catch (TaskCanceledException)
            {
                // Navigation timeout
                Trace.TraceWarning("Page load timed out");
                
                MessageBox.Show("Page load timed out. Please try again.", "Timeout", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                btnLoad.Text = "Load";
                btnLoad.Enabled = true;
            }
            catch (Exception ex)
            {
                // Last resort - log full exception details for troubleshooting (secured)
                Trace.TraceError("Unexpected error navigating to URL: {0}", ex);
                
                // Show generic message to user (no sensitive details)
                MessageBox.Show("An unexpected error occurred while loading the page. Please try again or contact support if the problem persists.", "Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                btnLoad.Text = "Load";
                btnLoad.Enabled = true;
            }
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            
            // Subscribe to WebView2 events
            if (webView.CoreWebView2 != null)
            {
                webView.CoreWebView2.NavigationCompleted += CoreWebView2_NavigationCompleted;
                webView.CoreWebView2.NavigationStarting += CoreWebView2_NavigationStarting;
            }
        }

        private void CoreWebView2_NavigationStarting(object sender, CoreWebView2NavigationStartingEventArgs e)
        {
            if (InvokeRequired)
            {
                Invoke(new Action(() =>
                {
                    btnLoad.Enabled = false;
                    btnLoad.Text = "Loading...";
                }));
            }
            else
            {
                btnLoad.Enabled = false;
                btnLoad.Text = "Loading...";
            }
        }

        private void CoreWebView2_NavigationCompleted(object sender, CoreWebView2NavigationCompletedEventArgs e)
        {
            if (InvokeRequired)
            {
                Invoke(new Action(() =>
                {
                    btnLoad.Enabled = true;
                    btnLoad.Text = "Load";
                }));
            }
            else
            {
                btnLoad.Enabled = true;
                btnLoad.Text = "Load";
            }
        }

        /// <summary>
        /// Checks if an IP address is in a private range (SSRF Protection).
        /// </summary>
        /// <param name="ip">The IP address to check.</param>
        /// <returns>True if the IP is private, false otherwise.</returns>
        private static bool IsPrivateIP(IPAddress ip)
        {
            if (ip.AddressFamily == AddressFamily.InterNetworkV6)
            {
                // Block IPv6 loopback and private addresses
                return ip.IsIPv6LinkLocal || ip.IsIPv6SiteLocal || IPAddress.IsLoopback(ip);
            }

            byte[] bytes = ip.GetAddressBytes();

            // Check for private IPv4 ranges:
            // 10.0.0.0/8
            // 127.0.0.0/8 (loopback)
            // 172.16.0.0/12
            // 192.168.0.0/16
            // 169.254.0.0/16 (link-local)
            return bytes[0] == 10 ||
                   bytes[0] == 127 ||
                   (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] <= 31) ||
                   (bytes[0] == 192 && bytes[1] == 168) ||
                   (bytes[0] == 169 && bytes[1] == 254);
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (webView != null && webView.CoreWebView2 != null)
                {
                    webView.CoreWebView2.NavigationCompleted -= CoreWebView2_NavigationCompleted;
                    webView.CoreWebView2.NavigationStarting -= CoreWebView2_NavigationStarting;
                }
                webView?.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
