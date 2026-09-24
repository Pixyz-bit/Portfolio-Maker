<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SkillsSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.SkillsSection" %>
<section class="bento-card">
    <h2 class="card-title">Skills</h2>

    <asp:Repeater ID="rptSkills" runat="server">
        <HeaderTemplate>
            <div class="list-group">
        </HeaderTemplate>
        <ItemTemplate>
            <div class="list-item">
                <div class="list-title"><%# Eval("SkillName") %></div>
                <div class="list-desc"><%# Eval("SkillDescription") %></div>
            </div>
        </ItemTemplate>
        <FooterTemplate>
            </div>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="pnlNoSkills" runat="server" Visible="false">
        <p class="empty-text">No technical skills added yet.</p>
    </asp:Panel>
</section>
