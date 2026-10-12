using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.User
{
    public partial class PublicDashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            SetupNavigationState();

            if (!IsPostBack)
            {
                string querySearch = Request.QueryString["q"];
                if (!string.IsNullOrWhiteSpace(querySearch))
                {
                    txtSearch.Text = querySearch.Trim();
                }

                LoadPortfolios(txtSearch.Text);
            }
        }

        private void SetupNavigationState()
        {
            int loggedInUserId = (Session["UserID"] != null && int.TryParse(Session["UserID"].ToString(), out int uid)) ? uid : 0;
            bool isLoggedIn = loggedInUserId > 0;
            bool isAdmin = string.Equals(Session["Role"]?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase);

            if (isLoggedIn)
            {
                phLoggedInActions.Visible = true;
                phGuestActions.Visible = false;

                if (isAdmin)
                {
                    lnkMyDashboard.NavigateUrl = "~/Frontend/Admin/Dashboard.aspx";
                    lnkMyDashboard.Text = "Admin Dashboard";
                }
                else
                {
                    lnkMyDashboard.NavigateUrl = "~/Frontend/User/Dashboard.aspx";
                    lnkMyDashboard.Text = "My Dashboard";
                }

                lnkMyPortfolio.NavigateUrl = "~/Frontend/User/Portfolio.aspx";

                UserProfile profile = UserProfileRepository.GetByUserId(loggedInUserId, out _);
                string email = Session["UserEmail"]?.ToString() ?? Session["Email"]?.ToString() ?? string.Empty;
                ucUserMenu.BindUser(profile, email);
            }
            else
            {
                phLoggedInActions.Visible = false;
                phGuestActions.Visible = true;
            }
        }

        private void LoadPortfolios(string search)
        {
            List<PublicPortfolioItem> portfolios = UserProfileRepository.GetPublicPortfolios(search, out string error);

            if (string.IsNullOrEmpty(error) && portfolios != null && portfolios.Count > 0)
            {
                rptPortfolios.DataSource = portfolios;
                rptPortfolios.DataBind();
                pnlNoPortfolios.Visible = false;
            }
            else
            {
                rptPortfolios.DataSource = null;
                rptPortfolios.DataBind();
                pnlNoPortfolios.Visible = true;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadPortfolios(txtSearch.Text.Trim());
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            LoadPortfolios(null);
        }

        public static string FormatSkillsPills(List<string> skills)
        {
            if (skills == null || skills.Count == 0)
            {
                return string.Empty;
            }

            StringBuilder sb = new StringBuilder();
            int maxPills = 4;
            int count = 0;

            foreach (string skill in skills)
            {
                if (count < maxPills)
                {
                    sb.Append($"<span class=\"skill-tag\">{System.Web.HttpUtility.HtmlEncode(skill)}</span>");
                    count++;
                }
                else
                {
                    break;
                }
            }

            if (skills.Count > maxPills)
            {
                sb.Append($"<span class=\"skill-tag-more\">+{skills.Count - maxPills} more</span>");
            }

            return sb.ToString();
        }
    }
}
