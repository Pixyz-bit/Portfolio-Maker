<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SummarySection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.SummarySection" %>

<style>
    /* Summary Section Component Styles */
    .summary-card {
        padding: 34px 38px;
    }

    .summary-text {
        font-size: 1.02rem;
        font-weight: 400;
        color: var(--text-black);
        line-height: 1.65;
        white-space: pre-line;
    }
</style>

<asp:Panel ID="pnlSummary" runat="server" CssClass="bento-card summary-card">
    <h2 class="card-title">Personal Biography</h2>
    <p class="summary-text">
        <asp:Literal ID="litSummary" runat="server" />
    </p>
</asp:Panel>
