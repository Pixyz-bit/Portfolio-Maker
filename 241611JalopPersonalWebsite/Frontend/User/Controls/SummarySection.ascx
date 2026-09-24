<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SummarySection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.SummarySection" %>
<asp:Panel ID="pnlSummary" runat="server" CssClass="bento-card summary-card">
    <h2 class="card-title">Personal Biography</h2>
    <p class="summary-text">
        <asp:Literal ID="litSummary" runat="server" />
    </p>
</asp:Panel>
