using System;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Web;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.Login
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlError.Visible = false;
                pnlSuccess.Visible = false;

                // Connection indicator: runs every time Login.aspx is loaded/run
                LogConnectionStatus();

                // Handle sign-out / logout action
                if (string.Equals(Request.QueryString["action"], "logout", StringComparison.OrdinalIgnoreCase))
                {
                    Session.Clear();
                    Session.Abandon();

                    if (Request.Cookies["RememberedEmail"] != null)
                    {
                        HttpCookie expiredCookie = new HttpCookie("RememberedEmail")
                        {
                            Expires = DateTime.UtcNow.AddDays(-1)
                        };
                        Response.Cookies.Add(expiredCookie);
                    }

                    txtEmail.Text = string.Empty;
                    txtPassword.Text = string.Empty;
                    chkRememberMe.Checked = false;

                    pnlSuccess.Visible = true;
                    lblSuccessMessage.Text = "You have been successfully signed out.";
                    return;
                }

                // Check for redirect message parameter
                if (!string.IsNullOrWhiteSpace(Request.QueryString["msg"]))
                {
                    pnlError.Visible = true;
                    lblErrorMessage.Text = Server.HtmlEncode(Request.QueryString["msg"]);
                }

                // Pre-fill email if remembered from cookie
                if (Request.Cookies["RememberedEmail"] != null)
                {
                    txtEmail.Text = Request.Cookies["RememberedEmail"].Value;
                    chkRememberMe.Checked = true;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            pnlSuccess.Visible = false;

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // 1. Authenticate using dedicated UserRepository.Login method and UserLogin model
            if (UserRepository.Login(email, password, out UserLogin authenticatedUser, out string errorMessage))
            {
                // 2. Establish user session
                Session["UserID"] = authenticatedUser.UserID;
                Session["UserEmail"] = authenticatedUser.Email;
                Session["FirstName"] = authenticatedUser.FirstName;
                Session["LastName"] = authenticatedUser.LastName;
                Session["FullName"] = $"{authenticatedUser.FirstName} {authenticatedUser.LastName}".Trim();
                Session["Role"] = authenticatedUser.Role;

                // 3. Handle Remember Me cookie
                if (chkRememberMe.Checked)
                {
                    HttpCookie emailCookie = new HttpCookie("RememberedEmail", authenticatedUser.Email)
                    {
                        Expires = DateTime.UtcNow.AddDays(30)
                    };
                    Response.Cookies.Add(emailCookie);
                }
                else if (Request.Cookies["RememberedEmail"] != null)
                {
                    HttpCookie expiredCookie = new HttpCookie("RememberedEmail")
                    {
                        Expires = DateTime.UtcNow.AddDays(-1)
                    };
                    Response.Cookies.Add(expiredCookie);
                }

                // 4. Show proper modal and redirect based on role
                bool isAdmin = string.Equals(authenticatedUser.Role, "Admin", StringComparison.OrdinalIgnoreCase);
                string welcomeName = !string.IsNullOrWhiteSpace(authenticatedUser.FirstName) 
                    ? authenticatedUser.FirstName 
                    : (!string.IsNullOrWhiteSpace(authenticatedUser.FullName) ? authenticatedUser.FullName : "User");
                string redirectUrl = isAdmin 
                    ? "../Admin/Dashboard.aspx" 
                    : $"../User/Portfolio.aspx?userId={authenticatedUser.UserID}";

                string safeWelcomeName = (welcomeName ?? "User").Replace("\\", "\\\\").Replace("'", "\\'").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "");
                string safeRedirectUrl = redirectUrl.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\"", "\\\"");

                string modalScript = $"showLoginSuccessModal('{safeWelcomeName}', '{safeRedirectUrl}');";
                ClientScript.RegisterStartupScript(this.GetType(), "LoginSuccessModal", modalScript, true);
            }
            else
            {
                // Display exact error message from repository as lower-right toast after loading check
                pnlError.Visible = true;
                lblErrorMessage.Text = errorMessage;
                ClientScript.RegisterStartupScript(this.GetType(), "LoginErrorLoading", "handleLoginError();", true);
            }
        }

        private void LogConnectionStatus()
        {
            string dbName = "IPTPersonalWebsite";
            string serverName = ".";
            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(conn.ConnectionString);
                    if (!string.IsNullOrWhiteSpace(builder.InitialCatalog)) dbName = builder.InitialCatalog;
                    if (!string.IsNullOrWhiteSpace(builder.DataSource)) serverName = builder.DataSource;
                }
            }
            catch
            {
                // Fallback to defaults if connection string is unavailable
            }

            Stopwatch sw = Stopwatch.StartNew();
            bool isConnected = DatabaseConnection.TestConnection(out string message);
            sw.Stop();

            long elapsedMs = sw.ElapsedMilliseconds;
            string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

            // 1. Output to Server Debug and Console
            string serverLog = $"[{timestamp}] [DB Connection Indicator] {(isConnected ? "SUCCESS" : "FAILED")} ({elapsedMs}ms) - Database: '{dbName}', Server: '{serverName}' | Result: {message}";
            Debug.WriteLine(serverLog);
            Console.WriteLine(serverLog);

            // 2. Output to Browser Developer Console
            string safeMsg = HttpUtility.JavaScriptStringEncode(message);
            string safeDb = HttpUtility.JavaScriptStringEncode(dbName);
            string safeServer = HttpUtility.JavaScriptStringEncode(serverName);

            string script;
            if (isConnected)
            {
                script = $@"
                    console.log(
                        '%c[DATABASE STATUS: CONNECTED]%c Database: %c{safeDb}%c | Server: %c{safeServer}%c (%c{elapsedMs}ms%c) • {timestamp}',
                        'background: #166534; color: #ffffff; font-weight: bold; padding: 3px 8px; border-radius: 4px; font-size: 11px;',
                        'color: #374151; font-weight: bold; padding-left: 6px;',
                        'color: #0284c7; font-weight: bold;',
                        'color: #374151; font-weight: bold;',
                        'color: #7c3aed; font-weight: bold;',
                        'color: #6b7280; font-weight: normal;',
                        'color: #166534; font-weight: 600;',
                        'color: #6b7280; font-weight: normal;'
                    );
                    console.info('%c[Details]%c {safeMsg}', 'font-weight: bold; color: #4b5563;', 'color: #166534; padding-left: 4px;');
                ";
            }
            else
            {
                script = $@"
                    console.error(
                        '%c[DATABASE STATUS: FAILED]%c Database: %c{safeDb}%c | Server: %c{safeServer}%c (%c{elapsedMs}ms%c) • {timestamp}',
                        'background: #dc2626; color: #ffffff; font-weight: bold; padding: 3px 8px; border-radius: 4px; font-size: 11px;',
                        'color: #991b1b; font-weight: bold; padding-left: 6px;',
                        'color: #dc2626; font-weight: bold;',
                        'color: #991b1b; font-weight: bold;',
                        'color: #dc2626; font-weight: bold;',
                        'color: #6b7280; font-weight: normal;',
                        'color: #dc2626; font-weight: 600;',
                        'color: #6b7280; font-weight: normal;'
                    );
                    console.error('%c[Details]%c {safeMsg}', 'font-weight: bold; color: #991b1b;', 'color: #dc2626; padding-left: 4px;');
                ";
            }

            ClientScript.RegisterStartupScript(this.GetType(), "DbConnectionConsoleIndicator", script, true);
        }
    }
}
