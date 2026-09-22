<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AffiliationsSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.AffiliationsSection" %>

<style>
    /* Affiliations Section Component Styles */
    .timeline-list {
        display: flex;
        flex-direction: column;
        flex-grow: 1;
    }

    .timeline-item {
        position: relative;
        padding-left: 32px;
        padding-bottom: 26px;
    }

    .timeline-item:last-child {
        padding-bottom: 0;
    }

    /* Vertical connector line */
    .timeline-item::before {
        content: '';
        position: absolute;
        left: 5px;
        top: 17px;
        bottom: -6px;
        width: 1.5px;
        background-color: #000000;
    }

    .timeline-item:last-child::before {
        display: none;
    }

    /* Hollow circle node */
    .timeline-item::after {
        content: '';
        position: absolute;
        left: 0;
        top: 4px;
        width: 12px;
        height: 12px;
        border-radius: 50%;
        border: 1.8px solid #000000;
        background-color: #ffffff;
        box-sizing: border-box;
    }

    .timeline-row {
        display: flex;
        justify-content: space-between;
        align-items: baseline;
        gap: 16px;
    }

    .timeline-primary {
        font-size: 1.05rem;
        font-weight: 700;
        color: var(--text-black);
        line-height: 1.35;
    }

    .timeline-period {
        font-size: 0.98rem;
        font-weight: 700;
        color: var(--text-black);
        white-space: nowrap;
        text-align: right;
        line-height: 1.35;
    }

    .timeline-sub {
        font-size: 0.95rem;
        font-weight: 400;
        color: var(--text-black);
        margin-top: 3px;
        line-height: 1.4;
    }

    @media (max-width: 840px) {
        .timeline-row {
            flex-direction: column;
            gap: 2px;
        }

        .timeline-period {
            text-align: left;
            font-size: 0.9rem;
            color: var(--text-muted);
        }
    }
</style>

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
