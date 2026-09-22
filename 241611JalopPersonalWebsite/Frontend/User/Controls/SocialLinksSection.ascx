<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SocialLinksSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.SocialLinksSection" %>

<style>
    /* Social Links Section Component Styles */
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

    @media (max-width: 840px) {
        .connect-bar {
            border-radius: 20px;
            flex-direction: column;
            align-items: flex-start;
            padding: 22px 20px;
            gap: 12px;
        }
    }
</style>

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
