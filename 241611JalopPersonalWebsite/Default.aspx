<%@ Page Language="C#" AutoEventWireup="true" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("~/Frontend/Login/Signup.aspx");
    }
</script>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="refresh" content="0;url=Frontend/Login/Signup.aspx" />
    <title>Redirecting to Signup...</title>
</head>
<body>
    <p>Redirecting to <a href="Frontend/Login/Signup.aspx">Signup Page</a>...</p>
</body>
</html>
