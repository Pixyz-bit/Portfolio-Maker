<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Dashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>User Dashboard | Personal Portfolio</title>
    <meta name="description" content="Manage and view your personal portfolio overview." />

    <!-- Google Fonts: Plus Jakarta Sans & Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

    <style>
        :root {
            --bg-canvas: #ffffff;
            --dot-color: #cbd5e1;
            --border-black: #000000;
            --text-black: #000000;
            --text-muted: #52525b;
            --card-bg: #ffffff;
            --radius-card: 20px;
            --radius-btn: 10px;
            --transition: 0.2s ease;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Plus Jakarta Sans', 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: var(--bg-canvas);
            background-image: radial-gradient(var(--dot-color) 1.2px, transparent 1.2px);
            background-size: 16px 16px;
            color: var(--text-black);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 36px 16px;
        }

        .dashboard-container {
            width: 100%;
            max-width: 640px;
        }

        .card {
            background-color: var(--card-bg);
            background-image: radial-gradient(var(--dot-color) 1.2px, transparent 1.2px);
            background-size: 16px 16px;
            border: 2.5px solid var(--border-black);
            border-radius: var(--radius-card);
            padding: 44px 36px;
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.04);
            text-align: center;
        }

        .user-avatar {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            border: 2.5px solid var(--border-black);
            margin: 0 auto 20px;
            object-fit: cover;
            overflow: hidden;
            background-color: #f4f4f5;
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .user-name {
            font-size: 1.8rem;
            font-weight: 800;
            letter-spacing: -0.02em;
            margin-bottom: 6px;
        }

        .user-email {
            font-size: 0.9rem;
            color: var(--text-muted);
            font-family: 'Inter', sans-serif;
            margin-bottom: 18px;
        }

        .bio-box {
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            border-radius: 12px;
            padding: 16px 20px;
            font-size: 0.9rem;
            color: #27272a;
            font-family: 'Inter', sans-serif;
            line-height: 1.6;
            margin-bottom: 28px;
            text-align: left;
        }

        .btn-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .btn {
            height: 48px;
            padding: 0 24px;
            border-radius: var(--radius-btn);
            font-family: inherit;
            font-size: 0.98rem;
            font-weight: 800;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: var(--transition);
        }

        .btn-solid {
            background-color: #000000;
            color: #ffffff;
            border: 2px solid #000000;
        }

        .btn-solid:hover {
            background-color: #27272a;
            border-color: #27272a;
        }

        .btn-outline {
            background-color: #ffffff;
            color: #000000;
            border: 2px solid #000000;
        }

        .btn-outline:hover {
            background-color: #f4f4f5;
        }
    </style>
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
                <a href="Portfolio.aspx" class="btn btn-solid">View Live Portfolio</a>
                <a href="Onboarding.aspx" class="btn btn-outline">Edit Onboarding Portfolio Details</a>
                <a href="../Login/Login.aspx?action=logout" class="btn btn-outline">Sign Out</a>
            </div>
        </div>
    </div>
</body>
</html>
