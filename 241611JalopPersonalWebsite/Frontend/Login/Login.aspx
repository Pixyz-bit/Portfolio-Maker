<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.Login.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign In | Personal Portfolio</title>
    <meta name="description" content="Sign in to manage and customize your personal developer and professional portfolio." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><rect width='100' height='100' rx='20' fill='%23000'/><text x='50' y='70' font-size='60' text-anchor='middle' fill='%23fff' font-family='sans-serif' font-weight='bold'>P</text></svg>">

    <link rel="stylesheet" href="../Assets/css/login.css" />

    <script src="../Assets/js/login.js"></script>
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
                        <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn-submit" OnClick="btnLogin_Click" OnClientClick="if (this.form.checkValidity ? this.form.checkValidity() : true) { showLoadingScreen('Authenticating...', 'Verifying credentials with the server...'); }" />
                    </div>
                </div>

                <!-- Floating Lower-Right Toast Notifications -->
                <div class="toast-container" id="toastContainer">
                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="toast-box toast-error">
                        <div class="toast-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        </div>
                        <div class="toast-content">
                            <span class="toast-title">Authentication Failed</span>
                            <asp:Label ID="lblErrorMessage" runat="server" CssClass="toast-message" />
                        </div>
                        <button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
                    </asp:Panel>

                    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="toast-box toast-success">
                        <div class="toast-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                        </div>
                        <div class="toast-content">
                            <span class="toast-title">Success</span>
                            <asp:Label ID="lblSuccessMessage" runat="server" CssClass="toast-message" />
                        </div>
                        <button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
                    </asp:Panel>
                </div>
            </form>

            <!-- Card Footer -->
            <div class="card-footer">
                Don't have an account? <a href="Signup.aspx">Create one</a>
            </div>
        </div>
    </div>

    <!-- PROPER LOGIN SUCCESS & LOADING MODAL -->
    <div class="login-modal-overlay" id="loginSuccessModal" style="display: none;">
        <div class="login-modal-box">
            <div class="login-modal-icon-wrap">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                    <polyline points="22 4 12 14.01 9 11.01"></polyline>
                </svg>
            </div>

            <h3 class="login-modal-title">Sign In Successful!</h3>
            <p class="login-modal-desc" id="loginModalSubtitle">
                Welcome back, <strong id="loginModalUserName">User</strong>! Preparing your workspace...
            </p>

            <div class="login-progress-track">
                <div class="login-progress-bar" id="loginProgressBar"></div>
            </div>

            <span class="login-redirect-text">Redirecting to your dashboard...</span>
        </div>
    </div>

    <!-- Universal Interactive Loading Screen -->
    <div class="loading-overlay" id="loadingOverlay" style="display: none;">
        <div class="loading-box">
            <div class="loading-spinner-wrap">
                <div class="retro-spinner"></div>
            </div>
            <h3 class="loading-title" id="loadingTitle">Authenticating...</h3>
            <p class="loading-desc" id="loadingDesc">Checking security credentials with the server...</p>
        </div>
    </div>

    <!-- Scripts are defined in head -->
</body>
</html>
