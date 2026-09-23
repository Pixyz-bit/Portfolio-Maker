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

    <style>
        :root {
            --bg-canvas: #ffffff;
            --dot-color: #cbd5e1;
            --border-black: #000000;
            --border-width: 2.5px;
            --radius-card: 20px;
            --radius-btn: 10px;
            --radius-pill: 999px;
            --text-black: #000000;
            --text-sub: #18181b;
            --text-muted: #52525b;
            --card-bg: #ffffff;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: var(--bg-canvas);
            background-image: radial-gradient(var(--dot-color) 1.2px, transparent 1.2px);
            background-size: 16px 16px;
            color: var(--text-black);
            min-height: 100vh;
            line-height: 1.5;
            -webkit-font-smoothing: antialiased;
        }

        /* Top Action Bar */
        .top-action-bar {
            position: sticky;
            top: 0;
            z-index: 100;
            background-color: #ffffff;
            border-bottom: 2.5px solid var(--border-black);
            padding: 12px 24px;
        }

        .bar-container {
            max-width: 980px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .bar-brand {
            font-size: 1.05rem;
            font-weight: 800;
            letter-spacing: -0.02em;
            color: var(--text-black);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .brand-badge {
            width: 30px;
            height: 30px;
            background-color: #000000;
            color: #ffffff;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            font-weight: 800;
        }

        .bar-actions {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-top-link {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--text-muted);
            text-decoration: none;
            padding: 6px 12px;
            border-radius: 8px;
            transition: color 0.15s ease;
        }

        .btn-top-link:hover {
            color: #000000;
        }

        .btn-top-action {
            background-color: #000000;
            color: #ffffff;
            padding: 6px 16px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 700;
            text-decoration: none;
            border: 2px solid #000000;
            transition: all 0.15s ease;
        }

        .btn-top-action:hover {
            background-color: #ffffff;
            color: #000000;
        }

        /* Portfolio Layout Wrap */
        .portfolio-wrap {
            max-width: 980px;
            margin: 0 auto;
            padding: 32px 20px 80px;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /* Bento Cards (Monochromatic Dot Matrix) */
        .bento-card {
            background-color: var(--card-bg);
            background-image: radial-gradient(var(--dot-color) 1.2px, transparent 1.2px);
            background-size: 16px 16px;
            border: var(--border-width) solid var(--border-black);
            border-radius: var(--radius-card);
            padding: 34px 38px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
            display: flex;
            flex-direction: column;
        }
        .card-title {
            font-size: 1.45rem;
            font-weight: 800;
            letter-spacing: -0.02em;
            color: var(--text-black);
            margin-bottom: 16px;
        }

        /* 2x2 Bento Grid Container */
        .bento-grid {
            display: grid;
            grid-template-columns: 1.35fr 1fr;
            gap: 24px;
        }

        /* Empty State */
        .empty-text {
            color: var(--text-muted);
            font-size: 0.92rem;
            font-style: italic;
        }

        /* Footer */
        .portfolio-footer {
            text-align: center;
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-top: 10px;
        }

        /* Responsive Breakpoints */
        @media (max-width: 840px) {
            .bento-grid {
                grid-template-columns: 1fr;
            }

            .bento-card {
                padding: 26px 22px;
            }
        }
    </style>
</head>
<body>
    <form id="portfolioForm" runat="server">
        <!-- Top Action Bar -->
        <header class="top-action-bar">
            <div class="bar-container">
                <asp:HyperLink ID="lnkBrand" runat="server" NavigateUrl="Dashboard.aspx" CssClass="bar-brand">
                    <div class="brand-badge"><asp:Literal ID="litBrandInitials" runat="server" Text="P" /></div>
                    <span><asp:Literal ID="litBrandName" runat="server" Text="Portfolio" /></span>
                </asp:HyperLink>

                <div class="bar-actions">
                    <!-- Share / Copy Link Button -->
                    <button type="button" class="btn-top-link" id="btnShareLink" onclick="copyPortfolioLink()" data-share-url="<%= ShareUrl %>" title="Copy Shareable Link">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: -2px; margin-right: 4px;">
                            <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"></path>
                            <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"></path>
                        </svg>
                        <span id="btnShareText">Share</span>
                    </button>


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

    <script>
        function copyPortfolioLink() {
            var btn = document.getElementById("btnShareLink");
            var url = (btn && btn.getAttribute("data-share-url")) ? btn.getAttribute("data-share-url") : window.location.href;

            if (navigator.clipboard && window.isSecureContext) {
                navigator.clipboard.writeText(url).then(function () {
                    showCopiedFeedback();
                }).catch(function () {
                    fallbackCopy(url);
                });
            } else {
                fallbackCopy(url);
            }
        }

        function fallbackCopy(text) {
            var textArea = document.createElement("textarea");
            textArea.value = text;
            textArea.style.position = "fixed";
            textArea.style.left = "-9999px";
            textArea.style.top = "0";
            textArea.style.opacity = "0";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            try {
                var successful = document.execCommand('copy');
                if (successful) {
                    showCopiedFeedback();
                } else {
                    prompt("Copy this portfolio link:", text);
                }
            } catch (err) {
                prompt("Copy this portfolio link:", text);
            }
            document.body.removeChild(textArea);
        }

        function showCopiedFeedback() {
            var span = document.getElementById("btnShareText");
            if (span) {
                var oldText = span.innerText;
                span.innerText = "Link Copied!";
                setTimeout(function () { span.innerText = oldText; }, 2500);
            }
        }

        // Sync browser address bar with canonical share URL if userId param was not already present
        (function () {
            var shareUrl = "<%= ShareUrl %>";
            if (shareUrl && window.history && window.history.replaceState) {
                try {
                    var current = new URL(window.location.href);
                    if (!current.searchParams.has("userId")) {
                        window.history.replaceState(null, document.title, shareUrl);
                    }
                } catch (e) { }
            }
        })();
    </script>
</body>
</html>
