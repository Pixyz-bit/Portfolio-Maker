<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Portfolio.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Portfolio" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><asp:Literal ID="litPageTitle" runat="server" Text="Personal Portfolio" /></title>
    <meta name="description" content="Personal portfolio showcasing educational attainment, professional skills, affiliations, and hobbies." />

    <!-- Google Fonts: Plus Jakarta Sans & Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

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
            background-color: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(8px);
            border-bottom: 2px solid var(--border-black);
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

        /* 1. Header Card (Top Full-Width) */
        .header-card {
            display: flex;
            flex-direction: row;
            justify-content: space-between;
            align-items: center;
            gap: 32px;
        }

        .header-left {
            flex: 1;
            min-width: 0;
        }

        .header-name {
            font-size: 2.75rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            line-height: 1.15;
            color: var(--text-black);
            margin-bottom: 18px;
            word-wrap: break-word;
        }

        .header-meta-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.05fr) minmax(0, 1.25fr);
            column-gap: 36px;
            row-gap: 10px;
            align-items: start;
        }

        .meta-col {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .detail-row {
            display: block;
            font-size: 1.02rem;
            line-height: 1.45;
        }

        .detail-label {
            font-weight: 800;
            color: var(--text-black);
            margin-right: 5px;
            display: inline;
        }

        .detail-value {
            font-weight: 500;
            color: var(--text-black);
            display: inline;
            word-break: break-word;
        }

        .detail-value a {
            color: var(--text-black);
            text-decoration: none;
        }

        .detail-value a:hover {
            text-decoration: underline;
        }

        .header-right {
            flex-shrink: 0;
        }

        .profile-photo {
            width: 170px;
            height: 170px;
            aspect-ratio: 1 / 1;
            object-fit: cover;
            border: 2px solid var(--border-black);
            border-radius: 12px;
            display: block;
            background-color: #f4f4f5;
        }

        /* 2. Summary Card (Full-Width, Separated) */
        .summary-card {
            padding: 34px 38px;
        }

        .card-title {
            font-size: 1.45rem;
            font-weight: 800;
            letter-spacing: -0.02em;
            color: var(--text-black);
            margin-bottom: 16px;
        }

        .summary-text {
            font-size: 1.02rem;
            font-weight: 400;
            color: var(--text-black);
            line-height: 1.65;
            white-space: pre-line;
        }

        /* 3. Connect With Me (Pill Stadium Bar) */
        .connect-bar {
            background-color: var(--card-bg);
            background-image: radial-gradient(var(--dot-color) 1.2px, transparent 1.2px);
            background-size: 16px 16px;
            border: var(--border-width) solid var(--border-black);
            border-radius: var(--radius-pill);
            padding: 12px 30px;
            display: flex;
            align-items: center;
            gap: 20px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.03);
        }

        .connect-title {
            font-size: 1.25rem;
            font-weight: 800;
            color: var(--text-black);
            letter-spacing: -0.02em;
            white-space: nowrap;
        }

        .connect-links {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 10px;
        }

        .social-pill-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 6px 15px;
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            border-radius: var(--radius-pill);
            color: var(--text-black);
            font-size: 0.92rem;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
            line-height: 1.2;
        }

        .social-pill-btn:hover {
            background-color: #000000;
            color: #ffffff;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .social-pill-btn svg {
            flex-shrink: 0;
            display: block;
        }

        /* 3. 2x2 Bento Grid */
        .bento-grid {
            display: grid;
            grid-template-columns: 1.35fr 1fr;
            gap: 24px;
        }

        /* Timeline Items (Education & Affiliations) */
        .timeline-list {
            display: flex;
            flex-direction: column;
            flex-grow: 1;
        }

        .timeline-item {
            position: relative;
            padding-left: 32px;
            padding-bottom: 26px;
        }

        .timeline-item:last-child {
            padding-bottom: 0;
        }

        /* Vertical connector line */
        .timeline-item::before {
            content: '';
            position: absolute;
            left: 5px;
            top: 17px;
            bottom: -6px;
            width: 1.5px;
            background-color: #000000;
        }

        .timeline-item:last-child::before {
            display: none;
        }

        /* Hollow circle node */
        .timeline-item::after {
            content: '';
            position: absolute;
            left: 0;
            top: 4px;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            border: 1.8px solid #000000;
            background-color: #ffffff;
            box-sizing: border-box;
        }

        .timeline-row {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            gap: 16px;
        }

        .timeline-primary {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text-black);
            line-height: 1.35;
        }

        .timeline-period {
            font-size: 0.98rem;
            font-weight: 700;
            color: var(--text-black);
            white-space: nowrap;
            text-align: right;
            line-height: 1.35;
        }

        .timeline-sub {
            font-size: 0.95rem;
            font-weight: 400;
            color: var(--text-black);
            margin-top: 3px;
            line-height: 1.4;
        }

        /* Text List Items (Skills & Hobbies) */
        .list-group {
            display: flex;
            flex-direction: column;
            gap: 22px;
            flex-grow: 1;
        }

        .list-item {
            display: flex;
            flex-direction: column;
        }

        .list-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text-black);
            line-height: 1.35;
        }

        .list-desc {
            font-size: 0.95rem;
            font-weight: 400;
            color: var(--text-black);
            margin-top: 3px;
            line-height: 1.45;
            white-space: pre-line;
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

            .header-card {
                flex-direction: column-reverse;
                align-items: flex-start;
                gap: 20px;
            }

            .header-meta-grid {
                grid-template-columns: 1fr;
                gap: 10px;
            }

            .profile-photo {
                width: 140px;
                height: 140px;
            }

            .header-name {
                font-size: 2.1rem;
            }

            .bento-card {
                padding: 26px 22px;
            }

            .timeline-row {
                flex-direction: column;
                gap: 2px;
            }

            .timeline-period {
                text-align: left;
                font-size: 0.9rem;
                color: var(--text-muted);
            }

            .connect-bar {
                border-radius: 20px;
                flex-direction: column;
                align-items: flex-start;
                padding: 22px 20px;
                gap: 12px;
            }
        }
    </style>
</head>
<body>
    <form id="portfolioForm" runat="server">
        <!-- Top Action Bar -->
        <header class="top-action-bar">
            <div class="bar-container">
                <a href="Dashboard.aspx" class="bar-brand">
                    <div class="brand-badge"><asp:Literal ID="litBrandInitials" runat="server" Text="P" /></div>
                    <span><asp:Literal ID="litBrandName" runat="server" Text="Portfolio" /></span>
                </a>

                <div class="bar-actions">
                    <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="Dashboard.aspx" CssClass="btn-top-link" Visible="false">
                        Dashboard
                    </asp:HyperLink>
                    <asp:HyperLink ID="lnkEditPortfolio" runat="server" NavigateUrl="Onboarding.aspx" CssClass="btn-top-action" Visible="false">
                        Edit Portfolio
                    </asp:HyperLink>
                </div>
            </div>
        </header>

        <!-- Main Content Wrapper -->
        <main class="portfolio-wrap">
            <!-- ========================================================= -->
            <!-- 1. TOP HEADER CARD                                        -->
            <!-- ========================================================= -->
            <section class="bento-card header-card">
                <div class="header-left">
                    <h1 class="header-name"><asp:Literal ID="litFullName" runat="server" Text="Full Name" /></h1>

                    <div class="header-meta-grid">
                        <!-- Left Column: Birthday & Address -->
                        <div class="meta-col">
                            <asp:Panel ID="rowBirthday" runat="server" CssClass="detail-row">
                                <span class="detail-label">Birthday:</span>
                                <span class="detail-value"><asp:Literal ID="litBirthday" runat="server" /></span>
                            </asp:Panel>

                            <asp:Panel ID="rowAddress" runat="server" CssClass="detail-row">
                                <span class="detail-label">Address:</span>
                                <span class="detail-value"><asp:Literal ID="litAddress" runat="server" /></span>
                            </asp:Panel>
                        </div>

                        <!-- Right Column: Contact# & Email -->
                        <div class="meta-col">
                            <asp:Panel ID="rowContact" runat="server" CssClass="detail-row">
                                <span class="detail-label">Contact#:</span>
                                <span class="detail-value"><asp:Literal ID="litContact" runat="server" /></span>
                            </asp:Panel>

                            <asp:Panel ID="rowEmail" runat="server" CssClass="detail-row">
                                <span class="detail-label">Email:</span>
                                <span class="detail-value"><asp:Literal ID="litEmail" runat="server" /></span>
                            </asp:Panel>
                        </div>
                    </div>
                </div>

                <div class="header-right">
                    <asp:Image ID="imgAvatar" runat="server" CssClass="profile-photo" AlternateText="Profile Picture" ImageUrl="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='170' height='170' viewBox='0 0 24 24' fill='none' stroke='%23000' stroke-width='1.5'><path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'></path><circle cx='12' cy='7' r='4'></circle></svg>" />
                </div>
            </section>

            <!-- ========================================================= -->
            <!-- 2. SEPARATED SUMMARY CARD                                 -->
            <!-- ========================================================= -->
            <asp:Panel ID="pnlSummary" runat="server" CssClass="bento-card summary-card">
                <h2 class="card-title">Summary</h2>
                <p class="summary-text">
                    <asp:Literal ID="litSummary" runat="server" />
                </p>
            </asp:Panel>

            <!-- ========================================================= -->
            <!-- 3. 2x2 BENTO GRID (MATCHING TARGET DESIGN)                -->
            <!-- ========================================================= -->
            <div class="bento-grid">
                <!-- Row 1, Col 1: Educational Attainment Card -->
                <section class="bento-card">
                    <h2 class="card-title">Educational Attainment</h2>

                    <asp:Repeater ID="rptEducation" runat="server">
                        <HeaderTemplate>
                            <div class="timeline-list">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="timeline-item">
                                <div class="timeline-row">
                                    <span class="timeline-primary"><%# Eval("CourseName") %></span>
                                    <span class="timeline-period"><%# FormatPeriod(Eval("StartYear"), Eval("EndYear")) %></span>
                                </div>
                                <div class="timeline-sub"><%# Eval("University") %></div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoEducation" runat="server" Visible="false">
                        <p class="empty-text">No educational background added yet.</p>
                    </asp:Panel>
                </section>

                <!-- Row 1, Col 2: Skills Card -->
                <section class="bento-card">
                    <h2 class="card-title">Skills</h2>

                    <asp:Repeater ID="rptSkills" runat="server">
                        <HeaderTemplate>
                            <div class="list-group">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="list-item">
                                <div class="list-title"><%# Eval("SkillName") %></div>
                                <div class="list-desc"><%# Eval("SkillDescription") %></div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoSkills" runat="server" Visible="false">
                        <p class="empty-text">No technical skills added yet.</p>
                    </asp:Panel>
                </section>

                <!-- Row 2, Col 1: Affiliations Card -->
                <section class="bento-card">
                    <h2 class="card-title">Affiliations</h2>

                    <asp:Repeater ID="rptAffiliations" runat="server">
                        <HeaderTemplate>
                            <div class="timeline-list">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="timeline-item">
                                <div class="timeline-row">
                                    <span class="timeline-primary"><%# Eval("Position") %></span>
                                    <span class="timeline-period"><%# FormatPeriod(Eval("StartYear"), Eval("EndYear")) %></span>
                                </div>
                                <div class="timeline-sub"><%# Eval("OrganizationName") %></div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoAffiliations" runat="server" Visible="false">
                        <p class="empty-text">No organization affiliations added yet.</p>
                    </asp:Panel>
                </section>

                <!-- Row 2, Col 2: Hobbies & Interest Card -->
                <section class="bento-card">
                    <h2 class="card-title">Hobbies &amp; Interest</h2>

                    <asp:Repeater ID="rptHobbies" runat="server">
                        <HeaderTemplate>
                            <div class="list-group">
                        </HeaderTemplate>
                        <ItemTemplate>
                            <div class="list-item">
                                <div class="list-title"><%# Eval("HobbyName") %></div>
                                <div class="list-desc"><%# Eval("HobbyDescription") %></div>
                            </div>
                        </ItemTemplate>
                        <FooterTemplate>
                            </div>
                        </FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoHobbies" runat="server" Visible="false">
                        <p class="empty-text">No hobbies added yet.</p>
                    </asp:Panel>
                </section>
            </div>

            <!-- ========================================================= -->
            <!-- 4. CONNECT WITH ME (PILL STADIUM BAR - BOTTOM MOST)       -->
            <!-- ========================================================= -->
            <asp:Panel ID="pnlConnect" runat="server" CssClass="connect-bar">
                <span class="connect-title">Connect with me!</span>
                <div class="connect-links">
                    <asp:Repeater ID="rptSocialLinks" runat="server">
                        <ItemTemplate>
                            <a href='<%# Eval("Link") %>' target="_blank" rel="noopener noreferrer" class="social-pill-btn">
                                <%# GetSocialIcon(Eval("SocialLinkName") as string) %>
                                <span><%# Eval("SocialLinkName") %></span>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <!-- Footer -->
            <footer class="portfolio-footer">
                <p>&copy; <%= DateTime.Now.Year %> <asp:Literal ID="litFooterName" runat="server" />. All rights reserved.</p>
            </footer>
        </main>
    </form>
</body>
</html>
