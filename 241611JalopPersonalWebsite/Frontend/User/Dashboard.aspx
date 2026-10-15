<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Dashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>User Dashboard | Personal Portfolio</title>
    <meta name="description" content="Manage and view your personal portfolio overview." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />

    <link rel="stylesheet" href="../Assets/css/user-dashboard.css" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Frontend/Assets/css/accessibility.css") %>" />
    <script src="<%= ResolveUrl("~/Frontend/Assets/js/accessibility.js") %>" defer></script>
</head>
<body>
    <div class="dashboard-container">
        <div class="card">
            <div class="user-avatar">
                <asp:Image ID="imgAvatar" runat="server" ImageUrl="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='100' height='100' viewBox='0 0 24 24' fill='none' stroke='%23000' stroke-width='1.5'><path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'></path><circle cx='12' cy='7' r='4'></circle></svg>" AlternateText="Avatar" />
            </div>

            <h1 class="user-name"><asp:Literal ID="litFullName" runat="server" Text="Welcome!" /></h1>
            <p class="user-email"><asp:Literal ID="litEmail" runat="server" Text="user@example.com" /></p>

            <div class="bio-box">
                <asp:Literal ID="litBio" runat="server" Text="No bio provided yet. Complete your onboarding to build your portfolio." />
            </div>

            <div class="btn-group">
                <asp:HyperLink ID="lnkAdminDashboard" runat="server" NavigateUrl="~/Frontend/Admin/Dashboard.aspx" CssClass="btn btn-solid" Visible="false">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" style="display:inline-block; vertical-align:-1px; margin-right:4px;"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg>Admin Dashboard
                </asp:HyperLink>
                <asp:HyperLink ID="lnkViewPortfolio" runat="server" NavigateUrl="Portfolio.aspx" CssClass="btn btn-solid">
                    View Live Portfolio
                </asp:HyperLink>
                <a href="Onboarding.aspx" class="btn btn-outline">Edit Onboarding Portfolio Details</a>
                <a href="PublicDashboard.aspx" class="btn btn-outline">Explore Public Portfolios</a>
                <a href="../Login/Login.aspx?action=logout" class="btn btn-outline">Sign Out</a>
            </div>
        </div>
    </div>
</body>
</html>
