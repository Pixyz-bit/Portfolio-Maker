<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PublicDashboard.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.PublicDashboard" %>
<%@ Register Src="~/Frontend/User/Controls/UserMenu.ascx" TagPrefix="uc" TagName="UserMenu" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Public Portfolios Directory | Creator Showcase</title>
    <meta name="description" content="Discover publicly active personal portfolios. Explore skills, projects, and connect directly with creators." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />

    <link rel="stylesheet" href="../Assets/css/public-dashboard.css" />
    <link rel="stylesheet" href="<%= Page.ResolveUrl("~/Frontend/Assets/css/user-menu.css") %>?v=20261013" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Frontend/Assets/css/accessibility.css") %>?v=20261015e" />
    <script src="<%= ResolveUrl("~/Frontend/Assets/js/accessibility.js") %>?v=20261015e" defer></script>
</head>
<body>
    <form id="publicDashboardForm" runat="server">
        <!-- Top Navigation Bar -->
        <header class="public-navbar">
            <a href="PublicDashboard.aspx" class="nav-brand">
                <div class="brand-badge">P</div>
                <div>
                    <span class="brand-text">Portfolio Showcase</span>
                    <span class="brand-subtitle">Public Creator Directory</span>
                </div>
            </a>

            <div class="nav-actions">
                <asp:PlaceHolder ID="phLoggedInActions" runat="server" Visible="false">
                    <asp:HyperLink ID="lnkMyDashboard" runat="server" CssClass="btn btn-outline btn-sm">
                        My Dashboard
                    </asp:HyperLink>
                    <asp:HyperLink ID="lnkMyPortfolio" runat="server" CssClass="btn btn-solid btn-sm">
                        My Portfolio
                    </asp:HyperLink>
                    <uc:UserMenu ID="ucUserMenu" runat="server" />
                </asp:PlaceHolder>

                <asp:PlaceHolder ID="phGuestActions" runat="server" Visible="true">
                    <a href="../Login/Login.aspx" class="btn btn-outline btn-sm">Sign In</a>
                    <a href="../Login/Signup.aspx" class="btn btn-solid btn-sm">Create Portfolio</a>
                </asp:PlaceHolder>
            </div>
        </header>

        <!-- Main Content Area -->
        <main class="public-container">
            <section class="hero-header">
                <div class="hero-pill">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 14 14"></polyline></svg>
                    Live & Verified Portfolios
                </div>
                <h1 class="hero-title">Explore Public Portfolios</h1>
                <p class="hero-desc">
                    Browse all publicly toggled developer and professional portfolios. Search by name, profession, tech stack, or location.
                </p>

                <!-- Search Input Field with Instant Real-Time Filter & Server Form -->
                <div class="search-bar-wrap">
                    <div class="search-input-group">
                        <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search by name, skill, keyword, or location..." MaxLength="255" aria-label="Search public portfolios" />
                    </div>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-solid" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline" OnClick="btnReset_Click" />
                </div>
            </section>

            <asp:Panel ID="pnlDirectoryError" runat="server" Visible="false" role="alert" CssClass="empty-state">
                <asp:Label ID="lblDirectoryMessage" runat="server" />
            </asp:Panel>
            <!-- Portfolios Grid -->
            <section>
                <div class="portfolio-grid" id="portfolioGrid">
                    <asp:Repeater ID="rptPortfolios" runat="server">
                        <ItemTemplate>
                            <article class="portfolio-card" 
                                     data-name="<%# Server.HtmlEncode((Eval("FullName")?.ToString() ?? "").ToLowerInvariant()) %>"
                                     data-desc="<%# Server.HtmlEncode((Eval("Description")?.ToString() ?? "").ToLowerInvariant()) %>"
                                     data-skills="<%# Server.HtmlEncode(string.Join(" ", (System.Collections.Generic.List<string>)Eval("Skills")).ToLowerInvariant()) %>"
                                     data-address="<%# Server.HtmlEncode((Eval("Address")?.ToString() ?? "").ToLowerInvariant()) %>">
                                <div>
                                    <div class="card-top">
                                        <div class="card-avatar">
                                            <%# !string.IsNullOrWhiteSpace(Eval("ProfileImagePath")?.ToString()) 
                                                ? $"<img src='{Server.HtmlEncode(ResolveUrl(_241611JalopPersonalWebsite.Backend.Common.ProfileImages.Url(Convert.ToInt32(Eval("UserID")), Eval("ProfileImagePath").ToString())))}' alt='{Server.HtmlEncode(Eval("FullName")?.ToString())}' />"
                                                : Server.HtmlEncode(Eval("Initials")?.ToString()) %>
                                        </div>
                                        <div class="card-user-info">
                                            <h2 class="card-user-name"><%# Server.HtmlEncode(Eval("FullName")?.ToString()) %></h2>
                                            <%# !string.IsNullOrWhiteSpace(Eval("Address")?.ToString())
                                                ? $"<p class='card-user-location'><svg width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z'></path><circle cx='12' cy='10' r='3'></circle></svg>{Server.HtmlEncode(Eval("Address").ToString())}</p>"
                                                : "" %>
                                            <span class="card-status-pill">
                                                <span class="card-status-dot"></span>
                                                Public Portfolio
                                            </span>
                                        </div>
                                    </div>

                                    <div class="card-body">
                                        <p class="card-bio">
                                            <%# !string.IsNullOrWhiteSpace(Eval("Description")?.ToString())
                                                ? Server.HtmlEncode(Eval("Description").ToString())
                                                : "Professional portfolio showcasing projects, education, competencies, and achievements." %>
                                        </p>

                                        <div class="card-skills-wrap">
                                            <%# FormatSkillsPills(Eval("Skills") as System.Collections.Generic.List<string>) %>
                                        </div>
                                    </div>
                                </div>

                                <div class="card-footer">
                                    <span class="card-date">
                                        Member since <%# ((DateTime)Eval("CreatedAt")).ToString("MMM yyyy") %>
                                    </span>
                                    <a href='<%# ResolveUrl($"~/Frontend/User/Portfolio.aspx?u={Eval("ObfuscatedToken")}") %>' class="btn-view-portfolio">
                                        View Portfolio
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                                    </a>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- Client-side No Search Match -->
                    <div id="clientNoMatch" class="empty-state" style="display: none;">
                        <h3>No matching public portfolios found</h3>
                        <p>Try searching for a different keyword or clear the search box.</p>
                    </div>

                    <asp:Panel ID="pnlNoPortfolios" runat="server" Visible="false" CssClass="empty-state">
                        <h3><asp:Literal ID="litEmptyDirectoryTitle" runat="server" /></h3>
                        <p><asp:Literal ID="litEmptyDirectoryDescription" runat="server" /></p>
                    </asp:Panel>
                </div>
            </section>
            <asp:Panel ID="pnlPagination" runat="server" CssClass="directory-pagination">
                <asp:Button ID="btnPreviousPage" runat="server" Text="Previous" CssClass="btn btn-outline" OnClick="btnPreviousPage_Click" />
                <span aria-live="polite"><asp:Literal ID="litPageNumber" runat="server" /></span>
                <asp:Button ID="btnNextPage" runat="server" Text="Next" CssClass="btn btn-outline" OnClick="btnNextPage_Click" />
            </asp:Panel>
        </main>

        <footer class="public-footer">
            &copy; <%= DateTime.Now.Year %> Personal Portfolio System. All rights reserved. &bull; <a href="../Login/Login.aspx" style="color: inherit; text-decoration: underline;">Admin &amp; User Login</a>
        </footer>
    </form>


</body>
</html>
