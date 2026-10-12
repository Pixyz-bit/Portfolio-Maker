<%@ Page Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("~/Frontend/User/PublicDashboard.aspx");
    }
</script>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="refresh" content="0;url=Frontend/User/PublicDashboard.aspx" />
    <title>Redirecting to Portfolios...</title>
</head>
<body>
    <p>Redirecting to <a href="Frontend/User/PublicDashboard.aspx">Public Portfolios Directory</a>...</p>
</body>
</html>
