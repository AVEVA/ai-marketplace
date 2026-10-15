using System;
using System.Linq;
using System.Windows.Forms;
using Aveva.Core.PMLNet;

namespace PMLExtensionTemplate
{
    [PMLNetCallable()]
    public class PMLExtensionTemplateMethods
    {
        /// <summary>
        /// Maximum allowed message length to prevent DoS attacks.
        /// </summary>
        private const int MaxMessageLength = 1000;

        [PMLNetCallable()]
        public PMLExtensionTemplateMethods()
        {
        }

        [PMLNetCallable()]
        public void Assign(PMLExtensionTemplateMethods that)
        {
        }

        /// <summary>
        /// Displays a message box with the provided message.
        /// Input is validated and sanitized for security.
        /// </summary>
        /// <param name="message">The message to display.</param>
        [PMLNetCallable()]
        public void ShowMessageBox(string message)
        {
            try
            {
                // Validate input - reject null or whitespace
                if (string.IsNullOrWhiteSpace(message))
                {
                    // Silently return for empty messages
                    return;
                }

                // Limit message length to prevent DoS attacks
                if (message.Length > MaxMessageLength)
                {
                    message = message.Substring(0, MaxMessageLength) + "... (message truncated)";
                }

                // Sanitize message - remove control characters except newlines and carriage returns
                // This prevents potential UI manipulation or injection attacks
                message = new string(message.Where(c => 
                    !char.IsControl(c) || c == '\n' || c == '\r' || c == '\t').ToArray());

                // Display the validated and sanitized message
                MessageBox.Show(
                    message,
                    "PML Extension",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (ArgumentException ex)
            {
                // Invalid message or MessageBox parameters
                System.Diagnostics.Trace.WriteLine($"[PMLExtensionTemplate] Invalid MessageBox parameters: {ex.Message}");
                
                MessageBox.Show(
                    "Invalid message format.",
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
            }
            catch (System.ComponentModel.Win32Exception ex)
            {
                // System error displaying MessageBox
                System.Diagnostics.Trace.WriteLine($"[PMLExtensionTemplate] System error displaying MessageBox: {ex.Message}");
                
                MessageBox.Show(
                    "System error displaying message.",
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            catch (Exception ex)
            {
                // Last resort - log error without exposing details to user
                System.Diagnostics.Trace.WriteLine($"[PMLExtensionTemplate] Unexpected MessageBox error: {ex.GetType().Name}");
                
                // Show generic error message
                MessageBox.Show(
                    "An unexpected error occurred while displaying the message.",
                    "Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
        }
    }
}

