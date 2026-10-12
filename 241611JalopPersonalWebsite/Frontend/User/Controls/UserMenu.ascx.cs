using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Backend.Common;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.User.Controls
{
    public partial class UserMenu : UserControl
    {
        public bool IsCurrentPortfolioPublic
        {
            get => ViewState["IsCurrentPortfolioPublic"] as bool? ?? true;
            set => ViewState["IsCurrentPortfolioPublic"] = value;
        }

        public int CurrentTargetUserId
        {
            get => ViewState["CurrentTargetUserId"] as int? ?? 0;
            set => ViewState["CurrentTargetUserId"] = value;
        }

        public void BindUser(UserProfile profile, string email, bool canEditPortfolio = true, bool canEditAccount = true, int targetUserId = 0)
        {
            int currentUserId = (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int sId)) ? sId : 0;
            int activeTargetId = targetUserId > 0 ? targetUserId : currentUserId;
            CurrentTargetUserId = activeTargetId;

            if (profile != null)
            {
                litFullName.Text = !string.IsNullOrWhiteSpace(profile.FullName) ? profile.FullName : "User";
                litEmail.Text = !string.IsNullOrWhiteSpace(profile.ContactEmail) ? profile.ContactEmail : (email ?? string.Empty);

                if (!string.IsNullOrWhiteSpace(profile.ProfileImagePath))
                {
                    imgAvatar.ImageUrl = ResolveUrl(profile.ProfileImagePath);
                }
            }
            else
            {
                litFullName.Text = !string.IsNullOrWhiteSpace(Session["FullName"]?.ToString()) ? Session["FullName"].ToString() : "Welcome";
                litEmail.Text = email ?? Session["UserEmail"]?.ToString() ?? string.Empty;
            }

            // Pre-populate Edit Account modal fields if not postback
            if (!IsPostBack)
            {
                txtAccountFirstName.Text = profile?.FirstName ?? Session["FirstName"]?.ToString() ?? string.Empty;
                txtAccountLastName.Text = profile?.LastName ?? Session["LastName"]?.ToString() ?? string.Empty;
                txtAccountEmail.Text = !string.IsNullOrWhiteSpace(profile?.ContactEmail) 
                    ? profile.ContactEmail 
                    : (email ?? Session["UserEmail"]?.ToString() ?? string.Empty);
            }

            bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);
            phAdminOnlyAccountFields.Visible = isAdmin;

            // Configure Role Tag
            lblRoleBadge.Text = isAdmin ? "Admin" : "Owner";
            lblRoleBadge.CssClass = isAdmin ? "menu-role-tag badge-admin" : "menu-role-tag badge-user";

            // Configure Portfolio Visibility
            bool isPublic = true;
            if (profile != null)
            {
                isPublic = profile.IsPublic;
            }
            else if (activeTargetId > 0)
            {
                UserProfile targetProf = UserProfileRepository.GetByUserId(activeTargetId, out _);
                if (targetProf != null) isPublic = targetProf.IsPublic;
            }
            IsCurrentPortfolioPublic = isPublic;

            litVisibilityLabel.Text = isPublic ? "Public Portfolio" : "Private Portfolio";
            litVisibilityAction.Text = isPublic ? "Make Private" : "Make Public";
            btnToggleVisibility.ToolTip = isPublic ? "Click to make your portfolio private" : "Click to make your portfolio public";
            dotVisibility.Attributes["class"] = isPublic ? "status-indicator-dot dot-public" : "status-indicator-dot dot-private";

            if (!IsPostBack)
            {
                chkAccountIsPublic.Checked = isPublic;
            }

            if (isAdmin)
            {
                lnkDashboard.Visible = true;
                lnkDashboard.NavigateUrl = "~/Frontend/Admin/Dashboard.aspx";
                litDashboardLabel.Text = "Admin Dashboard";
                ddlAccountRole.SelectedValue = "Admin";
                ddlAccountRole.Enabled = true;
                chkAccountIsActive.Enabled = true;
            }
            else
            {
                lnkDashboard.Visible = false;
                ddlAccountRole.SelectedValue = "User";
                ddlAccountRole.Enabled = false;
                chkAccountIsActive.Enabled = false;
            }

            phEditAccountBtn.Visible = canEditAccount;
            lnkEditPortfolio.Visible = canEditPortfolio;

            if (targetUserId > 0 && targetUserId != currentUserId && isAdmin)
            {
                string targetToken = UrlObfuscator.EncodeUserId(targetUserId);
                lnkEditPortfolio.NavigateUrl = $"~/Frontend/User/Onboarding.aspx?u={targetToken}";
                litEditPortfolioLabel.Text = "Edit User's Portfolio";
                lnkViewPortfolio.NavigateUrl = $"~/Frontend/User/Portfolio.aspx?u={targetToken}";
                litViewPortfolioLabel.Text = "View User's Portfolio";
            }
            else
            {
                lnkEditPortfolio.NavigateUrl = "~/Frontend/User/Onboarding.aspx";
                litEditPortfolioLabel.Text = "Edit Portfolio";
                lnkViewPortfolio.NavigateUrl = "~/Frontend/User/Portfolio.aspx";
                litViewPortfolioLabel.Text = "View Portfolio";
            }

            lnkViewPortfolio.Visible = true;
            lnkEditDetails.Visible = false;
            lnkSignOut.NavigateUrl = "~/Frontend/Login/Login.aspx?action=logout";
        }

        protected void btnToggleVisibility_Click(object sender, EventArgs e)
        {
            int userId = CurrentTargetUserId;
            if (userId <= 0 && Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int sId))
            {
                userId = sId;
            }

            if (userId > 0)
            {
                bool newVisibility = !IsCurrentPortfolioPublic;
                if (UserProfileRepository.SetPortfolioVisibility(userId, newVisibility, out _))
                {
                    IsCurrentPortfolioPublic = newVisibility;
                    Response.Redirect(Request.RawUrl);
                }
            }
        }

        protected void btnSaveUserAccount_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || !int.TryParse(Session["UserID"].ToString(), out int userId))
            {
                Response.Redirect("~/Frontend/Login/Login.aspx");
                return;
            }

            string firstName = txtAccountFirstName.Text.Trim();
            string lastName = txtAccountLastName.Text.Trim();
            string email = txtAccountEmail.Text.Trim();
            string newPassword = txtAccountNewPassword.Text;
            string confirmPassword = txtAccountConfirmPassword.Text;

            bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);
            string role = isAdmin ? ddlAccountRole.SelectedValue : (Session["Role"]?.ToString() ?? "User");
            bool isActive = isAdmin ? chkAccountIsActive.Checked : true;

            if (string.IsNullOrWhiteSpace(firstName))
            {
                ShowModalAlert("First Name is required.", isError: true);
                return;
            }
            if (string.IsNullOrWhiteSpace(email))
            {
                ShowModalAlert("Email Address is required.", isError: true);
                return;
            }

            if (!string.IsNullOrEmpty(newPassword))
            {
                if (newPassword.Length < 6)
                {
                    ShowModalAlert("New password must be at least 6 characters.", isError: true);
                    return;
                }
                if (newPassword != confirmPassword)
                {
                    ShowModalAlert("New password and confirmation do not match.", isError: true);
                    return;
                }
            }

            if (UserRepository.AdminUpdateUser(userId, firstName, lastName, email, role, isActive, out string updateError))
            {
                if (!string.IsNullOrEmpty(newPassword))
                {
                    UserRepository.AdminResetPassword(userId, newPassword, out _);
                }

                Session["FirstName"] = firstName;
                Session["LastName"] = lastName;
                Session["FullName"] = $"{firstName} {lastName}".Trim();
                Session["UserEmail"] = email;
                Session["Email"] = email;
                if (isAdmin)
                {
                    Session["Role"] = role;
                }

                // Save portfolio visibility choice
                UserProfileRepository.SetPortfolioVisibility(userId, chkAccountIsPublic.Checked, out _);
                IsCurrentPortfolioPublic = chkAccountIsPublic.Checked;

                // Redirect to current page to reflect updated name and credentials everywhere
                Response.Redirect(Request.RawUrl);
            }
            else
            {
                ShowModalAlert("Failed to update account: " + updateError, isError: true);
            }
        }

        private void ShowModalAlert(string message, bool isError)
        {
            pnlUserAccountModalMsg.Visible = true;
            pnlUserAccountModalMsg.CssClass = isError ? "user-account-toast alert-danger" : "user-account-toast alert-success";
            pnlUserAccountModalMsg.Style.Clear();
            litUserAccountModalMsg.Text = message;

            // Keep modal open so the user sees the validation message, and auto-dismiss toast after 5s
            string script = "openUserAccountModal(); setTimeout(function() { var t = document.getElementById('" + pnlUserAccountModalMsg.ClientID + "'); if(t) t.style.display='none'; }, 5000);";
            ScriptManager.RegisterStartupScript(this.Page, this.GetType(), "OpenUserAccountModalOnError", script, true);
        }
    }
}
