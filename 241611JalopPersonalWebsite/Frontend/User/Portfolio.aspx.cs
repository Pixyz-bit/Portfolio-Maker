using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI;
using _241611JalopPersonalWebsite.Backend.Common;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.User
{
    public partial class Portfolio : Page
    {
        public string ShareUrl { get; set; } = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int targetUserId = ResolveTargetUserId();
                if (targetUserId > 0)
                {
                    LoadPortfolio(targetUserId);
                }
                else
                {
                    // No profile found and unauthenticated
                    Response.Redirect("~/Frontend/Login/Login.aspx?msg=Please+log+in+to+view+or+setup+your+portfolio");
                }
            }
        }

        public static string FormatPeriod(object startYearObj, object endYearObj)
        {
            string start = (startYearObj as string ?? string.Empty).Trim();
            string end = (endYearObj as string ?? string.Empty).Trim();

            if (string.IsNullOrEmpty(start) && string.IsNullOrEmpty(end))
            {
                return string.Empty;
            }

            if (string.IsNullOrEmpty(end))
            {
                return $"{start} - Present";
            }

            return $"{start} - {end}";
        }

        public static string GetSocialIcon(string linkName)
        {
            string key = (linkName ?? string.Empty).Trim().ToLowerInvariant();

            if (key.Contains("github"))
            {
                return "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z\"/></svg>";
            }
            if (key.Contains("instagram"))
            {
                return "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><rect x=\"2\" y=\"2\" width=\"20\" height=\"20\" rx=\"5\" ry=\"5\"></rect><path d=\"M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z\"></path><line x1=\"17.5\" y1=\"6.5\" x2=\"17.51\" y2=\"6.5\"></line></svg>";
            }
            if (key.Contains("facebook"))
            {
                return "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z\"/></svg>";
            }
            if (key.Contains("linkedin"))
            {
                return "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M19 3a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h14m-.5 15.5v-5.3a3.26 3.26 0 0 0-3.26-3.26c-.85 0-1.84.52-2.28 1.3v-1.11h-2.79v8.37h2.79v-4.93c0-.77.62-1.4 1.39-1.4a1.4 1.4 0 0 1 1.4 1.4v4.93h2.75M6.46 8.76a1.64 1.64 0 0 0 1.63-1.63c0-.9-.73-1.63-1.63-1.63-.9 0-1.63.73-1.63 1.63 0 .9.73 1.63 1.63 1.63m1.4 9.74v-8.37H5.06v8.37h2.8z\"/></svg>";
            }
            if (key.Contains("twitter") || key == "x")
            {
                return "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z\"/></svg>";
            }
            if (key.Contains("youtube"))
            {
                return "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z\"/></svg>";
            }

            return "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><line x1=\"2\" y1=\"12\" x2=\"22\" y2=\"12\"></line><path d=\"M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z\"></path></svg>";
        }

        private int ResolveTargetUserId()
        {
            // 1. Check Obfuscated/Hashed Token QueryString: ?u=TOKEN
            string token = Request.QueryString["u"];
            if (!string.IsNullOrWhiteSpace(token))
            {
                int decodedId = UrlObfuscator.DecodeUserId(token);
                if (decodedId > 0)
                {
                    return decodedId;
                }
            }

            // 2. Direct QueryString: ?userId=X (Allowed for Admin or the authenticated owner)
            if (Request.QueryString["userId"] != null && int.TryParse(Request.QueryString["userId"], out int qsId) && qsId > 0)
            {
                bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);
                int loggedInId = (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int sId)) ? sId : 0;

                if (isAdmin || loggedInId == qsId)
                {
                    return qsId;
                }
            }

            // 3. Check Session (logged-in user viewing their own portfolio)
            if (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int sessionUserId) && sessionUserId > 0)
            {
                return sessionUserId;
            }

            // 4. Fallback for testing: find latest active user in database (only if in development)
            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();
                    string query = "SELECT TOP 1 UserID FROM dbo.Users WHERE IsActive = 1 ORDER BY UserID DESC";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int dbId))
                        {
                            return dbId;
                        }
                    }
                }
            }
            catch
            {
                // Ignore fallback failure
            }

            return 0;
        }

        private void LoadPortfolio(int userId)
        {
            // 1. Determine viewer authentication & permissions
            int loggedInUserId = 0;
            bool isLoggedIn = Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out loggedInUserId);
            bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);
            bool isOwner = isLoggedIn && (loggedInUserId == userId);
            bool canEdit = isOwner || isAdmin;

            // Generate canonical full absolute shareable URL with ?u={token}
            string scheme = Request.Url.Scheme;
            string authority = Request.Url.Authority;
            string path = ResolveUrl("~/Frontend/User/Portfolio.aspx");
            string token = UrlObfuscator.EncodeUserId(userId);
            ShareUrl = $"{scheme}://{authority}{path}?u={token}";

            // 2. Load UserProfile for the portfolio being viewed
            UserProfile profile = UserProfileRepository.GetByUserId(userId, out string profileError);
            if (profile != null)
            {
                string fullName = profile.FullName;
                litPageTitle.Text = $"{fullName} | Personal Portfolio";
                litBrandName.Text = fullName;
                litFooterName.Text = fullName;

                if (!string.IsNullOrWhiteSpace(profile.FirstName))
                {
                    litBrandInitials.Text = profile.FirstName.Substring(0, 1).ToUpper();
                }
            }
            else
            {
                litPageTitle.Text = "Portfolio";
                litBrandName.Text = "Portfolio";
                litFooterName.Text = "Portfolio";
            }

            // 3. Configure Top Action Bar based on viewer status
            if (isLoggedIn)
            {
                // User menu is visible for logged-in user
                ucUserMenu.Visible = true;
                UserProfile menuProfile = (loggedInUserId == userId) ? profile : UserProfileRepository.GetByUserId(loggedInUserId, out _);
                string menuEmail = Session["UserEmail"]?.ToString() ?? (menuProfile != null ? menuProfile.ContactEmail : string.Empty);
                ucUserMenu.BindUser(menuProfile, menuEmail, canEditPortfolio: canEdit, canEditAccount: true);

                lnkGuestSignIn.Visible = false;
            }
            else
            {
                // HIDE all edit options and user menu completely!
                ucUserMenu.Visible = false;

                // Show clean "Sign In" option
                lnkGuestSignIn.Visible = true;
            }

            // 3. Delegate to modular user controls
            ucHero.BindProfile(profile);
            ucSummary.BindSummary(profile != null ? profile.Description : null);

            List<Education> educations = EducationRepository.GetByUserId(userId, out _);
            ucEducation.BindEducation(educations);

            List<Skill> skills = SkillRepository.GetByUserId(userId, out _);
            ucSkills.BindSkills(skills);

            List<Affiliation> affiliations = AffiliationRepository.GetByUserId(userId, out _);
            ucAffiliations.BindAffiliations(affiliations);

            List<Hobby> hobbies = HobbyRepository.GetByUserId(userId, out _);
            ucHobbies.BindHobbies(hobbies);

            List<SocialLink> socialLinks = SocialLinkRepository.GetByUserId(userId, out _);
            ucSocialLinks.BindSocialLinks(socialLinks);
        }
    }
}
