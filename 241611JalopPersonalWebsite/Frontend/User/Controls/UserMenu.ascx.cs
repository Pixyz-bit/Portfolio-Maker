using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Frontend.User.Controls
{
    public partial class UserMenu : UserControl
    {
        public void BindUser(UserProfile profile, string email)
        {
            if (profile != null)
            {
                litFullName.Text = !string.IsNullOrWhiteSpace(profile.FullName) ? profile.FullName : "User";
                litEmail.Text = !string.IsNullOrWhiteSpace(profile.ContactEmail) ? profile.ContactEmail : (email ?? string.Empty);
                litBio.Text = !string.IsNullOrWhiteSpace(profile.Description) ? Server.HtmlEncode(profile.Description) : "No bio provided yet.";

                if (!string.IsNullOrWhiteSpace(profile.ProfileImagePath))
                {
                    imgAvatar.ImageUrl = ResolveUrl(profile.ProfileImagePath);
                }

                lnkViewPortfolio.NavigateUrl = $"~/Frontend/User/Portfolio.aspx?userId={profile.UserID}";
            }
            else
            {
                litFullName.Text = "Welcome";
                litEmail.Text = email ?? string.Empty;
                litBio.Text = "No bio provided yet.";
                lnkViewPortfolio.NavigateUrl = "~/Frontend/User/Portfolio.aspx";
            }

            lnkEditDetails.NavigateUrl = "~/Frontend/User/Onboarding.aspx";
            lnkSignOut.NavigateUrl = "~/Frontend/Login/Login.aspx?action=logout";

            bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);
            if (isAdmin)
            {
                lnkDashboard.NavigateUrl = "~/Frontend/Admin/Dashboard.aspx";
                lnkDashboard.Text = "Admin Dashboard";
                lnkDashboard.Visible = true;
                lnkEditDetails.Visible = true;
                lnkEditDetails.Text = "Edit Onboarding Portfolio Details";
            }
            else
            {
                // User role: hide user dashboard button, replace with Edit Account
                lnkDashboard.NavigateUrl = "~/Frontend/User/Onboarding.aspx";
                lnkDashboard.Text = "Edit Account";
                lnkDashboard.Visible = true;
                lnkEditDetails.Visible = false;
            }
        }
    }
}
