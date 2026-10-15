using System;
using _241611JalopPersonalWebsite.Backend.Common;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.User
{
    public partial class PublicDashboard : SecurePage
    {
        private const int PageSize = 12;
        private int CurrentPage { get => (int?)ViewState["DirectoryPage"] ?? 1; set => ViewState["DirectoryPage"] = value; }

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
            List<PublicPortfolioItem> portfolios = UserProfileRepository.GetPublicPortfolios(search, CurrentPage, PageSize, out int total, out string error);
            int pages = Math.Max(1, (total + PageSize - 1) / PageSize);
            CurrentPage = Math.Min(CurrentPage, pages);
            btnPreviousPage.Enabled = CurrentPage > 1;
            btnNextPage.Enabled = CurrentPage < pages;
            litPageNumber.Text = $"Page {CurrentPage} of {pages} · {total} portfolios";
            pnlPagination.Visible = total > PageSize;
            lblDirectoryMessage.Text = Server.HtmlEncode(error);
            pnlDirectoryError.Visible = !string.IsNullOrEmpty(error);
            bool searching = !string.IsNullOrWhiteSpace(search);
            litEmptyDirectoryTitle.Text = searching ? "No matching public portfolios" : "No public portfolios available";
            litEmptyDirectoryDescription.Text = searching ? "Try another keyword or reset your search to see all public portfolios." : "No portfolios are currently public. Check back soon!";

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
                pnlNoPortfolios.Visible = string.IsNullOrEmpty(error);
                if (!string.IsNullOrEmpty(error)) pnlPagination.Visible = false;
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            LoadPortfolios(txtSearch.Text.Trim());
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            txtSearch.Text = string.Empty;
            LoadPortfolios(null);
        }

        protected void btnPreviousPage_Click(object sender, EventArgs e) { CurrentPage = Math.Max(1, CurrentPage - 1); LoadPortfolios(txtSearch.Text.Trim()); }
        protected void btnNextPage_Click(object sender, EventArgs e) { CurrentPage++; LoadPortfolios(txtSearch.Text.Trim()); }

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
