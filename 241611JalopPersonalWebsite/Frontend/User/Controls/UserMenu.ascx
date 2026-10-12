<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserMenu.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.UserMenu" %>

<link rel="stylesheet" href="<%= Page.ResolveUrl("~/Frontend/Assets/css/user-menu.css") %>?v=<%= DateTime.UtcNow.Ticks %>" />

<div class="user-menu-wrapper" id="userMenuWrapper">
    <!-- 2nd Photo Icon Button -->
    <button type="button" class="user-menu-btn" id="btnUserMenuToggle" aria-label="Open User Menu" title="User Menu">
        <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="20" cy="20" r="20" fill="black"/>
            <circle cx="20" cy="15" r="5.2" fill="white"/>
            <path d="M7.5 36C8.5 28.5 13.5 24 20 24C26.5 24 31.5 28.5 32.5 36C28.8 39 24.6 40 20 40C15.4 40 11.2 39 7.5 36Z" fill="white"/>
        </svg>
    </button>

    <!-- Compact Organized Dropdown Menu -->
    <div class="user-menu-dropdown" id="userMenuDropdown">
        <!-- User Identity Header (Horizontal & Compact) -->
        <div class="menu-header">
            <div class="menu-avatar-wrap">
                <asp:Image ID="imgAvatar" runat="server" AlternateText="Avatar" ImageUrl="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='44' height='44' viewBox='0 0 24 24' fill='none' stroke='%23000' stroke-width='1.5'><path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'></path><circle cx='12' cy='7' r='4'></circle></svg>" />
            </div>
            <div class="menu-user-meta">
                <h4 class="menu-user-name"><asp:Literal ID="litFullName" runat="server" Text="User" /></h4>
                <p class="menu-user-email"><asp:Literal ID="litEmail" runat="server" Text="user@example.com" /></p>
                <div class="menu-role-tag-wrap">
                    <asp:Label ID="lblRoleBadge" runat="server" CssClass="menu-role-tag" Text="Owner" />
                </div>
            </div>
        </div>

        <!-- Portfolio Visibility Quick Toggle -->
        <div class="menu-visibility-card">
            <div class="visibility-status-info">
                <span class="status-indicator-dot dot-public" id="dotVisibility" runat="server"></span>
                <span class="visibility-status-text">
                    <asp:Literal ID="litVisibilityLabel" runat="server" Text="Public Portfolio" />
                </span>
            </div>
            <asp:LinkButton ID="btnToggleVisibility" runat="server" CssClass="visibility-action-btn" OnClick="btnToggleVisibility_Click" ToolTip="Click to toggle portfolio public/private visibility">
                <asp:Literal ID="litVisibilityAction" runat="server" Text="Make Private" />
            </asp:LinkButton>
        </div>

        <div class="menu-divider"></div>

        <!-- Primary Navigation Actions -->
        <div class="menu-group">
            <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/Frontend/Admin/Dashboard.aspx" CssClass="menu-item menu-item-admin">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
                <span><asp:Literal ID="litDashboardLabel" runat="server" Text="Admin Dashboard" /></span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkViewPortfolio" runat="server" NavigateUrl="~/Frontend/User/Portfolio.aspx" CssClass="menu-item">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                <span><asp:Literal ID="litViewPortfolioLabel" runat="server" Text="View Portfolio" /></span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkEditPortfolio" runat="server" NavigateUrl="~/Frontend/User/Onboarding.aspx" CssClass="menu-item">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                <span><asp:Literal ID="litEditPortfolioLabel" runat="server" Text="Edit Portfolio" /></span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkExplorePortfolios" runat="server" NavigateUrl="~/Frontend/User/PublicDashboard.aspx" CssClass="menu-item">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"></polygon></svg>
                <span>Explore Portfolios</span>
            </asp:HyperLink>
            <asp:HyperLink ID="lnkEditDetails" runat="server" NavigateUrl="Onboarding.aspx" CssClass="menu-item" Visible="false">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line></svg>
                <span>Edit Details</span>
            </asp:HyperLink>
        </div>

        <div class="menu-divider"></div>

        <!-- Preferences & Sign Out Actions -->
        <div class="menu-group">
            <asp:PlaceHolder ID="phEditAccountBtn" runat="server">
                <button type="button" class="menu-item" id="btnUserMenuEditAccount" onclick="openUserAccountModal()">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                    <span>Account Settings</span>
                </button>
            </asp:PlaceHolder>
            <asp:HyperLink ID="lnkSignOut" runat="server" NavigateUrl="~/Frontend/Login/Login.aspx?action=logout" CssClass="menu-item menu-item-signout">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
                <span>Sign Out</span>
            </asp:HyperLink>
        </div>
    </div>
</div>

<!-- EDIT USER ACCOUNT MODAL (Matching Photo 1) -->
<div class="user-account-modal-overlay" id="userAccountModalOverlay" style="display: none;">
    <div class="user-account-modal-box">
        <button type="button" class="user-account-close-btn" onclick="closeUserAccountModal()">&times;</button>
        
        <h3 class="user-account-modal-title">Edit User Account</h3>
        <p class="user-account-modal-desc">Update credentials, system role, and access status.</p>

        <div class="user-account-form-row">
            <div class="user-account-form-group">
                <label class="user-account-label">First Name</label>
                <asp:TextBox ID="txtAccountFirstName" runat="server" CssClass="user-account-input" placeholder="First Name" />
            </div>
            <div class="user-account-form-group">
                <label class="user-account-label">Last Name</label>
                <asp:TextBox ID="txtAccountLastName" runat="server" CssClass="user-account-input" placeholder="Last Name" />
            </div>
        </div>

        <div class="user-account-form-group" style="margin-bottom: 16px;">
            <label class="user-account-label">Email Address</label>
            <asp:TextBox ID="txtAccountEmail" runat="server" TextMode="Email" CssClass="user-account-input" placeholder="email@example.com" />
        </div>

        <asp:PlaceHolder ID="phAdminOnlyAccountFields" runat="server">
            <div class="user-account-form-group" style="margin-bottom: 16px;">
                <label class="user-account-label">System Role</label>
                <asp:DropDownList ID="ddlAccountRole" runat="server" CssClass="user-account-input">
                    <asp:ListItem Value="User" Text="User (Standard Portfolio Owner)" />
                    <asp:ListItem Value="Admin" Text="Administrator (Full Access)" />
                </asp:DropDownList>
            </div>

            <div class="user-account-form-check" style="margin-bottom: 18px;">
                <asp:CheckBox ID="chkAccountIsActive" runat="server" Checked="true" />
                <label for="<%= chkAccountIsActive.ClientID %>">Account is active and permitted to login</label>
            </div>
        </asp:PlaceHolder>

        <div class="user-account-form-check" style="margin-bottom: 18px;">
            <asp:CheckBox ID="chkAccountIsPublic" runat="server" Checked="true" />
            <label for="<%= chkAccountIsPublic.ClientID %>">Make my portfolio public (discoverable in Explore directory)</label>
        </div>

        <div class="user-account-divider"></div>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
            <label class="user-account-label" style="margin-bottom: 0;">Reset / Change Password</label>
            <span style="font-size: 0.8rem; color: #71717a;">(Leave blank to keep unchanged)</span>
        </div>

        <div class="user-account-form-row" style="margin-bottom: 24px;">
            <div class="user-account-form-group">
                <asp:TextBox ID="txtAccountNewPassword" runat="server" TextMode="Password" CssClass="user-account-input" placeholder="New password (min 6)" />
            </div>
            <div class="user-account-form-group">
                <asp:TextBox ID="txtAccountConfirmPassword" runat="server" TextMode="Password" CssClass="user-account-input" placeholder="Confirm new password" />
            </div>
        </div>

        <div class="user-account-actions">
            <button type="button" class="user-account-btn user-account-btn-cancel" onclick="closeUserAccountModal()">Cancel</button>
            <asp:Button ID="btnSaveUserAccount" runat="server" Text="Save Changes" CssClass="user-account-btn user-account-btn-save" OnClick="btnSaveUserAccount_Click" />
        </div>
    </div>
</div>

<!-- Floating Lower-Right Toast Container for User Account Alerts -->
<div class="user-account-toast-container" id="userAccountToastContainer">
    <asp:Panel ID="pnlUserAccountModalMsg" runat="server" Visible="false" CssClass="user-account-toast">
        <div class="user-account-toast-content">
            <span style="font-size: 1.1rem; line-height: 1;">&#9888;</span>
            <asp:Literal ID="litUserAccountModalMsg" runat="server" />
        </div>
        <button type="button" class="user-account-toast-close" onclick="this.closest('.user-account-toast').style.display='none';">&times;</button>
    </asp:Panel>
</div>

<script src="<%= Page.ResolveUrl("~/Frontend/Assets/js/user-menu.js") %>"></script>
