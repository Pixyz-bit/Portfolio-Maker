using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using System.Web.UI;
using _241611JalopPersonalWebsite.Backend.Common;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.User
{
    public partial class Onboarding : SecurePage
    {
        protected override bool RequiresLogin => true;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify user authentication and resolve target user
            int userId = GetCurrentUserId();
            if (userId <= 0)
            {
                Response.Redirect("~/Frontend/Login/Login.aspx?msg=Please+sign+in+to+access+onboarding");
                return;
            }

            int loggedInUserId = (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int lid)) ? lid : 0;
            bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);

            if (!IsPostBack)
            {
                pnlError.Visible = false;
                pnlSuccess.Visible = false;
                hfTargetUserId.Value = userId.ToString();

                if (isAdmin && userId != loggedInUserId)
                {
                    UserProfile targetProfile = UserProfileRepository.GetByUserId(userId, out _);
                    UserLogin targetUser = UserRepository.GetUserById(userId, out _);
                    string targetName = (targetProfile != null && !string.IsNullOrWhiteSpace(targetProfile.FullName))
                        ? targetProfile.FullName
                        : ((targetUser != null && !string.IsNullOrWhiteSpace(targetUser.FullName))
                            ? targetUser.FullName
                            : $"User #{userId}");

                    mainCard.Attributes["class"] = "card card-admin-editing";
                    pnlAdminBadge.Visible = true;
                    lnkReturnToAdmin.Visible = true;
                    litAdminTargetUserName.Text = Server.HtmlEncode(targetName);
                    litPageTitle.Text = Server.HtmlEncode($"Edit Portfolio: {targetName}");
                    litPageSubtitle.Text = "You are editing this user's live portfolio information with Administrator authority.";
                }
                else
                {
                    mainCard.Attributes["class"] = "card";
                    pnlAdminBadge.Visible = false;
                    lnkReturnToAdmin.Visible = false;
                    litPageTitle.Text = "Profile Onboarding";
                    litPageSubtitle.Text = "Fill in your information at your own pace. Save & Exit anytime to view your portfolio.";
                }

                string backUrl;
                if (isAdmin && userId != loggedInUserId)
                {
                    backUrl = ResolveUrl("~/Frontend/Admin/Dashboard.aspx");
                }
                else if (isAdmin)
                {
                    backUrl = ResolveUrl("~/Frontend/Admin/Dashboard.aspx");
                }
                else
                {
                    string targetToken = UrlObfuscator.EncodeUserId(userId);
                    backUrl = ResolveUrl($"~/Frontend/User/Portfolio.aspx?u={targetToken}");
                }

                lnkBackStep1.NavigateUrl = backUrl;

                // Load existing profile and portfolio data into form
                LoadExistingData(userId);
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] == null || !int.TryParse(Session["UserID"].ToString(), out int loggedInUserId) || loggedInUserId <= 0)
            {
                return 0;
            }

            bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);

            if (isAdmin)
            {
                // Check hidden field first on postback
                if (!string.IsNullOrWhiteSpace(hfTargetUserId.Value) && int.TryParse(hfTargetUserId.Value, out int hfId) && hfId > 0)
                {
                    return hfId;
                }

                // Check obfuscated token ?u=...
                string token = Request.QueryString["u"];
                if (!string.IsNullOrWhiteSpace(token))
                {
                    int targetId = UrlObfuscator.DecodeUserId(token);
                    if (targetId > 0)
                    {
                        return targetId;
                    }
                }

                // Check direct ?userId=...
                if (Request.QueryString["userId"] != null && int.TryParse(Request.QueryString["userId"], out int qsId) && qsId > 0)
                {
                    return qsId;
                }
            }

            return loggedInUserId;
        }

        private void LoadExistingData(int userId)
        {
            // 1. Load UserProfile
            PortfolioSaveData data = PortfolioReadRepository.Load(userId);
            UserProfile profile = data.Profile;
            if (profile != null)
            {
                txtFirstName.Text = profile.FirstName ?? string.Empty;
                txtLastName.Text = profile.LastName ?? string.Empty;
                txtAddress.Text = profile.Address ?? string.Empty;
                txtContactEmail.Text = profile.ContactEmail ?? string.Empty;
                txtContactNum.Text = profile.ContactNum ?? string.Empty;
                txtDescription.Text = profile.Description ?? string.Empty;

                if (profile.Birthday.HasValue)
                {
                    txtBirthday.Text = profile.Birthday.Value.ToString("yyyy-MM-dd");
                }

                if (!string.IsNullOrWhiteSpace(profile.ProfileImagePath))
                {
                    imgProfilePreview.ImageUrl = ResolveUrl(InputSafety.SafeImageUrl(profile.ProfileImagePath));
                    hfExistingImagePath.Value = profile.ProfileImagePath;
                }

                chkIsPublic.Checked = profile.IsPublic;
            }
            else
            {
                int loggedInUserId = (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int lid)) ? lid : 0;
                if (userId != loggedInUserId)
                {
                    UserLogin targetUser = UserRepository.GetUserById(userId, out _);
                    if (targetUser != null)
                    {
                        txtFirstName.Text = targetUser.FirstName ?? string.Empty;
                        txtLastName.Text = targetUser.LastName ?? string.Empty;
                        txtContactEmail.Text = targetUser.Email ?? string.Empty;
                    }
                }
                else if (Session["FirstName"] != null)
                {
                    // Fallback to session values from signup/login if profile not created yet
                    txtFirstName.Text = Session["FirstName"].ToString();
                    txtLastName.Text = Session["LastName"] != null ? Session["LastName"].ToString() : string.Empty;
                    txtContactEmail.Text = Session["UserEmail"] != null ? Session["UserEmail"].ToString() : string.Empty;
                }
            }

            // 2. Load Educations
            List<Education> educations = data.Educations;
            var eduDtoList = new List<object>();
            foreach (var e in educations)
            {
                eduDtoList.Add(new { courseName = e.CourseName, university = e.University, startYear = e.StartYear, endYear = e.EndYear });
            }
            hfEducationsJson.Value = new JavaScriptSerializer().Serialize(eduDtoList);

            // 3. Load Skills
            List<Skill> skills = data.Skills;
            var skillDtoList = new List<object>();
            foreach (var s in skills)
            {
                skillDtoList.Add(new { skillName = s.SkillName, skillDescription = s.SkillDescription });
            }
            hfSkillsJson.Value = new JavaScriptSerializer().Serialize(skillDtoList);

            // 4. Load Affiliations
            List<Affiliation> affiliations = data.Affiliations;
            var affilDtoList = new List<object>();
            foreach (var a in affiliations)
            {
                affilDtoList.Add(new { organizationName = a.OrganizationName, position = a.Position, startYear = a.StartYear, endYear = a.EndYear });
            }
            hfAffiliationsJson.Value = new JavaScriptSerializer().Serialize(affilDtoList);

            // 5. Load Hobbies
            List<Hobby> hobbies = data.Hobbies;
            var hobbyDtoList = new List<object>();
            foreach (var h in hobbies)
            {
                hobbyDtoList.Add(new { hobbyName = h.HobbyName, hobbyDescription = h.HobbyDescription });
            }
            hfHobbiesJson.Value = new JavaScriptSerializer().Serialize(hobbyDtoList);

            // 6. Load Social Links
            List<SocialLink> socialLinks = data.SocialLinks;
            var socialDtoList = new List<object>();
            foreach (var sl in socialLinks)
            {
                socialDtoList.Add(new { socialLinkName = sl.SocialLinkName, link = sl.Link });
            }
            hfSocialLinksJson.Value = new JavaScriptSerializer().Serialize(socialDtoList);
        }

        // =========================================================================
        // Event Handlers
        // =========================================================================
        protected void btnSaveChanges_Click(object sender, EventArgs e)
        {
            // Save progress and redirect to Dashboard (Save & Exit)
            SavePortfolioData(redirectToDashboard: true);
        }

        protected void btnCompleteOnboarding_Click(object sender, EventArgs e)
        {
            // Final submission action (Save & Launch Portfolio)
            SavePortfolioData(redirectToDashboard: true);
        }

        private void SavePortfolioData(bool redirectToDashboard)
        {
            pnlError.Visible = false; pnlSuccess.Visible = false;
            int userId = GetCurrentUserId();
            var actor = SessionSecurity.CurrentUser();
            if (!SessionSecurity.CanEdit(actor, userId)) { ShowError("Please sign in with permission to edit this portfolio."); return; }
            string uploadedImage = null;
            bool committed = false;
            string uploadDirectory = Server.MapPath("~/Uploads/Profiles/");
            try
            {
                DateTime? birthday = null;
                if (!string.IsNullOrWhiteSpace(txtBirthday.Text))
                {
                    if (!DateTime.TryParseExact(txtBirthday.Text, "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture,
                        System.Globalization.DateTimeStyles.None, out DateTime value)) throw new ArgumentException("Enter a valid birthday.");
                    birthday = value;
                }
                var data = new PortfolioSaveData
                {
                    Profile = new UserProfile { UserID = userId, FirstName = txtFirstName.Text.Trim(), LastName = txtLastName.Text.Trim(),
                        Birthday = birthday, Address = txtAddress.Text.Trim(), ContactEmail = txtContactEmail.Text.Trim(),
                        ContactNum = System.Text.RegularExpressions.Regex.Replace(txtContactNum.Text.Trim(), @"\D", ""),
                        Description = txtDescription.Text.Trim(), IsPublic = chkIsPublic.Checked },
                    Educations = PortfolioSaveData.ParseSection<Education>(hfEducationsJson.Value, "Education"),
                    Skills = PortfolioSaveData.ParseSection<Skill>(hfSkillsJson.Value, "Skills"),
                    Affiliations = PortfolioSaveData.ParseSection<Affiliation>(hfAffiliationsJson.Value, "Affiliations"),
                    Hobbies = PortfolioSaveData.ParseSection<Hobby>(hfHobbiesJson.Value, "Hobbies"),
                    SocialLinks = PortfolioSaveData.ParseSection<SocialLink>(hfSocialLinksJson.Value, "Social links")
                };
                data.Validate();
                if (fileProfileImage.HasFile)
                {
                    uploadedImage = ProfileImages.Save(fileProfileImage.PostedFile, userId, uploadDirectory);
                    data.Profile.ProfileImagePath = uploadedImage;
                }
                if (!PortfolioSaveRepository.Save(data, actor.UserID, out string previousImage, out string error))
                {
                    if (!committed && uploadedImage != null) ProfileImages.Delete(uploadedImage, uploadDirectory);
                    ShowError(error); return;
                }
                committed = true;
                if (uploadedImage != null && previousImage != uploadedImage) ProfileImages.Delete(previousImage, uploadDirectory);
                if (actor.UserID == userId)
                {
                    Session["FirstName"] = data.Profile.FirstName; Session["LastName"] = data.Profile.LastName;
                    Session["FullName"] = data.Profile.FullName;
                }
                pnlSuccess.Visible = true;
                lblSuccessMessage.Text = "Portfolio saved successfully. Redirecting to your portfolio…";
                string target = "Portfolio.aspx?u=" + UrlObfuscator.EncodeUserId(userId);
                ClientScript.RegisterStartupScript(GetType(), "OnboardingRedirect",
                    "setTimeout(function(){window.location.href='" + target + "';},1500);", true);
            }
            catch (ArgumentException ex) { if (!committed && uploadedImage != null) ProfileImages.Delete(uploadedImage, uploadDirectory); ShowError(ex.Message); }
            catch (Exception ex)
            {
                if (!committed && uploadedImage != null) ProfileImages.Delete(uploadedImage, uploadDirectory);
                System.Diagnostics.Trace.TraceError("Portfolio editor failed: {0}", ex);
                ShowError("The portfolio could not be saved. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblErrorMessage.Text = Server.HtmlEncode(message);
        }

    }
}
