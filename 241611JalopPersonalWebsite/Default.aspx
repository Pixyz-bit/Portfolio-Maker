<%@ Page Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("~/Frontend/Login/Login.aspx");
    }
</script>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="refresh" content="0;url=Frontend/Login/Login.aspx" />
    <title>Redirecting to Sign In...</title>
</head>
<body>
    <p>Redirecting to <a href="Frontend/Login/Login.aspx">Sign In Page</a>...</p>
</body>
</html>
