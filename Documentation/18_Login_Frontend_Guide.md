# 18 - Login.aspx Frontend & Code-Behind Guide

## 1. Overview
**`Login.aspx`** is the user sign-in page for the personal portfolio platform.
It shares the exact same minimalist, monochromatic, dotted grid aesthetic as `Signup.aspx`:
- **Background**: Pure white canvas with a subtle dotted matrix grid pattern (`radial-gradient(#cbd5e1 1.2px, transparent 1.2px)`).
- **Color Scheme**: High-contrast black and white (`#000000` on `#ffffff`).
- **Cards & Inputs**: Solid 2.5px black outlines with smooth rounded corners (`border-radius: 20px` for the card, `10px` for the textboxes).
- **Password Eye Icon**: Matching eye stroke icon placed on the right inside the password input with click-to-reveal toggle.
- **Button**: High-contrast white button with solid bold black border (`border: 2px solid #000000`) and bold typography (`Sign In`).

It is connected to:
- **Model**: `_241611JalopPersonalWebsite.Model.UserLogin`
- **Repository**: `_241611JalopPersonalWebsite.Repository.UserRepository` (via `UserRepository.Login`)

---

## 2. Page & Directory Convention
- **Web Form**: `241611JalopPersonalWebsite/Frontend/Login/Login.aspx`
- **Code-Behind**: `241611JalopPersonalWebsite/Frontend/Login/Login.aspx.cs`
- **Designer File**: `241611JalopPersonalWebsite/Frontend/Login/Login.aspx.designer.cs`

---

## 3. Entire Code Snippet: `Login.aspx`
File: `Frontend/Login/Login.aspx`

```html
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.Login.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign In | Personal Portfolio</title>
    <meta name="description" content="Sign in to manage and customize your personal developer and professional portfolio." />

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
            --radius-input: 10px;
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
            padding: 32px 16px;
        }

        .login-container {
            width: 100%;
            max-width: 460px;
        }

        .card {
            background-color: var(--card-bg);
            background-image: radial-gradient(var(--dot-color) 1.2px, transparent 1.2px);
            background-size: 16px 16px;
            border: 2.5px solid var(--border-black);
            border-radius: var(--radius-card);
            padding: 44px 36px 36px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
        }

        .card-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .card-title {
            font-size: 1.95rem;
            font-weight: 800;
            letter-spacing: -0.02em;
            color: var(--text-black);
            margin-bottom: 6px;
        }

        .card-subtitle {
            font-size: 0.88rem;
            color: var(--text-muted);
            font-family: 'Inter', sans-serif;
        }

        .alert-box {
            padding: 12px 16px;
            border-radius: var(--radius-input);
            font-size: 0.88rem;
            font-weight: 600;
            margin-bottom: 20px;
            border: 2px solid var(--border-black);
        }

        .alert-danger {
            background-color: #fef2f2;
            color: #991b1b;
            border-color: #991b1b;
        }

        .alert-success {
            background-color: #f0fdf4;
            color: #166534;
            border-color: #166534;
        }

        .form-grid {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-label {
            font-size: 0.88rem;
            font-weight: 700;
            color: var(--text-black);
        }

        .input-container {
            position: relative;
            display: flex;
            align-items: center;
        }

        .form-input {
            width: 100%;
            height: 44px;
            padding: 0 14px;
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            border-radius: var(--radius-input);
            color: var(--text-black);
            font-family: inherit;
            font-size: 0.92rem;
            font-weight: 500;
            outline: none;
            transition: var(--transition);
        }

        .form-input::placeholder {
            color: #a1a1aa;
            font-weight: 400;
        }

        .form-input:focus {
            box-shadow: 0 0 0 2px rgba(0, 0, 0, 0.2);
        }

        .input-with-icon {
            padding-right: 44px;
        }

        .toggle-btn {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            padding: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--border-black);
            transition: opacity var(--transition);
        }

        .toggle-btn:hover {
            opacity: 0.7;
        }

        .toggle-btn svg {
            width: 22px;
            height: 22px;
            stroke: #000000;
        }

        .remember-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 2px;
        }

        .checkbox-wrap {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .custom-checkbox {
            width: 17px;
            height: 17px;
            accent-color: #000000;
            cursor: pointer;
        }

        .checkbox-label {
            font-size: 0.84rem;
            color: var(--text-muted);
            font-weight: 500;
            cursor: pointer;
            user-select: none;
        }

        .btn-wrapper {
            display: flex;
            justify-content: center;
            margin-top: 10px;
        }

        .btn-submit {
            width: 100%;
            max-width: 260px;
            height: 50px;
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            border-radius: var(--radius-btn);
            color: var(--text-black);
            font-family: inherit;
            font-size: 1.15rem;
            font-weight: 800;
            letter-spacing: -0.01em;
            cursor: pointer;
            transition: var(--transition);
        }

        .btn-submit:hover {
            background-color: #000000;
            color: #ffffff;
        }

        .btn-submit:active {
            transform: scale(0.98);
        }

        .card-footer {
            margin-top: 26px;
            text-align: center;
            font-size: 0.85rem;
            color: var(--text-muted);
        }

        .card-footer a {
            color: var(--text-black);
            font-weight: 700;
            text-decoration: underline;
            margin-left: 4px;
        }

        @media (max-width: 480px) {
            .card {
                padding: 32px 20px 24px;
            }
            .card-title {
                font-size: 1.65rem;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="card">
            <!-- Header -->
            <div class="card-header">
                <h1 class="card-title">Sign In</h1>
                <p class="card-subtitle">Welcome back! Please enter your details.</p>
            </div>

            <!-- Form -->
            <form id="loginForm" runat="server">
                <!-- Status Alerts -->
                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert-box alert-danger">
                    <asp:Label ID="lblErrorMessage" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert-box alert-success">
                    <asp:Label ID="lblSuccessMessage" runat="server" />
                </asp:Panel>

                <!-- Input Fields -->
                <div class="form-grid">
                    <!-- Email -->
                    <div class="form-group">
                        <label for="txtEmail" class="form-label">Email:</label>
                        <div class="input-container">
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-input" placeholder="" MaxLength="255" required="required" />
                        </div>
                    </div>

                    <!-- Password -->
                    <div class="form-group">
                        <label for="txtPassword" class="form-label">Password:</label>
                        <div class="input-container">
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-input input-with-icon" placeholder="" required="required" />
                            <button type="button" class="toggle-btn" onclick="togglePasswordVisibility('txtPassword', this);" aria-label="Toggle password visibility">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <!-- Remember Me -->
                    <div class="remember-row">
                        <div class="checkbox-wrap">
                            <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="custom-checkbox" />
                            <label for="chkRememberMe" class="checkbox-label">Remember me</label>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <div class="btn-wrapper">
                        <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn-submit" OnClick="btnLogin_Click" />
                    </div>
                </div>
            </form>

            <!-- Card Footer -->
            <div class="card-footer">
                Don't have an account? <a href="Signup.aspx">Create one</a>
            </div>
        </div>
    </div>

    <!-- Password Visibility Toggle Script -->
    <script>
        function togglePasswordVisibility(inputId, button) {
            var input = document.getElementById(inputId);
            if (!input) return;

            if (input.type === "password") {
                input.type = "text";
                button.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>';
            } else {
                input.type = "password";
                button.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>';
            }
        }
    </script>
</body>
</html>
```

---

## 4. Entire Code Snippet: `Login.aspx.cs`
File: `Frontend/Login/Login.aspx.cs`

```csharp
using System;
using System.Web;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.Login
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlError.Visible = false;
                pnlSuccess.Visible = false;

                // Pre-fill email if remembered from cookie
                if (Request.Cookies["RememberedEmail"] != null)
                {
                    txtEmail.Text = Request.Cookies["RememberedEmail"].Value;
                    chkRememberMe.Checked = true;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            pnlSuccess.Visible = false;

            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // 1. Authenticate using dedicated UserRepository.Login method and UserLogin model
            if (UserRepository.Login(email, password, out UserLogin authenticatedUser, out string errorMessage))
            {
                // 2. Establish user session
                Session["UserID"] = authenticatedUser.UserID;
                Session["UserEmail"] = authenticatedUser.Email;
                Session["FirstName"] = authenticatedUser.FirstName;
                Session["LastName"] = authenticatedUser.LastName;
                Session["FullName"] = $"{authenticatedUser.FirstName} {authenticatedUser.LastName}".Trim();

                // 3. Handle Remember Me cookie
                if (chkRememberMe.Checked)
                {
                    HttpCookie emailCookie = new HttpCookie("RememberedEmail", authenticatedUser.Email)
                    {
                        Expires = DateTime.UtcNow.AddDays(30)
                    };
                    Response.Cookies.Add(emailCookie);
                }
                else if (Request.Cookies["RememberedEmail"] != null)
                {
                    HttpCookie expiredCookie = new HttpCookie("RememberedEmail")
                    {
                        Expires = DateTime.UtcNow.AddDays(-1)
                    };
                    Response.Cookies.Add(expiredCookie);
                }

                // 4. Show success and redirect to User Dashboard
                pnlSuccess.Visible = true;
                lblSuccessMessage.Text = $"Welcome back, {authenticatedUser.FirstName}! Login successful. Redirecting to dashboard...";

                string redirectScript = "setTimeout(function(){ window.location.href = '../User/Dashboard.aspx'; }, 1500);";
                ClientScript.RegisterStartupScript(this.GetType(), "LoginRedirect", redirectScript, true);
            }
            else
            {
                // Display exact error message from repository
                pnlError.Visible = true;
                lblErrorMessage.Text = errorMessage;
            }
        }
    }
}
```

---

## 5. Sequential Documentation Index
- `01_Models_Guide.md`: Model architecture and `UserLogin` model.
- `02_UserRepository_Guide.md`: User repository (`Create`, `Login`, `ChangePassword`, `UpdateEmail`).
- `03_UserProfile_Guide.md`: Personal profile model and SQL schema mapping.
- `04_UserProfileRepository_Guide.md`: User profile repository (`Create`, `Update`, `GetByUserId`, `GetByProfileId`).
- `05_SocialLink_Model_Guide.md`: Social links model and schema mapping.
- `06_SocialLinkRepository_Guide.md`: Social links repository (full CRUD operations).
- `07_Hobby_Model_Guide.md`: Hobby model and web form walkthrough.
- `08_HobbyRepository_Guide.md`: Hobby repository (full CRUD operations).
- `09_Affiliation_Model_Guide.md`: Affiliation model and schema mapping.
- `10_AffiliationRepository_Guide.md`: Affiliation repository (full CRUD operations).
- `11_Education_Model_Guide.md`: Education model and schema mapping.
- `12_EducationRepository_Guide.md`: Education repository (full CRUD operations).
- `13_Skill_Model_Guide.md`: Skill model and SQL schema mapping.
- `14_SkillRepository_Guide.md`: Skill repository (full CRUD operations).
- `15_DashboardAnalytics_Model_Guide.md`: Dashboard analytics model (`TotalUsers`, `TotalActive`, `TotalInactive`).
- `16_DashboardAnalyticsRepository_Guide.md`: Dashboard analytics repository functions and code-behind instructions.
- `17_Signup_Frontend_Guide.md`: Signup.aspx dotted grid monochrome frontend design, model integration, and UserRepository workflow.
- `18_Login_Frontend_Guide.md`: Login.aspx dotted grid monochrome frontend design, authentication workflow, session handling, and UserRepository integration.
