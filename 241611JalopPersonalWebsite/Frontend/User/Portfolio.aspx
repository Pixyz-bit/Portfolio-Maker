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
    <link rel="stylesheet" href="<%= Page.ResolveUrl("~/Frontend/Assets/fonts/fonts.css") %>" />

    <link rel="stylesheet" href="<%= Page.ResolveUrl("~/Frontend/Assets/css/portfolio.css") %>?v=<%= DateTime.UtcNow.Ticks %>" />
    <link rel="stylesheet" href="<%= Page.ResolveUrl("~/Frontend/Assets/css/user-menu.css") %>?v=<%= DateTime.UtcNow.Ticks %>" />

    <style>
        /* Top Navigation Button System matching nav-actions */
        .bar-actions {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .bar-actions .btn,
        .bar-actions a.btn,
        .bar-actions button.btn {
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 6px !important;
            font-family: 'Plus Jakarta Sans', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif !important;
            font-size: 0.8rem !important;
            font-weight: 800 !important;
            padding: 6px 14px !important;
            border-radius: 10px !important;
            cursor: pointer !important;
            text-decoration: none !important;
            transition: all 0.2s ease !important;
            white-space: nowrap !important;
            outline: none !important;
            line-height: 1.2 !important;
            box-sizing: border-box !important;
            border: 2px solid #000000 !important;
            -webkit-appearance: none !important;
            appearance: none !important;
        }

        .bar-actions .btn svg,
        .bar-actions a.btn svg,
        .bar-actions button.btn svg {
            width: 14px !important;
            height: 14px !important;
            flex-shrink: 0 !important;
            display: inline-block !important;
            vertical-align: middle !important;
            stroke: currentColor !important;
        }

        /* Outline Variant (Export PDF, Share, Explore, Sign In) */
        .bar-actions .btn-outline,
        .bar-actions a.btn-outline,
        .bar-actions button.btn-outline {
            background-color: #ffffff !important;
            color: #000000 !important;
            border: 2px solid #000000 !important;
        }

        .bar-actions .btn-outline:hover,
        .bar-actions a.btn-outline:hover,
        .bar-actions button.btn-outline:hover {
            background-color: #000000 !important;
            color: #ffffff !important;
            border-color: #000000 !important;
        }

        .bar-actions .btn-outline:hover svg,
        .bar-actions a.btn-outline:hover svg,
        .bar-actions button.btn-outline:hover svg {
            stroke: #ffffff !important;
        }

        /* Solid Variant (Edit Content) */
        .bar-actions .btn-solid,
        .bar-actions a.btn-solid,
        .bar-actions button.btn-solid {
            background-color: #000000 !important;
            color: #ffffff !important;
            border: 2px solid #000000 !important;
        }

        .bar-actions .btn-solid:hover,
        .bar-actions a.btn-solid:hover,
        .bar-actions button.btn-solid:hover {
            background-color: #27272a !important;
            border-color: #27272a !important;
            color: #ffffff !important;
        }

        .bar-actions .btn-solid svg,
        .bar-actions a.btn-solid svg,
        .bar-actions button.btn-solid svg {
            stroke: #ffffff !important;
        }

        .bar-actions .btn-sm {
            padding: 6px 12px !important;
            font-size: 0.8rem !important;
        }

        @media (max-width: 640px) {
            .bar-actions {
                flex-wrap: wrap;
                justify-content: center;
                gap: 8px;
            }
            .bar-actions .btn {
                padding: 5px 10px !important;
                font-size: 0.75rem !important;
            }
        }

        .owner-private-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background-color: #fef3c7;
            color: #92400e;
            border: 2px solid #000000;
            border-radius: 8px;
            padding: 5px 10px;
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            line-height: 1;
        }

        .private-portfolio-card {
            background-color: #ffffff;
            border: 2.5px solid #000000;
            border-radius: 20px;
            box-shadow: 6px 6px 0px #000000;
            max-width: 540px;
            margin: 60px auto;
            padding: 48px 32px;
            text-align: center;
        }

        .private-icon-wrap {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background-color: #fef3c7;
            border: 2px solid #000000;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            color: #92400e;
        }

        .private-title {
            font-family: 'Plus Jakarta Sans', sans-serif;
            font-size: 1.55rem;
            font-weight: 800;
            color: #000000;
            margin: 0 0 10px;
            letter-spacing: -0.02em;
        }

        .private-desc {
            font-size: 0.92rem;
            color: #52525b;
            line-height: 1.55;
            margin: 0 0 28px;
        }

        .private-actions {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            flex-wrap: wrap;
        }
    </style>
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
                    <button type="button" class="btn btn-outline btn-sm" id="btnExportPdf" onclick="exportPortfolioToPdf()" title="Export Portfolio to PDF">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                            <polyline points="7 10 12 15 17 10"></polyline>
                            <line x1="12" y1="15" x2="12" y2="3"></line>
                        </svg>
                        <span>Export PDF</span>
                    </button>

                    <!-- Share / Copy Link Button -->
                    <button type="button" class="btn btn-outline btn-sm" id="btnShareLink" onclick="copyPortfolioLink()" data-share-url="<%= ShareUrl %>" title="Copy Shareable Link">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
                            <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
                        </svg>
                        <span id="btnShareText">Share</span>
                    </button>

                    <!-- Explore Public Portfolios Directory -->
                    <a href="PublicDashboard.aspx" class="btn btn-outline btn-sm" title="Explore Public Portfolios Directory">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="12" cy="12" r="10"></circle>
                            <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon>
                        </svg>
                        <span>Explore</span>
                    </a>

                    <!-- Admin / Owner Edit Portfolio Button -->
                    <asp:HyperLink ID="lnkAdminEditPortfolio" runat="server" CssClass="btn btn-solid btn-sm" Visible="false">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M12 20h9"></path>
                            <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
                        </svg>
                        <span>Edit Content</span>
                    </asp:HyperLink>

                    <!-- Owner / Admin Private Indicator Badge -->
                    <asp:Panel ID="pnlOwnerPrivateIndicator" runat="server" Visible="false" CssClass="owner-private-badge" ToolTip="Your portfolio is currently set to Private. Only you and administrators can view it.">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                        <span>Private</span>
                    </asp:Panel>

                    <!-- User Menu (Visible ONLY when logged in) -->
                    <uc:UserMenu ID="ucUserMenu" runat="server" Visible="false" />

                    <!-- Guest Sign In (Visible ONLY when NOT logged in) -->
                    <asp:HyperLink ID="lnkGuestSignIn" runat="server" NavigateUrl="~/Frontend/Login/Login.aspx" CssClass="btn btn-outline btn-sm" Visible="false">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
                            <polyline points="10 17 15 12 10 7"></polyline>
                            <line x1="15" y1="12" x2="3" y2="12"></line>
                        </svg>
                        <span>Sign In</span>
                    </asp:HyperLink>
                </div>
            </div>
        </header>

        <!-- Main Content Wrapper -->
        <main class="portfolio-wrap">
            <!-- Private Portfolio Notice for Unauthorized Visitors -->
            <asp:Panel ID="pnlPrivateNotice" runat="server" Visible="false" CssClass="private-portfolio-card">
                <div class="private-icon-wrap">
                    <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </svg>
                </div>
                <h2 class="private-title">This Portfolio is Private</h2>
                <p class="private-desc">
                    <asp:Literal ID="litPrivateOwnerName" runat="server" Text="The user" /> has chosen to keep this portfolio private.
                    Only the owner and administrators have permission to access its content.
                </p>
                <div class="private-actions">
                    <a href="PublicDashboard.aspx" class="btn btn-solid btn-sm">Explore Public Portfolios</a>
                    <asp:HyperLink ID="lnkPrivateSignIn" runat="server" NavigateUrl="~/Frontend/Login/Login.aspx" CssClass="btn btn-outline btn-sm">
                        Owner Sign In
                    </asp:HyperLink>
                </div>
            </asp:Panel>

            <!-- Main Portfolio Content (Visible if Public OR Viewer is Owner/Admin) -->
            <asp:Panel ID="pnlPortfolioMain" runat="server" CssClass="portfolio-main">
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
            </asp:Panel>
        </main>
    </form>

    <script src="../Assets/js/portfolio.js"></script>
</body>
</html>
