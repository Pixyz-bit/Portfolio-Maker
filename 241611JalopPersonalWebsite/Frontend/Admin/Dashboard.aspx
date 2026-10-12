<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.Admin.Dashboard" %>
<%@ Register Src="~/Frontend/User/Controls/UserMenu.ascx" TagPrefix="uc" TagName="UserMenu" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Console | Portfolio OS</title>
    <meta name="description" content="Administrator dashboard for user management, system analytics, and account administration." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />

    <link rel="stylesheet" href="../Assets/css/admin-dashboard.css" />
</head>
<body>
    <form id="adminForm" runat="server">
        <nav class="admin-nav">
            <div class="nav-inner">
                <a href="Dashboard.aspx" class="nav-brand">
                    <span class="brand-badge"><!--<svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" style="display:inline-block; vertical-align:-1px; margin-right:3px;"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>-->ADMIN</span>
                    <span class="brand-title">Dashboard</span>
                </a>

                <div class="nav-user" style="display: flex; align-items: center; gap: 14px;">
                    <asp:Literal ID="litAdminName" runat="server" Visible="false" />
                    <asp:HyperLink ID="lnkViewPublicPortfolio" runat="server" NavigateUrl="../User/Portfolio.aspx" Target="_blank" CssClass="btn btn-outline btn-sm" Visible="false">
                        View Portfolio
                    </asp:HyperLink>
                    <uc:UserMenu ID="ucUserMenu" runat="server" />
                </div>
            </div>
        </nav>

        <main class="admin-main">
            <div class="page-header">
                <div>
                    <h1 class="page-title">System Dashboard & User Directory</h1>
                    <p class="page-subtitle">Track active accounts, manage privileges, and review user portfolios.</p>
                </div>
                <div style="display: flex; gap: 8px;">
                    <a href="../User/PublicDashboard.aspx" class="btn btn-outline btn-sm">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon></svg>
                        Public Showcase
                    </a>
                    <button type="button" class="btn btn-solid btn-sm" onclick="openAddModal()">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        Add New User
                    </button>
                </div>
            </div>

            <div class="toast-container" id="toastContainer">
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="toast-box toast-success">
                    <div class="toast-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div class="toast-content">
                        <span class="toast-title">Success</span>
                        <span class="toast-message"><asp:Literal ID="lblSuccessMessage" runat="server" /></span>
                    </div>
                    <button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
                </asp:Panel>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="toast-box toast-error">
                    <div class="toast-icon">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                    </div>
                    <div class="toast-content">
                        <span class="toast-title">Error</span>
                        <span class="toast-message"><asp:Literal ID="lblErrorMessage" runat="server" /></span>
                    </div>
                    <button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
                </asp:Panel>
            </div>

            <section class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-top">
                        <span class="metric-label">Total Registered</span>
                        <!--<div class="metric-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                        </div>-->
                    </div>
                    <div class="metric-value">
                        <asp:Literal ID="litTotalUsers" runat="server" Text="0" />
                    </div>
                    <div class="metric-desc">Total user accounts in dbo.Users</div>
                </div>

                <div class="metric-card">
                    <div class="metric-top">
                        <span class="metric-label">Active Users</span>
                        <!--<div class="metric-icon" style="background-color: #dcfce7;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#15803d" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                        </div>-->
                    </div>
                    <div class="metric-value" style="color: #15803d;">
                        <asp:Literal ID="litTotalActive" runat="server" Text="0" />
                    </div>
                    <div class="metric-desc">Enabled accounts permitted to authenticate</div>
                </div>

                <div class="metric-card">
                    <div class="metric-top">
                        <span class="metric-label">Deactivated Users</span>
                        <!--<div class="metric-icon" style="background-color: #fee2e2;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#b91c1c" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                        </div>-->
                    </div>
                    <div class="metric-value" style="color: #b91c1c;">
                        <asp:Literal ID="litTotalInactive" runat="server" Text="0" />
                    </div>
                    <div class="metric-desc">Suspended or disabled user accounts</div>
                </div>
            </section>

            <section class="content-card">
                <div class="table-toolbar">
                    <div class="filter-group">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="input-box search-input" placeholder="Search by name or email address..." autocomplete="off" />
                        
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="select-box">
                            <asp:ListItem Value="" Text="All Statuses" />
                            <asp:ListItem Value="active" Text="Active Accounts" />
                            <asp:ListItem Value="inactive" Text="Deactivated Accounts" />
                        </asp:DropDownList>

                        <asp:DropDownList ID="ddlRoleFilter" runat="server" CssClass="select-box">
                            <asp:ListItem Value="" Text="All Roles" />
                            <asp:ListItem Value="admin" Text="Administrators" />
                            <asp:ListItem Value="user" Text="Standard Users" />
                        </asp:DropDownList>

                        <asp:Button ID="btnResetFilter" runat="server" Text="Reset Filters" CssClass="btn btn-outline btn-sm" OnClientClick="resetClientUserFilters(); return false;" />
                    </div>
                </div>

                <div class="table-responsive">
                    <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                        <HeaderTemplate>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>User Account (Click to View Summary)</th>
                                        <th>Role</th>
                                        <th>Status</th>
                                        <th>Registered Date</th>
                                        <th style="text-align: right;">Management Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr class="user-data-row" 
                                data-name="<%# Server.HtmlEncode((Eval("FullName")?.ToString() ?? "").ToLowerInvariant()) %>" 
                                data-email="<%# Server.HtmlEncode((Eval("Email")?.ToString() ?? "").ToLowerInvariant()) %>" 
                                data-role="<%# Server.HtmlEncode((Eval("Role")?.ToString() ?? "").ToLowerInvariant()) %>" 
                                data-status="<%# (bool)Eval("IsActive") ? "active" : "inactive" %>">
                                <td data-label="User Account">
                                    <asp:LinkButton ID="btnUserClick" runat="server" 
                                        CommandName="ViewSummary" 
                                        CommandArgument='<%# Eval("UserID") %>' 
                                        CssClass="user-cell-btn" 
                                        ToolTip="Click to view comprehensive user summary">
                                        <div class="user-initials">
                                            <%# GetInitials(Eval("FirstName")?.ToString(), Eval("LastName")?.ToString(), Eval("Email")?.ToString()) %>
                                        </div>
                                        <div>
                                            <div class="user-name-cell">
                                                <%# Eval("FullName") %>
                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="2"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
                                            </div>
                                            <div class="user-email-cell">
                                                <%# Eval("Email") %>
                                            </div>
                                        </div>
                                    </asp:LinkButton>
                                </td>
                                <td data-label="Role">
                                    <span class="badge <%# string.Equals(Eval("Role")?.ToString(), "Admin", StringComparison.OrdinalIgnoreCase) ? "badge-admin" : "badge-user" %>">
                                        <%# Eval("Role") %>
                                    </span>
                                </td>
                                <td data-label="Status">
                                    <span class="badge <%# (bool)Eval("IsActive") ? "badge-active" : "badge-inactive" %>">
                                        <span class="status-dot"></span>
                                        <%# (bool)Eval("IsActive") ? "Active" : "Deactivated" %>
                                    </span>
                                </td>
                                <td data-label="Registered">
                                    <%# FormatPhilippineTimeTwoRows(Eval("CreatedAt")) %>
                                </td>
                                <td data-label="Actions" style="white-space: nowrap; text-align: right;">
                                    <div class="actions-cell" style="justify-content: flex-end; flex-wrap: nowrap; white-space: nowrap; gap: 6px;">
                                        <button type="button" 
                                            class='<%# (bool)Eval("IsActive") ? "btn btn-danger btn-sm" : "btn btn-success btn-sm" %>'
                                            onclick='openStatusModal(<%# Eval("UserID") %>, "<%# Server.HtmlEncode(Eval("FullName")?.ToString() ?? Eval("FirstName")?.ToString()) %>", "<%# Server.HtmlEncode(Eval("Email")?.ToString()) %>", <%# Eval("IsActive").ToString().ToLower() %>)'>
                                            <%# (bool)Eval("IsActive") ? "Deactivate" : "Activate" %>
                                        </button>

                                        <a href='<%# ResolveUrl($"~/Frontend/User/Onboarding.aspx?u={_241611JalopPersonalWebsite.Backend.Common.UrlObfuscator.EncodeUserId(Convert.ToInt32(Eval("UserID")))}") %>'
                                            class="btn btn-solid btn-sm"
                                            title="Edit user portfolio content">
                                            Edit Content
                                        </a>

                                        <button type="button" class="btn btn-outline btn-sm"
                                            onclick='openEditModal(<%# Eval("UserID") %>, "<%# Server.HtmlEncode(Eval("FirstName")?.ToString()) %>", "<%# Server.HtmlEncode(Eval("LastName")?.ToString()) %>", "<%# Server.HtmlEncode(Eval("Email")?.ToString()) %>", "<%# Eval("Role") %>", <%# Eval("IsActive").ToString().ToLower() %>)'
                                            title="Edit user account credentials and role">
                                            Account
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <div id="clientNoUsers" class="empty-state" style="display: none;">
                        <div class="empty-icon">
                            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        </div>
                        <h4 style="margin-bottom: 4px;">No users match your criteria</h4>
                        <p>Try adjusting your search keywords or resetting the status and role filters.</p>
                    </div>

                    <asp:Panel ID="pnlNoUsers" runat="server" Visible="false" CssClass="empty-state">
                        <div class="empty-icon">
                            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="1.5"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                        </div>
                        <h4 style="margin-bottom: 4px;">No users in database</h4>
                        <p>No user records are currently registered.</p>
                    </asp:Panel>
                </div>
            </section>
        </main>

        <asp:Panel ID="pnlUserSummaryModal" runat="server" Visible="false" CssClass="modal-overlay active">
            <div class="modal-box modal-box-lg">
                <asp:LinkButton ID="btnCloseSummaryX" runat="server" CssClass="close-modal-btn" OnClick="btnCloseSummary_Click">&times;</asp:LinkButton>
                
                <h3 class="modal-title">User Account Summary</h3>
                <p class="modal-desc">Detailed profile information, activity statistics, and administrative controls.</p>

                <asp:HiddenField ID="hfSummaryUserId" runat="server" />
                <asp:HiddenField ID="hfSummaryCurrentStatus" runat="server" />
                <asp:HiddenField ID="hfSummaryFirstName" runat="server" />
                <asp:HiddenField ID="hfSummaryLastName" runat="server" />
                <asp:HiddenField ID="hfSummaryEmailRaw" runat="server" />
                <asp:HiddenField ID="hfSummaryRoleRaw" runat="server" />

                <div class="summary-header-card">
                    <div class="summary-avatar">
                        <asp:Literal ID="litSummaryAvatarInitials" runat="server" Text="U" />
                    </div>
                    <div style="flex: 1;">
                        <h4 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 2px;">
                            <asp:Literal ID="litSummaryFullName" runat="server" />
                        </h4>
                        <p style="font-size: 0.88rem; color: var(--text-muted); margin-bottom: 8px;">
                            <asp:Literal ID="litSummaryEmail" runat="server" />
                        </p>
                        <div style="display: flex; gap: 8px; flex-wrap: wrap;">
                            <asp:Literal ID="litSummaryRoleBadge" runat="server" />
                            <asp:Literal ID="litSummaryStatusBadge" runat="server" />
                        </div>
                    </div>
                </div>

                <div class="summary-stats-bar">
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummaryEduCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Education</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummarySkillCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Skills</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummaryHobbyCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Hobbies</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummaryAffilCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Affiliations</div>
                    </div>
                    <div class="summary-stat-box">
                        <div class="summary-stat-num"><asp:Literal ID="litSummarySocialCount" runat="server" Text="0" /></div>
                        <div class="summary-stat-title">Socials</div>
                    </div>
                </div>

                <div class="summary-details-grid">
                    <div class="summary-item">
                        <div class="summary-item-label">User ID</div>
                        <div class="summary-item-value">#<asp:Literal ID="litSummaryUserId" runat="server" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Contact Email</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryContactEmail" runat="server" Text="None" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Phone Number</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryContactNum" runat="server" Text="None" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Address</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryAddress" runat="server" Text="None" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Birthday / Age</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryBirthday" runat="server" Text="Not specified" /></div>
                    </div>
                    <div class="summary-item">
                        <div class="summary-item-label">Registered On</div>
                        <div class="summary-item-value"><asp:Literal ID="litSummaryCreatedAt" runat="server" /></div>
                    </div>
                </div>

                <div class="summary-section-box">
                    <div class="summary-section-title">Personal Biography & Portfolio Intro</div>
                    <p style="font-size: 0.88rem; color: #334155; line-height: 1.55;">
                        <asp:Literal ID="litSummaryBio" runat="server" Text="No personal biography provided." />
                    </p>
                </div>

                <div class="summary-section-box">
                    <div class="summary-section-title">Educational Attainment</div>
                    <asp:Repeater ID="rptSummaryEducations" runat="server">
                        <HeaderTemplate><ul style="padding-left: 18px; font-size: 0.88rem;"></HeaderTemplate>
                        <ItemTemplate>
                            <li style="margin-bottom: 4px;">
                                <strong><%# Eval("CourseName") %></strong> at <%# Eval("University") %> 
                                <span style="color: var(--text-muted);">(<%# Eval("StartYear") %> - <%# Eval("EndYear") %>)</span>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate></ul></FooterTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoEducations" runat="server" Text="No education history recorded." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                </div>

                <div class="summary-section-box">
                    <div class="summary-section-title">Organizations & Affiliations</div>
                    <asp:Repeater ID="rptSummaryAffiliations" runat="server">
                        <HeaderTemplate><ul style="padding-left: 18px; font-size: 0.88rem;"></HeaderTemplate>
                        <ItemTemplate>
                            <li style="margin-bottom: 4px;">
                                <strong><%# Eval("Position") %></strong> at <%# Eval("OrganizationName") %> 
                                <span style="color: var(--text-muted);">(<%# FormatPeriod(Eval("StartYear"), Eval("EndYear")) %>)</span>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate></ul></FooterTemplate>
                    </asp:Repeater>
                    <asp:Label ID="lblNoAffiliations" runat="server" Text="No organization affiliations recorded." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                </div>

                <div class="form-row" style="margin-bottom: 14px;">
                    <div class="summary-section-box" style="margin-bottom: 0;">
                        <div class="summary-section-title">Skills</div>
                        <div class="summary-pill-list">
                            <asp:Repeater ID="rptSummarySkills" runat="server">
                                <ItemTemplate>
                                    <span class="summary-pill"><%# Eval("SkillName") %></span>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Label ID="lblNoSkills" runat="server" Text="No skills listed." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                        </div>
                    </div>

                    <div class="summary-section-box" style="margin-bottom: 0;">
                        <div class="summary-section-title">Hobbies</div>
                        <div class="summary-pill-list">
                            <asp:Repeater ID="rptSummaryHobbies" runat="server">
                                <ItemTemplate>
                                    <span class="summary-pill"><%# Eval("HobbyName") %></span>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Label ID="lblNoHobbies" runat="server" Text="No hobbies listed." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                        </div>
                    </div>
                </div>

                <div class="summary-section-box" style="margin-bottom: 0;">
                    <div class="summary-section-title">Social Links & Profiles</div>
                    <div class="summary-pill-list">
                        <asp:Repeater ID="rptSummarySocialLinks" runat="server">
                            <ItemTemplate>
                                <a href='<%# FormatSocialUrl(Eval("Link")) %>' target="_blank" rel="noopener noreferrer" class="summary-pill summary-pill-link" title='<%# Eval("Link") %>'>
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
                                    <span><%# Eval("SocialLinkName") %></span>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Label ID="lblNoSocialLinks" runat="server" Text="No social links connected." Visible="false" ForeColor="#64748b" style="font-size: 0.85rem;" />
                    </div>
                </div>

                <div class="modal-actions" style="margin-top: 18px;">
                    <button type="button" id="btnSummaryStatusTrigger" runat="server" class="btn btn-sm" onclick="openStatusModalFromSummary()">
                        <asp:Literal ID="litSummaryStatusBtnText" runat="server" Text="Deactivate" />
                    </button>
                    
                    <asp:HyperLink ID="lnkSummaryPortfolio" runat="server" Target="_blank" CssClass="btn btn-outline btn-sm">
                        View Portfolio
                    </asp:HyperLink>

                    <asp:HyperLink ID="lnkSummaryEditPortfolio" runat="server" Target="_blank" CssClass="btn btn-outline btn-sm">
                        Edit Content
                    </asp:HyperLink>

                    <button type="button" class="btn btn-outline btn-sm" onclick="openEditFromSummary()">
                        Account Settings
                    </button>

                    <!--<button type="button" class="btn btn-danger btn-sm" onclick="openDeleteModalFromSummary()">
                        Delete
                    </button>-->
                    
                    <asp:Button ID="btnCloseSummary" runat="server" Text="Close" CssClass="btn btn-solid btn-sm" OnClick="btnCloseSummary_Click" />
                </div>
            </div>
        </asp:Panel>

        <div class="modal-overlay" id="statusModal">
            <div class="modal-box" style="max-width: 480px; text-align: center;">
                <button type="button" class="close-modal-btn" onclick="closeStatusModal()">&times;</button>
                
                <div id="statusModalIconWrap" style="width: 60px; height: 60px; border-radius: 50%; border: 2.5px solid #000; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; background-color: #fee2e2;">
                    <svg id="statusModalIconDeactivate" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line></svg>
                    <svg id="statusModalIconActivate" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2.5" style="display: none;"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                </div>

                <h3 class="modal-title" id="statusModalTitle">Deactivate</h3>
                <p class="modal-desc" id="statusModalDesc" style="margin-bottom: 24px; line-height: 1.5; color: #3f3f46;">
                    Are you sure you want to change the status of this user account?
                </p>

                <asp:HiddenField ID="hfStatusUserId" runat="server" />
                <asp:HiddenField ID="hfStatusNewState" runat="server" />

                <div class="modal-actions" style="justify-content: center; border-top: none; padding-top: 0; margin-top: 10px; gap: 12px;">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeStatusModal()" style="min-width: 100px;">
                        Cancel
                    </button>
                    <asp:Button ID="btnConfirmStatusAction" runat="server" Text="Confirm" CssClass="btn btn-danger btn-sm" OnClick="btnConfirmStatusAction_Click" style="min-width: 140px;" />
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="deleteModal">
            <div class="modal-box" style="max-width: 480px; text-align: center;">
                <button type="button" class="close-modal-btn" onclick="closeDeleteModal()">&times;</button>
                
                <div style="width: 60px; height: 60px; border-radius: 50%; border: 2.5px solid #000; margin: 0 auto 16px; display: flex; align-items: center; justify-content: center; background-color: #fee2e2;">
                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        <line x1="10" y1="11" x2="10" y2="17"></line>
                        <line x1="14" y1="11" x2="14" y2="17"></line>
                    </svg>
                </div>

                <h3 class="modal-title">Delete User Account</h3>
                <p class="modal-desc" id="deleteModalDesc" style="margin-bottom: 16px; line-height: 1.5; color: #3f3f46;">
                    Are you sure you want to permanently delete this user account?
                </p>

                <div style="background-color: #fff1f2; border: 2px solid #fecdd3; border-radius: 10px; padding: 12px 14px; margin-bottom: 20px; text-align: left; display: flex; gap: 10px; align-items: flex-start;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#e11d48" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0; margin-top: 1px;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                    <div style="font-size: 0.82rem; color: #9f1239; line-height: 1.45;">
                        <strong style="font-weight: 700;">Warning:</strong> This action cannot be undone. All associated portfolios, educations, skills, affiliations, hobbies, and social links will be permanently erased.
                    </div>
                </div>

                <asp:HiddenField ID="hfDeleteUserId" runat="server" />

                <div class="modal-actions" style="justify-content: center; border-top: none; padding-top: 0; margin-top: 10px; gap: 12px;">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeDeleteModal()" style="min-width: 100px;">
                        Cancel
                    </button>
                    <asp:Button ID="btnConfirmDeleteUser" runat="server" Text="Yes, Permanently Delete" CssClass="btn btn-danger btn-sm" OnClick="btnConfirmDeleteUser_Click" style="min-width: 170px;" />
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="addModal">
            <div class="modal-box">
                <button type="button" class="close-modal-btn" onclick="closeAddModal()">&times;</button>
                <h3 class="modal-title">Create User Account</h3>
                <p class="modal-desc">Provision a new account with specified administrative privileges.</p>

                <div class="form-row">
                    <div>
                        <label class="form-label">First Name</label>
                        <asp:TextBox ID="txtAddFirstName" runat="server" CssClass="form-control" placeholder="Jane" />
                    </div>
                    <div>
                        <label class="form-label">Last Name</label>
                        <asp:TextBox ID="txtAddLastName" runat="server" CssClass="form-control" placeholder="Doe" />
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <asp:TextBox ID="txtAddEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="jane.doe@example.com" />
                </div>

                <div class="form-group">
                    <label class="form-label">Initial Password</label>
                    <asp:TextBox ID="txtAddPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Min. 6 characters" />
                </div>

                <div class="form-group">
                    <label class="form-label">System Role</label>
                    <asp:DropDownList ID="ddlAddRole" runat="server" CssClass="form-control">
                        <asp:ListItem Value="User" Text="User (Standard Portfolio Owner)" />
                        <asp:ListItem Value="Admin" Text="Admin (Console & System Access)" />
                    </asp:DropDownList>
                </div>

                <label class="form-check">
                    <asp:CheckBox ID="chkAddIsActive" runat="server" Checked="true" />
                    Activate account immediately
                </label>

                <div class="modal-actions">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeAddModal()">Cancel</button>
                    <asp:Button ID="btnSaveNewUser" runat="server" Text="Create Account" CssClass="btn btn-solid btn-sm" OnClick="btnSaveNewUser_Click" />
                </div>
            </div>
        </div>

        <div class="modal-overlay" id="editModal">
            <div class="modal-box">
                <button type="button" class="close-modal-btn" onclick="closeEditModal()">&times;</button>
                <h3 class="modal-title">Edit User Account</h3>
                <p class="modal-desc">Update credentials, system role, and access status.</p>

                <asp:HiddenField ID="hfEditUserId" runat="server" />

                <div class="form-row">
                    <div>
                        <label class="form-label">First Name</label>
                        <asp:TextBox ID="txtEditFirstName" runat="server" CssClass="form-control" />
                    </div>
                    <div>
                        <label class="form-label">Last Name</label>
                        <asp:TextBox ID="txtEditLastName" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Email Address</label>
                    <asp:TextBox ID="txtEditEmail" runat="server" TextMode="Email" CssClass="form-control" />
                </div>

                <div class="form-group">
                    <label class="form-label">System Role</label>
                    <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-control">
                        <asp:ListItem Value="User" Text="User (Standard Portfolio Owner)" />
                        <asp:ListItem Value="Admin" Text="Admin (Console & System Access)" />
                    </asp:DropDownList>
                </div>

                <label class="form-check">
                    <asp:CheckBox ID="chkEditIsActive" runat="server" />
                    Account is active and permitted to login
                </label>

                <div style="margin-top: 16px; padding-top: 14px; border-top: 1.5px dashed #cbd5e1;">
                    <label class="form-label" style="display: flex; align-items: center; justify-content: space-between;">
                        <span>Reset / Change Password</span>
                        <span style="font-size: 0.76rem; font-weight: normal; color: var(--text-muted);">(Leave blank to keep unchanged)</span>
                    </label>
                    <div class="form-row" style="margin-bottom: 0;">
                        <div>
                            <asp:TextBox ID="txtEditNewPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="New password (min 6)" />
                        </div>
                        <div>
                            <asp:TextBox ID="txtEditConfirmPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Confirm new password" />
                        </div>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-outline btn-sm" onclick="closeEditModal()">Cancel</button>
                    <asp:Button ID="btnUpdateUser" runat="server" Text="Save Changes" CssClass="btn btn-solid btn-sm" OnClick="btnUpdateUser_Click" />
                </div>
            </div>
        </div>
    </form>

    <script src="../Assets/js/admin-dashboard.js"></script>
</body>
</html>
