<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HeroSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.HeroSection" %>
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
