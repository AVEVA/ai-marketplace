using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Sockets;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Aveva.ApplicationFramework;
using Aveva.Core.Utilities.AvevaConnect;
using Newtonsoft.Json.Linq;

namespace WebEndpointAddInTemplate
{
    public class WebEndpointAddInTemplateControl : UserControl
    {
        private Button btnConnect;
        private TextBox txtUrl;
        private DataGridView gridOutput;
        private Button btnUpdate;

        /// <summary>
        /// Allowlist of permitted hosts for external requests (SSRF protection).
        /// Add your trusted API endpoints here.
        /// </summary>
        private static readonly HashSet<string> AllowedHosts = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "jsonplaceholder.typicode.com",
            "api.yourdomain.com"
            // Add additional trusted hosts as needed
        };

        /// <summary>
        /// The dependency resolver.
        /// </summary>
        private readonly IDependencyResolver _dependencyResolver;

        /// <summary>
        /// Constructor.
        /// </summary>
        /// <param name="dependencyResolver">The dependency resolver.</param>
        public WebEndpointAddInTemplateControl(IDependencyResolver dependencyResolver)
        {
            _dependencyResolver = dependencyResolver;

            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.btnConnect = new System.Windows.Forms.Button();
            this.txtUrl = new System.Windows.Forms.TextBox();
            this.gridOutput = new System.Windows.Forms.DataGridView();
            this.btnUpdate = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.gridOutput)).BeginInit();
            this.SuspendLayout();
            // 
            // btnConnect
            // 
            this.btnConnect.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.btnConnect.Location = new System.Drawing.Point(255, 18);
            this.btnConnect.Name = "btnConnect";
            this.btnConnect.Size = new System.Drawing.Size(75, 23);
            this.btnConnect.TabIndex = 0;
            this.btnConnect.Text = "Connect";
            this.btnConnect.UseVisualStyleBackColor = true;
            this.btnConnect.Click += new System.EventHandler(this.btnConnect_Click);
            // 
            // txtUrl
            // 
            this.txtUrl.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.txtUrl.Location = new System.Drawing.Point(12, 18);
            this.txtUrl.Name = "txtUrl";
            this.txtUrl.Size = new System.Drawing.Size(237, 20);
            this.txtUrl.TabIndex = 1;
            this.txtUrl.Text = "https://jsonplaceholder.typicode.com/users";
            // 
            // gridOutput
            // 
            this.gridOutput.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.gridOutput.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.gridOutput.Location = new System.Drawing.Point(12, 62);
            this.gridOutput.Name = "gridOutput";
            this.gridOutput.Size = new System.Drawing.Size(318, 536);
            this.gridOutput.TabIndex = 2;
            // 
            // btnUpdate
            // 
            this.btnUpdate.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.btnUpdate.Location = new System.Drawing.Point(255, 614);
            this.btnUpdate.Name = "btnUpdate";
            this.btnUpdate.Size = new System.Drawing.Size(75, 23);
            this.btnUpdate.TabIndex = 3;
            this.btnUpdate.Text = "Update";
            this.btnUpdate.UseVisualStyleBackColor = true;
            this.btnUpdate.Click += new System.EventHandler(this.btnUpdate_Click);
            // 
            // WebEndpointAddInTemplateControl
            // 
            this.Controls.Add(this.btnUpdate);
            this.Controls.Add(this.gridOutput);
            this.Controls.Add(this.txtUrl);
            this.Controls.Add(this.btnConnect);
            this.Name = "WebEndpointAddInTemplateControl";
            this.Size = new System.Drawing.Size(350, 652);
            ((System.ComponentModel.ISupportInitialize)(this.gridOutput)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        private async void btnConnect_Click(object sender, EventArgs e)
        {
            try
            {
                string url = string.IsNullOrWhiteSpace(txtUrl.Text) 
                    ? "https://jsonplaceholder.typicode.com/users" 
                    : txtUrl.Text;

                btnConnect.Enabled = false;
                btnConnect.Text = "Loading...";

                string json = await FetchJsonFromUrl(url);
                BindJsonToGrid(json);

                btnConnect.Text = "Connect";
            }
            catch (ArgumentException ex)
            {
                MessageBox.Show($"Invalid URL: {ex.Message}", "Invalid Input", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                btnConnect.Text = "Connect";
            }
            catch (SecurityException ex)
            {
                MessageBox.Show($"Security Error: {ex.Message}", "Access Denied", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                btnConnect.Text = "Connect";
            }
            catch (HttpRequestException)
            {
                MessageBox.Show("Unable to fetch data from the server. Please check your connection and try again.", 
                    "Connection Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                btnConnect.Text = "Connect";
            }
            catch (TaskCanceledException)
            {
                MessageBox.Show("Request timed out. Please try again.", 
                    "Timeout", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                btnConnect.Text = "Connect";
            }
            catch (Exception ex)
            {
                // Last resort - log full details for diagnostics
                Trace.TraceError("Unexpected error in btnConnect_Click: {0}", ex);
                
                MessageBox.Show("An unexpected error occurred. Please contact support if the problem persists.", 
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                btnConnect.Text = "Connect";
            }
            finally
            {
                btnConnect.Enabled = true;
            }
        }

        private async Task<string> FetchJsonFromUrl(string url)
        {
            // Validate URL format
            if (!Uri.TryCreate(url, UriKind.Absolute, out Uri uri))
            {
                throw new ArgumentException("Invalid URL format.");
            }

            // Enforce HTTPS only (SSRF Protection)
            if (uri.Scheme != Uri.UriSchemeHttps)
            {
                Trace.TraceWarning("[SECURITY] Non-HTTPS URL blocked: {0}", url);
                throw new ArgumentException("Only HTTPS URLs are allowed for security reasons.");
            }

            // Whitelist allowed hosts (SSRF Protection)
            if (!AllowedHosts.Contains(uri.Host))
            {
                Trace.TraceWarning(
                    "[SECURITY] SSRF attempt blocked - Host '{0}' not in allowlist. Allowed hosts: {1}",
                    uri.Host, string.Join(", ", AllowedHosts));
                
                throw new ArgumentException($"Host '{uri.Host}' is not in the allowlist. Allowed hosts: {string.Join(", ", AllowedHosts)}");
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
                        
                        throw new SecurityException("Access to private IP ranges is forbidden for security reasons.");
                    }
                }
            }
            catch (SocketException)
            {
                throw new ArgumentException($"Unable to resolve host '{uri.Host}'.");
            }

            // Configure HttpClient with security settings
            var handler = new HttpClientHandler
            {
                ServerCertificateCustomValidationCallback = (message, cert, chain, errors) =>
                {
                    // Enforce strict certificate validation
                    if (errors != System.Net.Security.SslPolicyErrors.None)
                    {
                        // Security logging: Certificate validation failure
                        Trace.TraceWarning(
                            "[SECURITY] Certificate validation failed for '{0}': {1}",
                            message?.RequestUri?.Host ?? "unknown", errors);
                        
                        // In production, log this for security monitoring
                        return false;
                    }
                    return true;
                }
            };

            var accessToken = CoreConnectManager.GetAccessToken();
            if (string.IsNullOrWhiteSpace(accessToken))
            {
                throw new SecurityException("Unable to obtain valid access token. Please ensure you are authenticated with AVEVA Connect.");
            }

            using (HttpClient client = new HttpClient(handler, disposeHandler: true))
            {
                client.Timeout = TimeSpan.FromSeconds(30);
                client.DefaultRequestHeaders.Add("User-Agent", "AVEVA-UE-Customization/1.0");
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                HttpResponseMessage response = await client.GetAsync(uri);
                if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                {
                    throw new SecurityException("Authentication failed. The access token may be invalid or expired.");
                }
                response.EnsureSuccessStatusCode();

                // Limit response size to prevent DoS (10MB limit)
                const long maxResponseSize = 10 * 1024 * 1024;
                if (response.Content.Headers.ContentLength > maxResponseSize)
                {
                    Trace.TraceWarning(
                        "[SECURITY] Response size exceeds limit for '{0}': {1} bytes (max: {2})",
                        uri, response.Content.Headers.ContentLength, maxResponseSize);
                    
                    throw new InvalidOperationException("Response size exceeds maximum allowed limit.");
                }

                return await response.Content.ReadAsStringAsync();
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

        private void BindJsonToGrid(string json)
        {
            // Limit JSON size to prevent DoS attacks (5MB limit)
            const int maxJsonSize = 5 * 1024 * 1024;
            if (json.Length > maxJsonSize)
            {
                throw new InvalidOperationException("JSON response too large to process.");
            }

            DataTable table = new DataTable();
            table.Columns.Add("Path");
            table.Columns.Add("Type");
            table.Columns.Add("Value");

            JToken root = JToken.Parse(json);
            const int maxRecursionDepth = 32;
            AddJsonRows(root, "$", table, 0, maxRecursionDepth);

            this.gridOutput.AutoGenerateColumns = true;
            this.gridOutput.DataSource = table;
        }

        private void AddJsonRows(JToken token, string path, DataTable table, int depth, int maxDepth)
        {
            // Prevent stack overflow by limiting recursion depth
            if (depth > maxDepth)
            {
                table.Rows.Add(path, "Error", "<Max depth exceeded>");
                return;
            }

            if (token.Type == JTokenType.Object)
            {
                table.Rows.Add(path, token.Type.ToString(), "(object)");

                foreach (JProperty property in ((JObject)token).Properties())
                {
                    AddJsonRows(property.Value, path + "." + property.Name, table, depth + 1, maxDepth);
                }

                return;
            }

            if (token.Type == JTokenType.Array)
            {
                JArray array = (JArray)token;
                table.Rows.Add(path, token.Type.ToString(), array.Count.ToString(CultureInfo.InvariantCulture) + " item(s)");

                int index = 0;
                foreach (JToken item in array)
                {
                    AddJsonRows(item, string.Format(CultureInfo.InvariantCulture, "{0}[{1}]", path, index), table, depth + 1, maxDepth);
                    index++;
                }

                return;
            }

            table.Rows.Add(path, token.Type.ToString(), GetTokenValue(token));
        }

        private static string GetTokenValue(JToken token)
        {
            switch (token.Type)
            {
                case JTokenType.String:
                    return token.Value<string>();
                case JTokenType.Integer:
                case JTokenType.Float:
                case JTokenType.Boolean:
                    return token.ToString();
                case JTokenType.Null:
                    return "null";
                default:
                    return string.Empty;
            }
        }

        private void btnUpdate_Click(object sender, EventArgs e)
        {
            // to do, add code in here to work with your json to update your project as needed. You can access the current json from the grid by iterating through the rows and reconstructing the json, or you can maintain a separate variable to hold the current json and update it as needed.
        }
    }
}
