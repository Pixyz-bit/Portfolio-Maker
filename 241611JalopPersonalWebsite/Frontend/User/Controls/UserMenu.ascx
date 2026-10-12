<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserMenu.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.UserMenu" %>

<link rel="stylesheet" href="<%= Page.ResolveUrl("~/Frontend/Assets/css/user-menu.css") %>" />

<div class="user-menu-wrapper" id="userMenuWrapper">
    <!-- 2nd Photo Icon Button -->
    <button type="button" class="user-menu-btn" id="btnUserMenuToggle" aria-label="Open User Menu" title="User Menu">
        <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="20" cy="20" r="20" fill="black"/>
            <circle cx="20" cy="15" r="5.2" fill="white"/>
            <path d="M7.5 36C8.5 28.5 13.5 24 20 24C26.5 24 31.5 28.5 32.5 36C28.8 39 24.6 40 20 40C15.4 40 11.2 39 7.5 36Z" fill="white"/>
        </svg>
    </button>

    <!-- 3rd Photo Component Dropdown -->
    <div class="user-menu-dropdown" id="userMenuDropdown">
        <div class="menu-avatar-wrap">
            <asp:Image ID="imgAvatar" runat="server" AlternateText="Avatar" ImageUrl="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='76' height='76' viewBox='0 0 24 24' fill='none' stroke='%23000' stroke-width='1.5'><path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'></path><circle cx='12' cy='7' r='4'></circle></svg>" />
        </div>

        <h3 class="menu-user-name"><asp:Literal ID="litFullName" runat="server" Text="User" /></h3>
        <p class="menu-user-email"><asp:Literal ID="litEmail" runat="server" Text="user@example.com" /></p>

        <div class="menu-actions">
            <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/Frontend/Admin/Dashboard.aspx" CssClass="menu-btn menu-btn-solid">
                Admin Dashboard
            </asp:HyperLink>
            <asp:HyperLink ID="lnkViewPortfolio" runat="server" NavigateUrl="~/Frontend/User/Portfolio.aspx" CssClass="menu-btn menu-btn-outline">
                View Portfolio
            </asp:HyperLink>
            <asp:HyperLink ID="lnkExplorePortfolios" runat="server" NavigateUrl="~/Frontend/User/PublicDashboard.aspx" CssClass="menu-btn menu-btn-outline">
                Explore Portfolios
            </asp:HyperLink>
            <asp:PlaceHolder ID="phEditAccountBtn" runat="server">
                <button type="button" class="menu-btn menu-btn-outline" id="btnUserMenuEditAccount" onclick="openUserAccountModal()">
                    Account Settings
                </button>
            </asp:PlaceHolder>
            <asp:HyperLink ID="lnkEditPortfolio" runat="server" NavigateUrl="~/Frontend/User/Onboarding.aspx" CssClass="menu-btn menu-btn-outline">
                Edit Portfolio
            </asp:HyperLink>
            <asp:HyperLink ID="lnkEditDetails" runat="server" NavigateUrl="Onboarding.aspx" CssClass="menu-btn menu-btn-outline" Visible="false">
                Edit Onboarding Portfolio Details
            </asp:HyperLink>
            <asp:HyperLink ID="lnkSignOut" runat="server" NavigateUrl="~/Frontend/Login/Login.aspx?action=logout" CssClass="menu-btn menu-btn-outline">
                Sign Out
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
