<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.HobbiesSection" %>
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
