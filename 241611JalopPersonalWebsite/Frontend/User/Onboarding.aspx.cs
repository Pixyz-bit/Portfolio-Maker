using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.User
{
    public partial class Onboarding : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify user authentication
            int userId = GetCurrentUserId();
            if (userId <= 0)
            {
                Response.Redirect("~/Frontend/Login/Login.aspx?msg=Please+sign+in+to+access+onboarding");
                return;
            }

            if (!IsPostBack)
            {
                pnlError.Visible = false;
                pnlSuccess.Visible = false;

                // Load existing profile and portfolio data into form
                LoadExistingData(userId);
            }
        }

        private int GetCurrentUserId()
        {
            if (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int userId))
            {
                return userId;
            }

            return 0;
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
            else if (Session["FirstName"] != null)
            {
                // Fallback to session values from signup/login if profile not created yet
                txtFirstName.Text = Session["FirstName"].ToString();
                txtLastName.Text = Session["LastName"] != null ? Session["LastName"].ToString() : string.Empty;
                txtContactEmail.Text = Session["UserEmail"] != null ? Session["UserEmail"].ToString() : string.Empty;
            }

            // 2. Load Educations
            List<Education> educations = EducationRepository.GetByUserId(userId, out _);
            if (educations != null && educations.Count > 0)
            {
                txtCourse1.Text = educations[0].CourseName;
                txtUniversity1.Text = educations[0].University;
                txtEduStartYear1.Text = educations[0].StartYear;
                txtEduEndYear1.Text = educations[0].EndYear ?? string.Empty;

                if (educations.Count > 1)
                {
                    txtCourse2.Text = educations[1].CourseName;
                    txtUniversity2.Text = educations[1].University;
                    txtEduStartYear2.Text = educations[1].StartYear;
                    txtEduEndYear2.Text = educations[1].EndYear ?? string.Empty;
                }
            }

            // 3. Load Skills
            List<Skill> skills = SkillRepository.GetByUserId(userId, out _);
            if (skills != null && skills.Count > 0)
            {
                if (skills.Count >= 1) { txtSkill1.Text = skills[0].SkillName; txtSkillDesc1.Text = skills[0].SkillDescription; }
                if (skills.Count >= 2) { txtSkill2.Text = skills[1].SkillName; txtSkillDesc2.Text = skills[1].SkillDescription; }
                if (skills.Count >= 3) { txtSkill3.Text = skills[2].SkillName; txtSkillDesc3.Text = skills[2].SkillDescription; }
                if (skills.Count >= 4) { txtSkill4.Text = skills[3].SkillName; txtSkillDesc4.Text = skills[3].SkillDescription; }
            }

            // 4. Load Affiliations
            List<Affiliation> affiliations = AffiliationRepository.GetByUserId(userId, out _);
            if (affiliations != null && affiliations.Count > 0)
            {
                if (affiliations.Count >= 1)
                {
                    txtOrg1.Text = affiliations[0].OrganizationName;
                    txtRole1.Text = affiliations[0].Position;
                    txtOrgStart1.Text = affiliations[0].StartYear;
                    txtOrgEnd1.Text = affiliations[0].EndYear ?? string.Empty;
                }
                if (affiliations.Count >= 2)
                {
                    txtOrg2.Text = affiliations[1].OrganizationName;
                    txtRole2.Text = affiliations[1].Position;
                    txtOrgStart2.Text = affiliations[1].StartYear;
                    txtOrgEnd2.Text = affiliations[1].EndYear ?? string.Empty;
                }
            }

            // 5. Load Hobbies
            List<Hobby> hobbies = HobbyRepository.GetByUserId(userId, out _);
            if (hobbies != null && hobbies.Count > 0)
            {
                if (hobbies.Count >= 1)
                {
                    txtHobby1.Text = hobbies[0].HobbyName;
                    txtHobbyDesc1.Text = hobbies[0].HobbyDescription;
                }
                if (hobbies.Count >= 2)
                {
                    txtHobby2.Text = hobbies[1].HobbyName;
                    txtHobbyDesc2.Text = hobbies[1].HobbyDescription;
                }
            }

            // 6. Load Social Links
            List<SocialLink> socialLinks = SocialLinkRepository.GetByUserId(userId, out _);
            if (socialLinks != null)
            {
                foreach (SocialLink link in socialLinks)
                {
                    string name = link.SocialLinkName?.ToLower() ?? string.Empty;
                    if (name.Contains("github")) txtGithubLink.Text = link.Link;
                    else if (name.Contains("linkedin")) txtLinkedinLink.Text = link.Link;
                    else if (name.Contains("website") || name.Contains("portfolio")) txtWebsiteLink.Text = link.Link;
                    else if (name.Contains("twitter") || name.Contains("x")) txtTwitterLink.Text = link.Link;
                    else if (string.IsNullOrWhiteSpace(txtOtherSocialLink.Text)) txtOtherSocialLink.Text = link.Link;
                }
            }
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
                    existingProfile.ContactEmail = txtContactEmail.Text.Trim();
                    existingProfile.ContactNum = txtContactNum.Text.Trim();
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
                        ContactEmail = txtContactEmail.Text.Trim(),
                        ContactNum = txtContactNum.Text.Trim(),
                        ProfileImagePath = profileImagePath,
                        Description = txtDescription.Text.Trim()
                    };

                    if (!UserProfileRepository.Create(newProfile, out string createError))
                    {
                        ShowError($"Failed to create profile: {createError}");
                        return;
                    }
                }

                // Update Session state
                Session["FirstName"] = firstName;
                Session["LastName"] = lastName;
                Session["FullName"] = $"{firstName} {lastName}".Trim();

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

                if (!string.IsNullOrWhiteSpace(txtCourse1.Text) && !string.IsNullOrWhiteSpace(txtUniversity1.Text))
                {
                    Education edu1 = new Education
                    {
                        UserID = userId,
                        CourseName = txtCourse1.Text.Trim(),
                        University = txtUniversity1.Text.Trim(),
                        StartYear = string.IsNullOrWhiteSpace(txtEduStartYear1.Text) ? "2020" : txtEduStartYear1.Text.Trim(),
                        EndYear = txtEduEndYear1.Text.Trim()
                    };
                    EducationRepository.Create(edu1, out _);
                }

                if (!string.IsNullOrWhiteSpace(txtCourse2.Text) && !string.IsNullOrWhiteSpace(txtUniversity2.Text))
                {
                    Education edu2 = new Education
                    {
                        UserID = userId,
                        CourseName = txtCourse2.Text.Trim(),
                        University = txtUniversity2.Text.Trim(),
                        StartYear = string.IsNullOrWhiteSpace(txtEduStartYear2.Text) ? "2018" : txtEduStartYear2.Text.Trim(),
                        EndYear = txtEduEndYear2.Text.Trim()
                    };
                    EducationRepository.Create(edu2, out _);
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

                SaveSkillIfNotEmpty(userId, txtSkill1.Text, txtSkillDesc1.Text);
                SaveSkillIfNotEmpty(userId, txtSkill2.Text, txtSkillDesc2.Text);
                SaveSkillIfNotEmpty(userId, txtSkill3.Text, txtSkillDesc3.Text);
                SaveSkillIfNotEmpty(userId, txtSkill4.Text, txtSkillDesc4.Text);

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

                SaveAffiliationIfNotEmpty(userId, txtOrg1.Text, txtRole1.Text, txtOrgStart1.Text, txtOrgEnd1.Text);
                SaveAffiliationIfNotEmpty(userId, txtOrg2.Text, txtRole2.Text, txtOrgStart2.Text, txtOrgEnd2.Text);

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

                SaveHobbyIfNotEmpty(userId, txtHobby1.Text, txtHobbyDesc1.Text);
                SaveHobbyIfNotEmpty(userId, txtHobby2.Text, txtHobbyDesc2.Text);

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

                SaveSocialLinkIfNotEmpty(userId, "GitHub", txtGithubLink.Text);
                SaveSocialLinkIfNotEmpty(userId, "LinkedIn", txtLinkedinLink.Text);
                SaveSocialLinkIfNotEmpty(userId, "Personal Website", txtWebsiteLink.Text);
                SaveSocialLinkIfNotEmpty(userId, "Twitter / X", txtTwitterLink.Text);
                SaveSocialLinkIfNotEmpty(userId, "Instagram", txtOtherSocialLink.Text);

                // =========================================================================
                // 8. Result Handling
                // =========================================================================
                pnlSuccess.Visible = true;

                if (redirectToDashboard)
                {
                    lblSuccessMessage.Text = "Portfolio details successfully saved! Redirecting to your dashboard...";
                    string redirectScript = "setTimeout(function(){ window.location.href = 'Dashboard.aspx'; }, 1500);";
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
    }
}
