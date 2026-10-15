using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using _241611JalopPersonalWebsite.Backend.Common;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.Admin
{
    public partial class Dashboard : SecurePage
    {
        protected override bool RequiresAdmin => true;
        private const int UserPageSize = 12;
        private int UserPage { get => (int?)ViewState["UserPage"] ?? 1; set => ViewState["UserPage"] = value; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security verification: Ensure authenticated session has Admin role
            if (Session["UserID"] == null || !string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Frontend/Login/Login.aspx");
                return;
            }

            int currentAdminId = Convert.ToInt32(Session["UserID"]);
            UserProfile adminProfile = UserProfileRepository.GetByUserId(currentAdminId, out _);
            string adminEmail = Session["UserEmail"]?.ToString() ?? Session["Email"]?.ToString() ?? string.Empty;
            ucUserMenu.BindUser(adminProfile, adminEmail);

            if (!IsPostBack)
            {
                litAdminName.Text = Server.HtmlEncode((adminProfile != null && !string.IsNullOrWhiteSpace(adminProfile.FullName))
                    ? adminProfile.FullName
                    : (!string.IsNullOrWhiteSpace(Session["FullName"]?.ToString()) ? Session["FullName"].ToString() : "Administrator"));

                LoadAnalytics();
                LoadUsers();
            }
        }

        private void LoadAnalytics()
        {
            // Query analytics using DashboardAnalyticsRepository and DashboardAnalytics model
            DashboardAnalytics stats = DashboardAnalyticsRepository.GetDashboardAnalytics(out string error);

            if (string.IsNullOrEmpty(error))
            {
                litTotalUsers.Text = stats.TotalUsers.ToString("N0");
                litTotalActive.Text = stats.TotalActive.ToString("N0");
                litTotalInactive.Text = stats.TotalInactive.ToString("N0");
            }
            else
            {
                ShowError("Failed to fetch system metrics: " + error);
            }
        }

        private void LoadUsers()
        {
            string search = txtSearch.Text.Trim();
            string status = ddlStatusFilter.SelectedValue;
            string role = ddlRoleFilter.SelectedValue;

            List<UserLogin> users = UserRepository.GetUsersPage(search, status, role, UserPage, UserPageSize, out int total, out string error);
            int pages = Math.Max(1, (total + UserPageSize - 1) / UserPageSize);
            UserPage = Math.Max(1, Math.Min(UserPage, pages));
            litUsersPage.Text = $"Page {UserPage} of {pages} · {total} accounts";
            btnPreviousUsers.Enabled = UserPage > 1;
            btnNextUsers.Enabled = UserPage < pages;
            pnlUsersPagination.Visible = string.IsNullOrEmpty(error) && total > UserPageSize;
            bool filtered = search.Length > 0 || status.Length > 0 || role.Length > 0;
            litNoUsersTitle.Text = filtered ? "No accounts match your search" : "No user accounts yet";
            litNoUsersDescription.Text = filtered ? "Try a different name or email, or reset the filters." : "Create an account to get started.";

            if (string.IsNullOrEmpty(error))
            {
                rptUsers.DataSource = users;
                rptUsers.DataBind();

                pnlNoUsers.Visible = (users == null || users.Count == 0);
            }
            else
            {
                ShowError("Error loading user records: " + error);
                rptUsers.DataSource = null;
                rptUsers.DataBind();
                pnlNoUsers.Visible = false;
            }
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            ClearBanners();
            UserPage = 1;
            LoadUsers();
        }

        protected void btnResetFilter_Click(object sender, EventArgs e)
        {
            ClearBanners();
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            ddlRoleFilter.SelectedIndex = 0;
            UserPage = 1;
            LoadUsers();
        }

        protected void btnPreviousUsers_Click(object sender, EventArgs e) { ClearBanners(); UserPage=Math.Max(1,UserPage-1); LoadUsers(); }
        protected void btnNextUsers_Click(object sender, EventArgs e) { ClearBanners(); UserPage++; LoadUsers(); }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            ClearBanners();

            if (string.Equals(e.CommandName, "ViewSummary", StringComparison.OrdinalIgnoreCase))
            {
                if (int.TryParse(e.CommandArgument?.ToString(), out int targetUserId))
                {
                    LoadUserSummary(targetUserId);
                }
            }
            else if (string.Equals(e.CommandName, "ToggleStatus", StringComparison.OrdinalIgnoreCase))
            {
                string[] parts = (e.CommandArgument?.ToString() ?? string.Empty).Split('|');
                if (parts.Length == 2 && int.TryParse(parts[0], out int targetUserId) && bool.TryParse(parts[1], out bool currentStatus))
                {
                    // Check if administrator is trying to deactivate their own logged in account
                    int currentAdminId = Convert.ToInt32(Session["UserID"]);
                    if (targetUserId == currentAdminId && currentStatus)
                    {
                        ShowError("You cannot deactivate your own administrative account while logged in.");
                        return;
                    }

                    bool newStatus = !currentStatus;
                    if (UserRepository.ToggleUserStatus(targetUserId, newStatus, out string error))
                    {
                        ShowSuccess($"Account #{targetUserId} successfully {(newStatus ? "Activated" : "Deactivated")}.");
                        LoadAnalytics();
                        LoadUsers();

                        // If summary modal is open for this user, refresh it
                        if (pnlUserSummaryModal.Visible && hfSummaryUserId.Value == targetUserId.ToString())
                        {
                            LoadUserSummary(targetUserId);
                        }
                    }
                    else
                    {
                        ShowError("Could not update account status: " + error);
                    }
                }
            }
            else if (string.Equals(e.CommandName, "DeleteUser", StringComparison.OrdinalIgnoreCase))
            {
                if (int.TryParse(e.CommandArgument?.ToString(), out int targetUserId))
                {
                    int currentAdminId = Convert.ToInt32(Session["UserID"]);
                    if (targetUserId == currentAdminId)
                    {
                        ShowError("Action aborted: You cannot delete the account you are currently logged in with.");
                        return;
                    }

                    if (UserRepository.DeleteUser(targetUserId, out string error, Server.MapPath("~/")))
                    {
                        ShowSuccess("User account and related portfolio records were deleted successfully.");
                        if (!string.IsNullOrEmpty(error)) ShowError(error);
                        if (pnlUserSummaryModal.Visible && hfSummaryUserId.Value == targetUserId.ToString())
                        {
                            pnlUserSummaryModal.Visible = false;
                        }
                        LoadAnalytics();
                        LoadUsers();
                    }
                    else
                    {
                        ShowError("Error deleting user: " + error);
                    }
                }
            }
        }

        private void LoadUserSummary(int userId)
        {
            UserSummaryData summary;
            try { summary = PortfolioReadRepository.LoadSummary(userId); }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Account summary failed: {0}", ex);
                pnlUserSummaryModal.Visible = false;
                ShowError("The account summary could not be loaded. Select the account to try again.");
                return;
            }
            if (summary == null)
            { pnlUserSummaryModal.Visible=false; ShowError("This account no longer exists. Refresh the directory and try again."); return; }
            UserLogin user = summary.User;
            UserProfile profile = summary.Portfolio.Profile;
            var educations = summary.Portfolio.Educations;
            var skills = summary.Portfolio.Skills;
            var hobbies = summary.Portfolio.Hobbies;
            var affiliations = summary.Portfolio.Affiliations;
            var socialLinks = summary.Portfolio.SocialLinks;

            // 4. Bind Header Details
            hfSummaryUserId.Value = userId.ToString();
            hfSummaryCurrentStatus.Value = user.IsActive.ToString().ToLower();
            hfSummaryFirstName.Value = user.FirstName ?? string.Empty;
            hfSummaryLastName.Value = user.LastName ?? string.Empty;
            hfSummaryEmailRaw.Value = user.Email ?? string.Empty;
            hfSummaryRoleRaw.Value = user.Role ?? "User";
            litSummaryUserId.Text = userId.ToString();
            litSummaryFullName.Text = Server.HtmlEncode(!string.IsNullOrWhiteSpace(user.FullName) ? user.FullName : user.Email);
            litSummaryEmail.Text = Server.HtmlEncode(user.Email);
            litSummaryCreatedAt.Text = FormatPhilippineTimeTwoRows(user.CreatedAt);
            litSummaryAvatarInitials.Text = Server.HtmlEncode(GetInitials(user.FirstName, user.LastName, user.Email));

            bool isAdmin = string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase);
            litSummaryRoleBadge.Text = $"<span class='badge {(isAdmin ? "badge-admin" : "badge-user")}'>{user.Role}</span>";
            litSummaryStatusBadge.Text = $"<span class='badge {(user.IsActive ? "badge-active" : "badge-inactive")}'><span class='status-dot'></span>{(user.IsActive ? "Active" : "Deactivated")}</span>";

            // 5. Bind Personal Details
            if (profile != null)
            {
                litSummaryContactEmail.Text = Server.HtmlEncode(!string.IsNullOrWhiteSpace(profile.ContactEmail) ? profile.ContactEmail : user.Email);
                litSummaryContactNum.Text = Server.HtmlEncode(!string.IsNullOrWhiteSpace(profile.ContactNum) ? profile.ContactNum : "None specified");
                litSummaryAddress.Text = Server.HtmlEncode(!string.IsNullOrWhiteSpace(profile.Address) ? profile.Address : "None specified");
                
                if (profile.Birthday.HasValue)
                {
                    int age = DateTime.Today.Year - profile.Birthday.Value.Year;
                    if (profile.Birthday.Value.Date > DateTime.Today.AddYears(-age)) age--;
                    litSummaryBirthday.Text = $"{profile.Birthday.Value:dd MMM yyyy} ({age} years old)";
                }
                else
                {
                    litSummaryBirthday.Text = "Not specified";
                }

                litSummaryBio.Text = !string.IsNullOrWhiteSpace(profile.Description) ? Server.HtmlEncode(profile.Description) : "No personal biography provided.";
            }
            else
            {
                litSummaryContactEmail.Text = Server.HtmlEncode(user.Email);
                litSummaryContactNum.Text = Server.HtmlEncode("None specified");
                litSummaryAddress.Text = Server.HtmlEncode("None specified");
                litSummaryBirthday.Text = "Not specified";
                litSummaryBio.Text = "Profile has not yet been initialized.";
            }

            // 6. Bind Count Statistics
            litSummaryEduCount.Text = educations.Count.ToString();
            litSummarySkillCount.Text = skills.Count.ToString();
            litSummaryHobbyCount.Text = hobbies.Count.ToString();
            litSummaryAffilCount.Text = affiliations.Count.ToString();
            litSummarySocialCount.Text = socialLinks.Count.ToString();

            // 7. Bind Repeaters
            rptSummaryEducations.DataSource = educations;
            rptSummaryEducations.DataBind();
            lblNoEducations.Visible = (educations.Count == 0);

            rptSummaryAffiliations.DataSource = affiliations;
            rptSummaryAffiliations.DataBind();
            lblNoAffiliations.Visible = (affiliations.Count == 0);

            rptSummarySkills.DataSource = skills;
            rptSummarySkills.DataBind();
            lblNoSkills.Visible = (skills.Count == 0);

            rptSummaryHobbies.DataSource = hobbies;
            rptSummaryHobbies.DataBind();
            lblNoHobbies.Visible = (hobbies.Count == 0);

            rptSummarySocialLinks.DataSource = socialLinks;
            rptSummarySocialLinks.DataBind();
            lblNoSocialLinks.Visible = (socialLinks.Count == 0);

            // 8. Bind Actions
            string targetToken = UrlObfuscator.EncodeUserId(userId);
            lnkSummaryPortfolio.NavigateUrl = $"~/Frontend/User/Portfolio.aspx?u={targetToken}";
            lnkSummaryEditPortfolio.NavigateUrl = $"~/Frontend/User/Onboarding.aspx?u={targetToken}";

            if (user.IsActive)
            {
                litSummaryStatusBtnText.Text = "Deactivate";
                btnSummaryStatusTrigger.Attributes["class"] = "btn btn-danger btn-sm";
            }
            else
            {
                litSummaryStatusBtnText.Text = "Activate";
                btnSummaryStatusTrigger.Attributes["class"] = "btn btn-success btn-sm";
            }

            // Open modal
            pnlUserSummaryModal.Visible = true;
        }

        protected void btnConfirmStatusAction_Click(object sender, EventArgs e)
        {
            ClearBanners();

            if (int.TryParse(hfStatusUserId.Value, out int targetUserId) && bool.TryParse(hfStatusNewState.Value, out bool newStatus))
            {
                int currentAdminId = Convert.ToInt32(Session["UserID"]);
                if (targetUserId == currentAdminId && !newStatus)
                {
                    ShowError("Action aborted: You cannot deactivate your own administrative account while logged in.");
                    return;
                }

                if (UserRepository.ToggleUserStatus(targetUserId, newStatus, out string error))
                {
                    ShowSuccess($"User account #{targetUserId} successfully {(newStatus ? "Activated" : "Deactivated")}.");
                    LoadAnalytics();
                    LoadUsers();

                    // If summary modal is open for this user, refresh it
                    if (pnlUserSummaryModal.Visible && hfSummaryUserId.Value == targetUserId.ToString())
                    {
                        LoadUserSummary(targetUserId);
                    }
                }
                else
                {
                    ShowError("Could not update account status: " + error);
                }
            }
        }

        protected void btnConfirmDeleteUser_Click(object sender, EventArgs e)
        {
            ClearBanners();

            if (int.TryParse(hfDeleteUserId.Value, out int targetUserId))
            {
                int currentAdminId = Convert.ToInt32(Session["UserID"]);
                if (targetUserId == currentAdminId)
                {
                    ShowError("Action aborted: You cannot delete the account you are currently logged in with.");
                    return;
                }

                if (UserRepository.DeleteUser(targetUserId, out string error, Server.MapPath("~/")))
                {
                    ShowSuccess("User account and related portfolio records were deleted successfully.");
                        if (!string.IsNullOrEmpty(error)) ShowError(error);
                    if (pnlUserSummaryModal.Visible && hfSummaryUserId.Value == targetUserId.ToString())
                    {
                        pnlUserSummaryModal.Visible = false;
                    }
                    LoadAnalytics();
                    LoadUsers();
                }
                else
                {
                    ShowError("Error deleting user: " + error);
                }
            }
        }

        protected void btnCloseSummary_Click(object sender, EventArgs e)
        {
            pnlUserSummaryModal.Visible = false;
        }

        protected void btnSaveNewUser_Click(object sender, EventArgs e)
        {
            ClearBanners();

            string firstName = txtAddFirstName.Text.Trim();
            string lastName = txtAddLastName.Text.Trim();
            string email = txtAddEmail.Text.Trim();
            string password = txtAddPassword.Text;
            string role = ddlAddRole.SelectedValue;
            bool isActive = chkAddIsActive.Checked;

            if (UserRepository.AdminCreateUser(firstName, lastName, email, password, role, isActive, out string error))
            {
                ShowSuccess($"User account '{email}' created successfully as {role}.");
                txtAddFirstName.Text = string.Empty;
                txtAddLastName.Text = string.Empty;
                txtAddEmail.Text = string.Empty;
                txtAddPassword.Text = string.Empty;
                ddlAddRole.SelectedIndex = 0;
                chkAddIsActive.Checked = true;

                LoadAnalytics();
                LoadUsers();
            }
            else
            {
                ShowAccountFormError(false, error);
            }
        }

        protected void btnUpdateUser_Click(object sender, EventArgs e)
        {
            ClearBanners();

            if (!int.TryParse(hfEditUserId.Value, out int userId) || userId <= 0)
            {
                ShowAccountFormError(true, "Invalid user selected for update. Close this form and select the account again.");
                return;
            }

            string firstName = txtEditFirstName.Text.Trim();
            string lastName = txtEditLastName.Text.Trim();
            string email = txtEditEmail.Text.Trim();
            string role = ddlEditRole.SelectedValue;
            bool isActive = chkEditIsActive.Checked;

            int currentAdminId = Convert.ToInt32(Session["UserID"]);
            if (userId == currentAdminId && !isActive)
            {
                ShowAccountFormError(true, "You cannot deactivate your own active session.");
                return;
            }

            string newPassword = txtEditNewPassword.Text;
            string confirmPassword = txtEditConfirmPassword.Text;
            bool passwordChanged = !string.IsNullOrEmpty(newPassword);
            if (passwordChanged && newPassword.Length < 6)
            { ShowAccountFormError(true, "New password must be at least 6 characters."); return; }
            if (newPassword != confirmPassword)
            { ShowAccountFormError(true, "New password and confirmation do not match."); return; }
            if (!UserRepository.AdminUpdateUser(userId, firstName, lastName, email, role, isActive, out string error, newPassword))
            { ShowAccountFormError(true, error); return; }

            string successMsg = passwordChanged
                ? $"User #{userId} ({email}) and password updated successfully."
                : $"User #{userId} ({email}) updated successfully.";

            ShowSuccess(successMsg);
            LoadAnalytics();
            LoadUsers();
            if (pnlUserSummaryModal.Visible && hfSummaryUserId.Value == userId.ToString())
            {
                LoadUserSummary(userId);
            }
        }

        public string GetInitials(string firstName, string lastName, string email)
        {
            string f = !string.IsNullOrWhiteSpace(firstName) ? firstName.Trim().Substring(0, 1).ToUpper() : string.Empty;
            string l = !string.IsNullOrWhiteSpace(lastName) ? lastName.Trim().Substring(0, 1).ToUpper() : string.Empty;

            if (!string.IsNullOrEmpty(f) || !string.IsNullOrEmpty(l))
            {
                return (f + l);
            }

            if (!string.IsNullOrWhiteSpace(email))
            {
                return email.Trim().Substring(0, 1).ToUpper();
            }

            return "U";
        }

        public static string FormatPeriod(object startYear, object endYear)
        {
            string start = startYear?.ToString()?.Trim();
            string end = endYear?.ToString()?.Trim();

            if (string.IsNullOrEmpty(start) && string.IsNullOrEmpty(end))
                return string.Empty;

            if (string.IsNullOrEmpty(end))
                return $"{start} - Present";

            if (string.IsNullOrEmpty(start))
                return end;

            return $"{start} - {end}";
        }

        public static string EncodeScriptAttribute(string value) => System.Web.HttpUtility.HtmlAttributeEncode(System.Web.HttpUtility.JavaScriptStringEncode(value ?? string.Empty)).Replace("'", "&#39;");

        public static string FormatSocialUrl(object rawUrl) => InputSafety.SafeWebUrl(rawUrl);


        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            lblSuccessMessage.Text = Server.HtmlEncode(message);
            pnlError.Visible = false;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblErrorMessage.Text = Server.HtmlEncode(message);
            pnlSuccess.Visible = false;
        }

        private void ClearBanners()
        {
            pnlSuccess.Visible = false;
            pnlError.Visible = false;
            pnlAddError.Visible = false;
            pnlEditError.Visible = false;
            foreach (TextBox field in new[] {txtAddFirstName,txtAddLastName,txtAddEmail,txtAddPassword,txtEditFirstName,txtEditLastName,txtEditEmail,txtEditNewPassword,txtEditConfirmPassword})
            { field.Attributes.Remove("aria-invalid"); field.Attributes.Remove("aria-describedby"); }
        }

        private void ShowAccountFormError(bool editing, string message)
        {
            var panel = editing ? pnlEditError : pnlAddError;
            var literal = editing ? litEditError : litAddError;
            panel.Visible = true;
            literal.Text = Server.HtmlEncode(message);
            string compact = message.Replace(" ", "").ToLowerInvariant();
            TextBox field = compact.Contains("firstname") ? (editing ? txtEditFirstName : txtAddFirstName) :
                compact.Contains("lastname") ? (editing ? txtEditLastName : txtAddLastName) :
                compact.Contains("email") ? (editing ? txtEditEmail : txtAddEmail) :
                compact.Contains("password") ? (editing ? txtEditNewPassword : txtAddPassword) : null;
            if (field != null) { field.Attributes["aria-invalid"]="true"; field.Attributes["aria-describedby"]=panel.ClientID; }
            string script = "document.getElementById('" + (editing ? "editModal" : "addModal") + "').classList.add('active');";
            ClientScript.RegisterStartupScript(GetType(), "RestoreAccountForm", script, true);
        }

        private static readonly TimeZoneInfo PhilippineTimeZone = GetPhilippineTimeZone();

        private static TimeZoneInfo GetPhilippineTimeZone()
        {
            string[] candidates = { "Singapore Standard Time", "Asia/Manila", "Taipei Standard Time", "China Standard Time" };
            foreach (var id in candidates)
            {
                try
                {
                    return TimeZoneInfo.FindSystemTimeZoneById(id);
                }
                catch { }
            }
            return TimeZoneInfo.CreateCustomTimeZone("Philippine Standard Time", TimeSpan.FromHours(8), "Philippine Standard Time", "Philippine Standard Time");
        }

        public static string FormatPhilippineTime(object dateTimeObj, string format = "dd MMM yyyy, hh:mm tt")
        {
            if (dateTimeObj == null || dateTimeObj == DBNull.Value) return string.Empty;
            if (DateTime.TryParse(dateTimeObj.ToString(), out DateTime dt))
            {
                DateTime utc = dt.Kind == DateTimeKind.Utc ? dt : DateTime.SpecifyKind(dt, DateTimeKind.Utc);
                return TimeZoneInfo.ConvertTimeFromUtc(utc, PhilippineTimeZone).ToString(format);
            }
            return string.Empty;
        }

        public static string FormatPhilippineTimeTwoRows(object dateTimeObj)
        {
            if (dateTimeObj == null || dateTimeObj == DBNull.Value) return string.Empty;
            if (DateTime.TryParse(dateTimeObj.ToString(), out DateTime dt))
            {
                DateTime utc = dt.Kind == DateTimeKind.Utc ? dt : DateTime.SpecifyKind(dt, DateTimeKind.Utc);
                DateTime ph = TimeZoneInfo.ConvertTimeFromUtc(utc, PhilippineTimeZone);
                return $"<div style='line-height: 1.35;'><span style='font-weight: 700; color: #000000; display: block;'>{ph:dd MMM yyyy}</span><span style='font-size: 0.78rem; color: #64748b; display: block;'>{ph:hh:mm tt}</span></div>";
            }
            return string.Empty;
        }
    }
}
