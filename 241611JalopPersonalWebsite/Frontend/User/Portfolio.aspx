<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Portfolio.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Portfolio" %>
<%@ Register Src="~/Frontend/User/Controls/HeroSection.ascx" TagPrefix="uc" TagName="HeroSection" %>
<%@ Register Src="~/Frontend/User/Controls/SummarySection.ascx" TagPrefix="uc" TagName="SummarySection" %>
<%@ Register Src="~/Frontend/User/Controls/EducationSection.ascx" TagPrefix="uc" TagName="EducationSection" %>
<%@ Register Src="~/Frontend/User/Controls/SkillsSection.ascx" TagPrefix="uc" TagName="SkillsSection" %>
<%@ Register Src="~/Frontend/User/Controls/AffiliationsSection.ascx" TagPrefix="uc" TagName="AffiliationsSection" %>
<%@ Register Src="~/Frontend/User/Controls/HobbiesSection.ascx" TagPrefix="uc" TagName="HobbiesSection" %>
<%@ Register Src="~/Frontend/User/Controls/SocialLinksSection.ascx" TagPrefix="uc" TagName="SocialLinksSection" %>
<%@ Register Src="~/Frontend/User/Controls/UserMenu.ascx" TagPrefix="uc" TagName="UserMenu" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><asp:Literal ID="litPageTitle" runat="server" Text="Personal Portfolio" /></title>
    <meta name="description" content="Personal portfolio showcasing educational attainment, professional skills, affiliations, and hobbies." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />

    <link rel="stylesheet" href="../Assets/css/portfolio.css" />
</head>
<body>
    <form id="portfolioForm" runat="server">
        <!-- Top Action Bar -->
        <header class="top-action-bar">
            <div class="bar-container">
                <div class="bar-brand">
                    <div class="brand-badge"><asp:Literal ID="litBrandInitials" runat="server" Text="P" /></div>
                    <span><asp:Literal ID="litBrandName" runat="server" Text="Portfolio" /></span>
                </div>

                <div class="bar-actions">
                    <!-- Export to PDF Button -->
                    <button type="button" class="btn-top-link" id="btnExportPdf" onclick="exportPortfolioToPdf()" title="Export Portfolio to PDF">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: -2px; margin-right: 4px;">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                            <polyline points="7 10 12 15 17 10"></polyline>
                            <line x1="12" y1="15" x2="12" y2="3"></line>
                        </svg>
                        <span>Export PDF</span>
                    </button>

                    <!-- Share / Copy Link Button -->
                    <button type="button" class="btn-top-link" id="btnShareLink" onclick="copyPortfolioLink()" data-share-url="<%= ShareUrl %>" title="Copy Shareable Link">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: -2px; margin-right: 4px;">
                            <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
                            <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
                        </svg>
                        <span id="btnShareText">Share</span>
                    </button>

                    <!-- Admin / Owner Edit Portfolio Button -->
                    <asp:HyperLink ID="lnkAdminEditPortfolio" runat="server" CssClass="btn-top-link" Visible="false" style="font-weight: 700; background-color: #000; color: #fff; text-decoration: none;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: -2px; margin-right: 4px;">
                            <path d="M12 20h9"></path>
                            <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                        </svg>
                        <span>Edit Content</span>
                    </asp:HyperLink>

                    <!-- User Menu (Visible ONLY when logged in) -->
                    <uc:UserMenu ID="ucUserMenu" runat="server" Visible="false" />

                    <!-- Guest Sign In (Visible ONLY when NOT logged in) -->
                    <asp:HyperLink ID="lnkGuestSignIn" runat="server" NavigateUrl="~/Frontend/Login/Login.aspx" CssClass="btn-top-action" Visible="false">
                        Sign In
                    </asp:HyperLink>
                </div>
            </div>
        </header>

        <!-- Main Content Wrapper -->
        <main class="portfolio-wrap">
            <!-- 1. Top Header Card (Hero) -->
            <uc:HeroSection ID="ucHero" runat="server" />

            <!-- 2. Separated Summary Card -->
            <uc:SummarySection ID="ucSummary" runat="server" />

            <!-- 3. 2x2 Bento Grid -->
            <div class="bento-grid">
                <!-- Row 1, Col 1: Educational Attainment Card -->
                <uc:EducationSection ID="ucEducation" runat="server" />

                <!-- Row 1, Col 2: Skills Card -->
                <uc:SkillsSection ID="ucSkills" runat="server" />

                <!-- Row 2, Col 1: Affiliations Card -->
                <uc:AffiliationsSection ID="ucAffiliations" runat="server" />

                <!-- Row 2, Col 2: Hobbies & Interest Card -->
                <uc:HobbiesSection ID="ucHobbies" runat="server" />
            </div>

            <!-- 4. Connect With Me (Bottom-Most) -->
            <uc:SocialLinksSection ID="ucSocialLinks" runat="server" />

            <!-- Footer -->
            <footer class="portfolio-footer">
                <p>&copy; <%= DateTime.Now.Year %> <asp:Literal ID="litFooterName" runat="server" />. All rights reserved.</p>
            </footer>
        </main>
    </form>

    <script src="../Assets/js/portfolio.js"></script>
</body>
</html>
