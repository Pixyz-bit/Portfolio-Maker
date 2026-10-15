<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SocialLinksSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.SocialLinksSection" %>
<asp:Panel ID="pnlConnect" runat="server" CssClass="connect-bar">
    <span class="connect-title">Connect with me!</span>
    <div class="connect-links">
        <asp:Repeater ID="rptSocialLinks" runat="server">
            <ItemTemplate>
                <a href='<%# _241611JalopPersonalWebsite.Backend.Common.InputSafety.SafeWebUrl(Eval("Link")) %>' target="_blank" rel="noopener noreferrer" class="social-pill-btn">
                    <%# GetSocialIcon(Eval("SocialLinkName") as string) %>
                    <span><%#: Eval("SocialLinkName") %></span>
                </a>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>
