<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EducationSection.ascx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Controls.EducationSection" %>
<section class="bento-card">
    <h2 class="card-title">Educational Attainment</h2>

    <asp:Repeater ID="rptEducation" runat="server">
        <HeaderTemplate>
            <div class="timeline-list">
        </HeaderTemplate>
        <ItemTemplate>
            <div class="timeline-item">
                <div class="timeline-row">
                    <span class="timeline-primary"><%# Eval("CourseName") %></span>
                    <span class="timeline-period"><%# FormatPeriod(Eval("StartYear"), Eval("EndYear")) %></span>
                </div>
                <div class="timeline-sub"><%# Eval("University") %></div>
            </div>
        </ItemTemplate>
        <FooterTemplate>
            </div>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="pnlNoEducation" runat="server" Visible="false">
        <p class="empty-text">No educational background added yet.</p>
    </asp:Panel>
</section>
