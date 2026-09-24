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
    public partial class Onboarding : Page
    {
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

                    pnlAdminBanner.Visible = true;
                    litAdminTargetUserName.Text = targetName;
                    litPageTitle.Text = $"Edit Portfolio: {targetName}";
                    litPageSubtitle.Text = "You are editing this user's live portfolio information with Administrator authority.";
                }
                else
                {
                    pnlAdminBanner.Visible = false;
                    litPageTitle.Text = "Profile Onboarding";
                    litPageSubtitle.Text = "Fill in your information at your own pace. Save & Exit anytime to view your portfolio.";
                }

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
            UserProfile profile = UserProfileRepository.GetByUserId(userId, out _);
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
                    imgProfilePreview.ImageUrl = ResolveUrl(profile.ProfileImagePath);
                    hfExistingImagePath.Value = profile.ProfileImagePath;
                }
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
            List<Education> educations = EducationRepository.GetByUserId(userId, out _) ?? new List<Education>();
            var eduDtoList = new List<object>();
            foreach (var e in educations)
            {
                eduDtoList.Add(new { courseName = e.CourseName, university = e.University, startYear = e.StartYear, endYear = e.EndYear });
            }
            hfEducationsJson.Value = new JavaScriptSerializer().Serialize(eduDtoList);

            // 3. Load Skills
            List<Skill> skills = SkillRepository.GetByUserId(userId, out _) ?? new List<Skill>();
            var skillDtoList = new List<object>();
            foreach (var s in skills)
            {
                skillDtoList.Add(new { skillName = s.SkillName, skillDescription = s.SkillDescription });
            }
            hfSkillsJson.Value = new JavaScriptSerializer().Serialize(skillDtoList);

            // 4. Load Affiliations
            List<Affiliation> affiliations = AffiliationRepository.GetByUserId(userId, out _) ?? new List<Affiliation>();
            var affilDtoList = new List<object>();
            foreach (var a in affiliations)
            {
                affilDtoList.Add(new { organizationName = a.OrganizationName, position = a.Position, startYear = a.StartYear, endYear = a.EndYear });
            }
            hfAffiliationsJson.Value = new JavaScriptSerializer().Serialize(affilDtoList);

            // 5. Load Hobbies
            List<Hobby> hobbies = HobbyRepository.GetByUserId(userId, out _) ?? new List<Hobby>();
            var hobbyDtoList = new List<object>();
            foreach (var h in hobbies)
            {
                hobbyDtoList.Add(new { hobbyName = h.HobbyName, hobbyDescription = h.HobbyDescription });
            }
            hfHobbiesJson.Value = new JavaScriptSerializer().Serialize(hobbyDtoList);

            // 6. Load Social Links
            List<SocialLink> socialLinks = SocialLinkRepository.GetByUserId(userId, out _) ?? new List<SocialLink>();
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
            pnlError.Visible = false;
            pnlSuccess.Visible = false;

            int userId = GetCurrentUserId();
            if (userId <= 0)
            {
                ShowError("Session expired or invalid. Please log in again.");
                return;
            }

            // Validate personal info (fallback to session if empty)
            string firstName = txtFirstName.Text.Trim();
            string lastName = txtLastName.Text.Trim();

            if (string.IsNullOrWhiteSpace(firstName) && Session["FirstName"] != null)
            {
                firstName = Session["FirstName"].ToString();
            }

            if (string.IsNullOrWhiteSpace(lastName) && Session["LastName"] != null)
            {
                lastName = Session["LastName"].ToString();
            }

            if (string.IsNullOrWhiteSpace(firstName) || string.IsNullOrWhiteSpace(lastName))
            {
                ShowError("Please enter your First Name and Last Name on Step 1 to save your portfolio.");
                hfCurrentStep.Value = "1";
                return;
            }

            // Validate Public Contact Email (if provided)
            string contactEmail = txtContactEmail.Text.Trim();
            if (!string.IsNullOrWhiteSpace(contactEmail))
            {
                if (!Regex.IsMatch(contactEmail, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                {
                    ShowError("Please enter a valid Public Contact Email address (e.g. name@example.com).");
                    hfCurrentStep.Value = "1";
                    return;
                }
            }

            // Validate Contact Number (must be exactly 11 digits if provided)
            string contactNum = txtContactNum.Text.Trim();
            if (!string.IsNullOrWhiteSpace(contactNum))
            {
                string cleanPhone = Regex.Replace(contactNum, @"\D", "");
                if (cleanPhone.Length != 11)
                {
                    ShowError("Contact / Mobile Number must be exactly 11 digits (e.g. 09123456789).");
                    hfCurrentStep.Value = "1";
                    return;
                }
                contactNum = cleanPhone;
            }

            try
            {
                // =========================================================================
                // 1. Handle Profile Picture Upload
                // =========================================================================
                string profileImagePath = hfExistingImagePath.Value;

                if (fileProfileImage.HasFile)
                {
                    string fileExt = Path.GetExtension(fileProfileImage.FileName).ToLower();
                    if (fileExt != ".jpg" && fileExt != ".jpeg" && fileExt != ".png" && fileExt != ".webp")
                    {
                        ShowError("Please upload a valid image file (.jpg, .jpeg, .png, or .webp).");
                        return;
                    }

                    if (fileProfileImage.PostedFile.ContentLength > 2 * 1024 * 1024)
                    {
                        ShowError("Profile picture size must be less than 2MB.");
                        return;
                    }

                    string uploadDir = Server.MapPath("~/Uploads/Profiles/");
                    if (!Directory.Exists(uploadDir))
                    {
                        Directory.CreateDirectory(uploadDir);
                    }

                    string uniqueFileName = $"user_{userId}_{Guid.NewGuid().ToString("N").Substring(0, 8)}{fileExt}";
                    string fullPath = Path.Combine(uploadDir, uniqueFileName);
                    fileProfileImage.SaveAs(fullPath);

                    profileImagePath = $"~/Uploads/Profiles/{uniqueFileName}";
                    hfExistingImagePath.Value = profileImagePath;
                    imgProfilePreview.ImageUrl = ResolveUrl(profileImagePath);
                }

                // =========================================================================
                // 2. Persist UserProfile using dedicated UserProfileRepository
                // =========================================================================
                DateTime? birthday = null;
                if (!string.IsNullOrWhiteSpace(txtBirthday.Text) && DateTime.TryParse(txtBirthday.Text, out DateTime parsedBday))
                {
                    birthday = parsedBday;
                }

                UserProfile existingProfile = UserProfileRepository.GetByUserId(userId, out _);
                if (existingProfile != null)
                {
                    existingProfile.FirstName = firstName;
                    existingProfile.LastName = lastName;
                    existingProfile.Birthday = birthday;
                    existingProfile.Address = txtAddress.Text.Trim();
                    existingProfile.ContactEmail = contactEmail;
                    existingProfile.ContactNum = contactNum;
                    existingProfile.ProfileImagePath = profileImagePath;
                    existingProfile.Description = txtDescription.Text.Trim();

                    if (!UserProfileRepository.Update(existingProfile, out string updateError))
                    {
                        ShowError($"Failed to update profile: {updateError}");
                        return;
                    }
                }
                else
                {
                    UserProfile newProfile = new UserProfile
                    {
                        UserID = userId,
                        FirstName = firstName,
                        LastName = lastName,
                        Birthday = birthday,
                        Address = txtAddress.Text.Trim(),
                        ContactEmail = contactEmail,
                        ContactNum = contactNum,
                        ProfileImagePath = profileImagePath,
                        Description = txtDescription.Text.Trim()
                    };

                    if (!UserProfileRepository.Create(newProfile, out string createError))
                    {
                        ShowError($"Failed to create profile: {createError}");
                        return;
                    }
                }

                // Update Session state only if editing own profile
                int loggedInUserId = (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int lid)) ? lid : 0;
                if (userId == loggedInUserId)
                {
                    Session["FirstName"] = firstName;
                    Session["LastName"] = lastName;
                    Session["FullName"] = $"{firstName} {lastName}".Trim();
                }

                var serializer = new JavaScriptSerializer();

                // =========================================================================
                // 3. Persist Education Records using EducationRepository
                // =========================================================================
                List<Education> existingEdu = EducationRepository.GetByUserId(userId, out _);
                if (existingEdu != null)
                {
                    foreach (var edu in existingEdu)
                    {
                        EducationRepository.Delete(edu.EducationID, out _);
                    }
                }

                if (!string.IsNullOrWhiteSpace(hfEducationsJson.Value))
                {
                    try
                    {
                        var eduItems = serializer.Deserialize<List<EducationInputDto>>(hfEducationsJson.Value);
                        if (eduItems != null)
                        {
                            foreach (var item in eduItems)
                            {
                                if (!string.IsNullOrWhiteSpace(item.CourseName) && !string.IsNullOrWhiteSpace(item.University))
                                {
                                    Education edu = new Education
                                    {
                                        UserID = userId,
                                        CourseName = item.CourseName.Trim(),
                                        University = item.University.Trim(),
                                        StartYear = string.IsNullOrWhiteSpace(item.StartYear) ? "2020" : item.StartYear.Trim(),
                                        EndYear = item.EndYear?.Trim()
                                    };
                                    EducationRepository.Create(edu, out _);
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Error parsing educations JSON: " + ex.Message);
                    }
                }

                // =========================================================================
                // 4. Persist Skills using SkillRepository
                // =========================================================================
                List<Skill> existingSkills = SkillRepository.GetByUserId(userId, out _);
                if (existingSkills != null)
                {
                    foreach (var s in existingSkills)
                    {
                        SkillRepository.Delete(s.SkillID, out _);
                    }
                }

                if (!string.IsNullOrWhiteSpace(hfSkillsJson.Value))
                {
                    try
                    {
                        var skillItems = serializer.Deserialize<List<SkillInputDto>>(hfSkillsJson.Value);
                        if (skillItems != null)
                        {
                            foreach (var item in skillItems)
                            {
                                SaveSkillIfNotEmpty(userId, item.SkillName, item.SkillDescription);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Error parsing skills JSON: " + ex.Message);
                    }
                }

                // =========================================================================
                // 5. Persist Affiliations using AffiliationRepository
                // =========================================================================
                List<Affiliation> existingAffiliations = AffiliationRepository.GetByUserId(userId, out _);
                if (existingAffiliations != null)
                {
                    foreach (var a in existingAffiliations)
                    {
                        AffiliationRepository.Delete(a.AffiliationID, out _);
                    }
                }

                if (!string.IsNullOrWhiteSpace(hfAffiliationsJson.Value))
                {
                    try
                    {
                        var affilItems = serializer.Deserialize<List<AffiliationInputDto>>(hfAffiliationsJson.Value);
                        if (affilItems != null)
                        {
                            foreach (var item in affilItems)
                            {
                                SaveAffiliationIfNotEmpty(userId, item.OrganizationName, item.Position, item.StartYear, item.EndYear);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Error parsing affiliations JSON: " + ex.Message);
                    }
                }

                // =========================================================================
                // 6. Persist Hobbies using HobbyRepository
                // =========================================================================
                List<Hobby> existingHobbies = HobbyRepository.GetByUserId(userId, out _);
                if (existingHobbies != null)
                {
                    foreach (var h in existingHobbies)
                    {
                        HobbyRepository.Delete(h.HobbyID, out _);
                    }
                }

                if (!string.IsNullOrWhiteSpace(hfHobbiesJson.Value))
                {
                    try
                    {
                        var hobbyItems = serializer.Deserialize<List<HobbyInputDto>>(hfHobbiesJson.Value);
                        if (hobbyItems != null)
                        {
                            foreach (var item in hobbyItems)
                            {
                                SaveHobbyIfNotEmpty(userId, item.HobbyName, item.HobbyDescription);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Error parsing hobbies JSON: " + ex.Message);
                    }
                }

                // =========================================================================
                // 7. Persist Social Links using SocialLinkRepository (Final Step)
                // =========================================================================
                List<SocialLink> existingLinks = SocialLinkRepository.GetByUserId(userId, out _);
                if (existingLinks != null)
                {
                    foreach (var sl in existingLinks)
                    {
                        SocialLinkRepository.Delete(sl.SocialLinkID, out _);
                    }
                }

                if (!string.IsNullOrWhiteSpace(hfSocialLinksJson.Value))
                {
                    try
                    {
                        var socialItems = serializer.Deserialize<List<SocialLinkInputDto>>(hfSocialLinksJson.Value);
                        if (socialItems != null)
                        {
                            foreach (var item in socialItems)
                            {
                                SaveSocialLinkIfNotEmpty(userId, item.SocialLinkName, item.Link);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("Error parsing social links JSON: " + ex.Message);
                    }
                }

                // =========================================================================
                // 8. Result Handling
                // =========================================================================
                pnlSuccess.Visible = true;

                if (redirectToDashboard)
                {
                    int currentSessionId = (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int sid)) ? sid : 0;
                    string targetUrl;
                    if (userId == currentSessionId)
                    {
                        lblSuccessMessage.Text = "Portfolio details successfully saved! Redirecting to your portfolio...";
                        targetUrl = "Portfolio.aspx";
                    }
                    else
                    {
                        lblSuccessMessage.Text = "User portfolio successfully updated! Redirecting to portfolio preview...";
                        string targetToken = UrlObfuscator.EncodeUserId(userId);
                        targetUrl = $"Portfolio.aspx?u={targetToken}";
                    }

                    string redirectScript = $"setTimeout(function(){{ window.location.href = '{targetUrl}'; }}, 1500);";
                    ClientScript.RegisterStartupScript(this.GetType(), "OnboardingRedirect", redirectScript, true);
                }
                else
                {
                    lblSuccessMessage.Text = "Changes saved successfully! Your portfolio data has been updated in the database.";
                }
            }
            catch (Exception ex)
            {
                ShowError($"An unexpected error occurred while saving: {ex.Message}");
            }
        }

        private void SaveSkillIfNotEmpty(int userId, string skillName, string description)
        {
            if (!string.IsNullOrWhiteSpace(skillName))
            {
                SkillRepository.Create(new Skill
                {
                    UserID = userId,
                    SkillName = skillName.Trim(),
                    SkillDescription = description?.Trim()
                }, out _);
            }
        }

        private void SaveAffiliationIfNotEmpty(int userId, string orgName, string position, string startYear, string endYear)
        {
            if (!string.IsNullOrWhiteSpace(orgName) && !string.IsNullOrWhiteSpace(position))
            {
                AffiliationRepository.Create(new Affiliation
                {
                    UserID = userId,
                    OrganizationName = orgName.Trim(),
                    Position = position.Trim(),
                    StartYear = string.IsNullOrWhiteSpace(startYear) ? "2022" : startYear.Trim(),
                    EndYear = endYear?.Trim()
                }, out _);
            }
        }

        private void SaveHobbyIfNotEmpty(int userId, string hobbyName, string description)
        {
            if (!string.IsNullOrWhiteSpace(hobbyName))
            {
                HobbyRepository.Create(new Hobby
                {
                    UserID = userId,
                    HobbyName = hobbyName.Trim(),
                    HobbyDescription = description?.Trim()
                }, out _);
            }
        }

        private void SaveSocialLinkIfNotEmpty(int userId, string platformName, string url)
        {
            if (!string.IsNullOrWhiteSpace(url))
            {
                SocialLinkRepository.Create(new SocialLink
                {
                    UserID = userId,
                    SocialLinkName = platformName,
                    Link = url.Trim()
                }, out _);
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblErrorMessage.Text = message;
        }

        private class EducationInputDto
        {
            public string CourseName { get; set; }
            public string University { get; set; }
            public string StartYear { get; set; }
            public string EndYear { get; set; }
        }

        private class SkillInputDto
        {
            public string SkillName { get; set; }
            public string SkillDescription { get; set; }
        }

        private class AffiliationInputDto
        {
            public string OrganizationName { get; set; }
            public string Position { get; set; }
            public string StartYear { get; set; }
            public string EndYear { get; set; }
        }

        private class HobbyInputDto
        {
            public string HobbyName { get; set; }
            public string HobbyDescription { get; set; }
        }

        private class SocialLinkInputDto
        {
            public string SocialLinkName { get; set; }
            public string Link { get; set; }
        }
    }
}
