<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.HobbiesSection" %>

<style>
    /* Hobbies Section Component Styles */
    .list-group {
        display: flex;
        flex-direction: column;
        gap: 22px;
        flex-grow: 1;
    }

    .list-item {
        display: flex;
        flex-direction: column;
    }

    .list-title {
        font-size: 1.05rem;
        font-weight: 700;
        color: var(--text-black);
        line-height: 1.35;
    }

    .list-desc {
        font-size: 0.95rem;
        font-weight: 400;
        color: var(--text-black);
        margin-top: 3px;
        line-height: 1.45;
        white-space: pre-line;
    }
</style>

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
