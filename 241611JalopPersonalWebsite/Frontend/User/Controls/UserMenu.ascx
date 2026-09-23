<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserMenu.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.UserMenu" %>

<style>
    .user-menu-wrapper {
        position: relative;
        display: inline-block;
    }

    /* Icon button matching 2nd photo */
    .user-menu-btn {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background-color: transparent;
        border: none;
        padding: 0;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: transform 0.15s ease, box-shadow 0.15s ease;
        outline: none;
    }

    .user-menu-btn:hover {
        transform: scale(1.06);
    }

    .user-menu-btn:active {
        transform: scale(0.94);
    }

    .user-menu-btn svg {
        width: 40px;
        height: 40px;
        display: block;
    }

    /* Dropdown card matching 3rd photo */
    .user-menu-dropdown {
        position: absolute;
        top: calc(100% + 14px);
        right: 0;
        width: 350px;
        background-color: #ffffff;
        background-image: radial-gradient(#cbd5e1 1.2px, transparent 1.2px);
        background-size: 16px 16px;
        border: 2.5px solid #000000;
        border-radius: 20px;
        padding: 30px 24px 26px;
        box-shadow: 0 16px 40px rgba(0, 0, 0, 0.16);
        z-index: 1000;
        text-align: center;
        opacity: 0;
        visibility: hidden;
        transform: translateY(-8px);
        transition: opacity 0.2s ease, transform 0.2s cubic-bezier(0.16, 1, 0.3, 1), visibility 0.2s ease;
    }

    .user-menu-dropdown.active {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }

    .menu-avatar-wrap {
        width: 76px;
        height: 76px;
        border-radius: 50%;
        border: 2.5px solid #000000;
        margin: 0 auto 14px;
        overflow: hidden;
        background-color: #f4f4f5;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .menu-avatar-wrap img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }

    .menu-user-name {
        font-size: 1.45rem;
        font-weight: 800;
        color: #000000;
        letter-spacing: -0.02em;
        line-height: 1.2;
        margin-bottom: 4px;
        word-wrap: break-word;
    }

    .menu-user-email {
        font-size: 0.88rem;
        font-weight: 500;
        color: #52525b;
        margin-bottom: 18px;
        word-break: break-all;
    }

    .menu-bio-box {
        background-color: #ffffff;
        border: 2px solid #000000;
        border-radius: 12px;
        padding: 12px 16px;
        font-size: 0.9rem;
        color: #000000;
        line-height: 1.45;
        margin-bottom: 18px;
        text-align: left;
        min-height: 44px;
        word-wrap: break-word;
    }

    .menu-actions {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }

    .menu-btn {
        height: 44px;
        border-radius: 10px;
        font-size: 0.92rem;
        font-weight: 800;
        text-decoration: none;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.15s ease;
        line-height: 1;
    }

    .menu-btn-solid {
        background-color: #000000;
        color: #ffffff;
        border: 2px solid #000000;
    }

    .menu-btn-solid:hover {
        background-color: #27272a;
        border-color: #27272a;
    }

    .menu-btn-outline {
        background-color: #ffffff;
        color: #000000;
        border: 2px solid #000000;
    }

    .menu-btn-outline:hover {
        background-color: #f4f4f5;
    }

    /* Proper Edit User Account Modal (Photo 1 Matching) */
    .user-account-modal-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background-color: rgba(0, 0, 0, 0.65);
        backdrop-filter: blur(4px);
        z-index: 99999;
        display: flex;
        justify-content: center;
        align-items: flex-start;
        padding: 40px 16px;
        overflow-y: auto;
        box-sizing: border-box;
    }

    .user-account-modal-box {
        background-color: #ffffff;
        border: 2.5px solid #000000;
        border-radius: 20px;
        box-shadow: 8px 8px 0px #000000;
        width: 100%;
        max-width: 520px;
        padding: 32px 30px;
        position: relative;
        text-align: left;
        margin: auto;
        box-sizing: border-box;
    }

    .user-account-close-btn {
        position: absolute;
        top: 20px;
        right: 20px;
        background: none;
        border: none;
        font-size: 1.4rem;
        line-height: 1;
        cursor: pointer;
        color: #52525b;
    }

    .user-account-close-btn:hover {
        color: #000000;
    }

    .user-account-modal-title {
        font-family: 'Plus Jakarta Sans', sans-serif;
        font-size: 1.45rem;
        font-weight: 800;
        margin-bottom: 6px;
        letter-spacing: -0.02em;
        color: #000000;
    }

    .user-account-modal-desc {
        font-size: 0.88rem;
        color: #52525b;
        margin-bottom: 22px;
    }

    .user-account-toast-container {
        position: fixed;
        bottom: 24px;
        right: 24px;
        z-index: 1000000;
        max-width: 420px;
        width: calc(100vw - 48px);
        pointer-events: none;
    }

    .user-account-toast {
        pointer-events: auto;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 12px;
        padding: 14px 18px;
        border-radius: 12px;
        border: 2px solid #000000;
        box-shadow: 4px 4px 0px #000000;
        font-size: 0.88rem;
        font-weight: 700;
        animation: userToastSlideUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        background: #ffffff;
    }

    @keyframes userToastSlideUp {
        from {
            opacity: 0;
            transform: translateY(20px) scale(0.96);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }

    .user-account-toast.alert-danger {
        background-color: #fef2f2;
        color: #991b1b;
        border-color: #ef4444;
    }

    .user-account-toast.alert-success {
        background-color: #f0fdf4;
        color: #166534;
        border-color: #16a34a;
    }

    .user-account-toast-content {
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .user-account-toast-close {
        background: transparent;
        border: none;
        font-size: 1.3rem;
        line-height: 1;
        cursor: pointer;
        color: inherit;
        padding: 0 4px;
        font-weight: 800;
    }

    .user-account-form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 14px;
        margin-bottom: 16px;
    }

    .user-account-form-group {
        display: flex;
        flex-direction: column;
    }

    .user-account-label {
        font-size: 0.85rem;
        font-weight: 700;
        margin-bottom: 6px;
        color: #000000;
    }

    .user-account-input {
        width: 100%;
        height: 42px;
        padding: 0 14px;
        border: 2px solid #000000;
        border-radius: 10px;
        font-family: 'Inter', sans-serif;
        font-size: 0.9rem;
        background-color: #ffffff;
        outline: none;
        box-sizing: border-box;
    }

    .user-account-input:focus {
        box-shadow: 0 0 0 2px rgba(0, 0, 0, 0.2);
    }

    .user-account-form-check {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 0.9rem;
        font-weight: 600;
        color: #000000;
    }

    .user-account-form-check input[type="checkbox"] {
        width: 18px;
        height: 18px;
        accent-color: #000000;
        cursor: pointer;
    }

    .user-account-divider {
        border-top: 1.5px dotted #cbd5e1;
        margin: 18px 0 16px;
    }

    .user-account-actions {
        display: flex;
        align-items: center;
        justify-content: flex-end;
        gap: 10px;
        padding-top: 18px;
        border-top: 1.5px solid #e2e8f0;
    }

    .user-account-btn {
        height: 38px;
        padding: 0 20px;
        border-radius: 8px;
        font-family: 'Plus Jakarta Sans', sans-serif;
        font-size: 0.88rem;
        font-weight: 800;
        cursor: pointer;
        transition: all 0.15s ease;
        border: 2px solid #000000;
    }

    .user-account-btn-cancel {
        background-color: #ffffff;
        color: #000000;
    }

    .user-account-btn-cancel:hover {
        background-color: #f4f4f5;
    }

    .user-account-btn-save {
        background-color: #000000;
        color: #ffffff;
    }

    .user-account-btn-save:hover {
        background-color: #27272a;
    }
</style>

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

        <div class="menu-bio-box">
            <asp:Literal ID="litBio" runat="server" Text="No bio provided yet." />
        </div>

        <div class="menu-actions">
            <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/Frontend/Admin/Dashboard.aspx" CssClass="menu-btn menu-btn-solid">
                Admin Dashboard
            </asp:HyperLink>
            <asp:PlaceHolder ID="phEditAccountBtn" runat="server">
                <button type="button" class="menu-btn menu-btn-outline" id="btnUserMenuEditAccount" onclick="openUserAccountModal()">
                    Edit Account
                </button>
            </asp:PlaceHolder>
            <asp:HyperLink ID="lnkEditPortfolio" runat="server" NavigateUrl="~/Frontend/User/Onboarding.aspx" CssClass="menu-btn menu-btn-outline">
                Edit Portfolio
            </asp:HyperLink>
            <asp:HyperLink ID="lnkViewPortfolio" runat="server" NavigateUrl="Portfolio.aspx" CssClass="menu-btn menu-btn-outline" Visible="false">
                View Live Portfolio
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

<script>
    (function () {
        const toggleBtn = document.getElementById('btnUserMenuToggle');
        const dropdown = document.getElementById('userMenuDropdown');

        if (toggleBtn && dropdown) {
            toggleBtn.addEventListener('click', function (e) {
                e.stopPropagation();
                dropdown.classList.toggle('active');
            });

            document.addEventListener('click', function (e) {
                if (!dropdown.contains(e.target) && !toggleBtn.contains(e.target)) {
                    dropdown.classList.remove('active');
                }
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    dropdown.classList.remove('active');
                    closeUserAccountModal();
                }
            });
        }

        window.addEventListener('click', function (e) {
            const modal = document.getElementById('userAccountModalOverlay');
            if (e.target === modal) {
                closeUserAccountModal();
            }
        });
    })();

    function ensureModalAttachedToForm() {
        const modal = document.getElementById('userAccountModalOverlay');
        const form = document.forms[0] || document.body;
        if (modal && form && modal.parentElement !== form) {
            form.appendChild(modal);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', ensureModalAttachedToForm);
    } else {
        ensureModalAttachedToForm();
    }

    function openUserAccountModal() {
        const dropdown = document.getElementById('userMenuDropdown');
        if (dropdown) dropdown.classList.remove('active');
        ensureModalAttachedToForm();
        const modal = document.getElementById('userAccountModalOverlay');
        if (modal) modal.style.display = 'flex';
    }

    function closeUserAccountModal() {
        const modal = document.getElementById('userAccountModalOverlay');
        if (modal) modal.style.display = 'none';
    }
</script>
