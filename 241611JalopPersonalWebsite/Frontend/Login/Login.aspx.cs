using System;
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

                // 4. Show success and redirect immediately to Portfolio
                pnlSuccess.Visible = true;
                lblSuccessMessage.Text = $"Welcome back, {authenticatedUser.FirstName}! Login successful. Redirecting to your portfolio...";

                string redirectScript = $"setTimeout(function(){{ window.location.href = '../User/Portfolio.aspx?userId={authenticatedUser.UserID}'; }}, 1000);";
                ClientScript.RegisterStartupScript(this.GetType(), "LoginRedirect", redirectScript, true);
            }
            else
            {
                // Display exact error message from repository
                pnlError.Visible = true;
                lblErrorMessage.Text = errorMessage;
            }
        }
    }
}
