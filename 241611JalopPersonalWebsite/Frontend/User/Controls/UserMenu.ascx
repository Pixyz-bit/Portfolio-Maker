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
            <asp:HyperLink ID="lnkViewPortfolio" runat="server" NavigateUrl="Portfolio.aspx" CssClass="menu-btn menu-btn-solid">
                View Live Portfolio
            </asp:HyperLink>
            <asp:HyperLink ID="lnkEditDetails" runat="server" NavigateUrl="Onboarding.aspx" CssClass="menu-btn menu-btn-outline">
                Edit Onboarding Portfolio Details
            </asp:HyperLink>
            <a href="../Login/Login.aspx?action=logout" class="menu-btn menu-btn-outline">
                Sign Out
            </a>
        </div>
    </div>
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
                }
            });
        }
    })();
</script>
