<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HeroSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.HeroSection" %>

<style>
    /* Hero Section Component Styles */
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

    @media (max-width: 840px) {
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
    }
</style>

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
