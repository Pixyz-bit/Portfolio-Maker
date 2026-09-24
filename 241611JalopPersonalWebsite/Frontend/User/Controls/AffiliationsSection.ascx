<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AffiliationsSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.AffiliationsSection" %>
<section class="bento-card">
    <h2 class="card-title">Affiliations</h2>

    <asp:Repeater ID="rptAffiliations" runat="server">
        <HeaderTemplate>
            <div class="timeline-list">
        </HeaderTemplate>
        <ItemTemplate>
            <div class="timeline-item">
                <div class="timeline-row">
                    <span class="timeline-primary"><%# Eval("Position") %></span>
                    <span class="timeline-period"><%# FormatPeriod(Eval("StartYear"), Eval("EndYear")) %></span>
                </div>
                <div class="timeline-sub"><%# Eval("OrganizationName") %></div>
            </div>
        </ItemTemplate>
        <FooterTemplate>
            </div>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="pnlNoAffiliations" runat="server" Visible="false">
        <p class="empty-text">No organization affiliations added yet.</p>
    </asp:Panel>
</section>
