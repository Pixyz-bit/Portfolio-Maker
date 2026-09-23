using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.Login
{
    public partial class Signup : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlError.Visible = false;
                pnlSuccess.Visible = false;
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Reset message panels
            pnlError.Visible = false;
            pnlSuccess.Visible = false;

            // 1. Instantiate and populate the dedicated UserLogin model
            UserLogin newUser = new UserLogin
            {
                FirstName = txtFirstName.Text.Trim(),
                LastName = txtLastName.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                Password = txtPassword.Text
            };

            string confirmPassword = txtConfirmPassword.Text;

            // 3. Delegate creation, validation, hashing, and transaction to UserRepository
            if (UserRepository.Create(newUser, confirmPassword, out string errorMessage))
            {
                // Directly redirect to Login.aspx
                Response.Redirect($"Login.aspx?registered=true&email={Server.UrlEncode(newUser.Email)}");
                return;
            }
            else
            {
                // Display error returned by repository
                ShowError(errorMessage);
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblErrorMessage.Text = message;
            ClientScript.RegisterStartupScript(this.GetType(), "SignupErrorLoading", "handleSignupError();", true);
        }
    }
}
