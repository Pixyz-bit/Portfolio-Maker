using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using _241611JalopPersonalWebsite.Backend.Common;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.Admin
{
    public partial class Dashboard : Page
    {
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
                litAdminName.Text = (adminProfile != null && !string.IsNullOrWhiteSpace(adminProfile.FullName))
                    ? adminProfile.FullName
                    : (!string.IsNullOrWhiteSpace(Session["FullName"]?.ToString()) ? Session["FullName"].ToString() : "Administrator");

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

            List<UserLogin> users = UserRepository.GetAllUsers(search, status, role, out string error);

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
                pnlNoUsers.Visible = true;
            }
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            ClearBanners();
            LoadUsers();
        }

        protected void btnResetFilter_Click(object sender, EventArgs e)
        {
            ClearBanners();
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            ddlRoleFilter.SelectedIndex = 0;
            LoadUsers();
        }

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

                    if (UserRepository.DeleteUser(targetUserId, out string error))
                    {
                        ShowSuccess("User account and related portfolio records were deleted successfully.");
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
            // 1. Fetch user credentials & role
            UserLogin user = UserRepository.GetUserById(userId, out string userErr);
            if (user == null)
            {
                ShowError("Could not locate user #" + userId + ": " + userErr);
                return;
            }

            // 2. Fetch user profile
            UserProfile profile = UserProfileRepository.GetByUserId(userId, out _);

            // 3. Fetch related section models
            List<Education> educations = EducationRepository.GetByUserId(userId, out _) ?? new List<Education>();
            List<Skill> skills = SkillRepository.GetByUserId(userId, out _) ?? new List<Skill>();
            List<Hobby> hobbies = HobbyRepository.GetByUserId(userId, out _) ?? new List<Hobby>();
            List<Affiliation> affiliations = AffiliationRepository.GetByUserId(userId, out _) ?? new List<Affiliation>();
            List<SocialLink> socialLinks = SocialLinkRepository.GetByUserId(userId, out _) ?? new List<SocialLink>();

            // 4. Bind Header Details
            hfSummaryUserId.Value = userId.ToString();
            hfSummaryCurrentStatus.Value = user.IsActive.ToString().ToLower();
            hfSummaryFirstName.Value = user.FirstName ?? string.Empty;
            hfSummaryLastName.Value = user.LastName ?? string.Empty;
            hfSummaryEmailRaw.Value = user.Email ?? string.Empty;
            hfSummaryRoleRaw.Value = user.Role ?? "User";
            litSummaryUserId.Text = userId.ToString();
            litSummaryFullName.Text = !string.IsNullOrWhiteSpace(user.FullName) ? user.FullName : user.Email;
            litSummaryEmail.Text = user.Email;
            litSummaryCreatedAt.Text = FormatPhilippineTime(user.CreatedAt);
            litSummaryAvatarInitials.Text = GetInitials(user.FirstName, user.LastName, user.Email);

            bool isAdmin = string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase);
            litSummaryRoleBadge.Text = $"<span class='badge {(isAdmin ? "badge-admin" : "badge-user")}'>{user.Role}</span>";
            litSummaryStatusBadge.Text = $"<span class='badge {(user.IsActive ? "badge-active" : "badge-inactive")}'><span class='status-dot'></span>{(user.IsActive ? "Active" : "Deactivated")}</span>";

            // 5. Bind Personal Details
            if (profile != null)
            {
                litSummaryContactEmail.Text = !string.IsNullOrWhiteSpace(profile.ContactEmail) ? profile.ContactEmail : user.Email;
                litSummaryContactNum.Text = !string.IsNullOrWhiteSpace(profile.ContactNum) ? profile.ContactNum : "None specified";
                litSummaryAddress.Text = !string.IsNullOrWhiteSpace(profile.Address) ? profile.Address : "None specified";
                
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
                litSummaryContactEmail.Text = user.Email;
                litSummaryContactNum.Text = "None specified";
                litSummaryAddress.Text = "None specified";
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
            lnkSummaryPortfolio.NavigateUrl = $"~/Frontend/User/Portfolio.aspx?u={UrlObfuscator.EncodeUserId(userId)}";

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

                if (UserRepository.DeleteUser(targetUserId, out string error))
                {
                    ShowSuccess("User account and related portfolio records were deleted successfully.");
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
                ShowError("Failed to create user: " + error);
            }
        }

        protected void btnUpdateUser_Click(object sender, EventArgs e)
        {
            ClearBanners();

            if (!int.TryParse(hfEditUserId.Value, out int userId) || userId <= 0)
            {
                ShowError("Invalid user selected for update.");
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
                ShowError("You cannot deactivate your own active session.");
                return;
            }

            if (!UserRepository.AdminUpdateUser(userId, firstName, lastName, email, role, isActive, out string error))
            {
                ShowError("Failed to update user: " + error);
                return;
            }

            // Check if password change was requested in the same modal
            string newPassword = txtEditNewPassword.Text;
            string confirmPassword = txtEditConfirmPassword.Text;
            bool passwordChanged = false;

            if (!string.IsNullOrWhiteSpace(newPassword))
            {
                if (newPassword.Length < 6)
                {
                    ShowError($"User details were updated, but password was not changed: Password must be at least 6 characters long.");
                    LoadAnalytics();
                    LoadUsers();
                    return;
                }

                if (newPassword != confirmPassword)
                {
                    ShowError($"User details were updated, but password was not changed: Passwords do not match.");
                    LoadAnalytics();
                    LoadUsers();
                    return;
                }

                if (UserRepository.AdminResetPassword(userId, newPassword, out string pwdError))
                {
                    passwordChanged = true;
                }
                else
                {
                    ShowError($"User details were updated, but password could not be reset: {pwdError}");
                    LoadAnalytics();
                    LoadUsers();
                    return;
                }
            }

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

        public static string FormatSocialUrl(object rawUrl)
        {
            string url = rawUrl?.ToString()?.Trim() ?? string.Empty;
            if (string.IsNullOrEmpty(url)) return "#";
            if (!url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) && !url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                return "https://" + url;
            }
            return url;
        }

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            lblSuccessMessage.Text = message;
            pnlError.Visible = false;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblErrorMessage.Text = message;
            pnlSuccess.Visible = false;
        }

        private void ClearBanners()
        {
            pnlSuccess.Visible = false;
            pnlError.Visible = false;
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
    }
}
