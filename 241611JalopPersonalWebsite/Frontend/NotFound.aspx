<%@ Page Language="C#" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.StatusCode = 404;
        Response.TrySkipIisCustomErrors = true;
    }
</script>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Portfolio not found</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Frontend/Assets/css/public-dashboard.css") %>" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Frontend/Assets/css/accessibility.css") %>?v=20261015e" />
</head>
<body>
    <main class="main-content">
        <h1>Portfolio not found</h1>
        <p>This portfolio link is invalid or the portfolio is no longer available.</p>
        <a class="btn btn-solid" href="<%= ResolveUrl("~/Frontend/User/PublicDashboard.aspx") %>">Browse public portfolios</a>
    </main>
</body>
</html>
