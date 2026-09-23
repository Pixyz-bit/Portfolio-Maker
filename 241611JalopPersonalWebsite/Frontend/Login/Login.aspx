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

        /* Outline Card with Matching Dotted Grid */
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

        /* Floating Lower-Right Toast Notifications */
        .toast-container {
            position: fixed;
            bottom: 24px;
            right: 24px;
            z-index: 100000;
            display: flex;
            flex-direction: column;
            gap: 12px;
            max-width: 420px;
            width: calc(100vw - 48px);
            pointer-events: none;
        }

        .toast-box {
            pointer-events: auto;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 14px 18px;
            border-radius: 12px;
            border: 2px solid #000000;
            box-shadow: 4px 4px 0px #000000;
            background-color: #ffffff;
            animation: toastSlideUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) forwards;
            transition: opacity 0.25s ease, transform 0.25s ease;
        }

        @keyframes toastSlideUp {
            from {
                opacity: 0;
                transform: translateY(24px) scale(0.96);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .toast-box.toast-error {
            background-color: #fef2f2;
            border-color: #ef4444;
            color: #991b1b;
            box-shadow: 4px 4px 0px #ef4444;
        }

        .toast-box.toast-success {
            background-color: #f0fdf4;
            border-color: #16a34a;
            color: #166534;
            box-shadow: 4px 4px 0px #16a34a;
        }

        .toast-icon {
            flex-shrink: 0;
            margin-top: 2px;
        }

        .toast-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 3px;
        }

        .toast-title {
            font-size: 0.85rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            line-height: 1.2;
        }

        .toast-message {
            font-size: 0.88rem;
            font-weight: 600;
            line-height: 1.4;
        }

        .toast-close-btn {
            background: transparent;
            border: none;
            font-size: 1.3rem;
            line-height: 1;
            cursor: pointer;
            color: inherit;
            padding: 0 2px;
            font-weight: 800;
            opacity: 0.75;
            transition: opacity 0.2s ease;
        }

        .toast-close-btn:hover {
            opacity: 1;
        }

        @media (max-width: 480px) {
            .toast-container {
                bottom: 16px;
                right: 16px;
                left: 16px;
                width: auto;
                max-width: none;
            }
        }

        /* Universal Interactive Loading Screen Overlay */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.65);
            backdrop-filter: blur(6px);
            z-index: 99999;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .loading-box {
            background-color: #ffffff;
            border: 2.5px solid #000000;
            border-radius: 16px;
            box-shadow: 6px 6px 0px #000000;
            width: 100%;
            max-width: 380px;
            padding: 34px 26px;
            text-align: center;
            animation: loadingPop 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes loadingPop {
            from { opacity: 0; transform: scale(0.92) translateY(8px); }
            to { opacity: 1; transform: scale(1) translateY(0); }
        }

        .loading-spinner-wrap {
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }

        .retro-spinner {
            width: 44px;
            height: 44px;
            border: 4px solid #f4f4f5;
            border-top: 4px solid #000000;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading-title {
            font-size: 1.35rem;
            font-weight: 800;
            color: #000000;
            margin-bottom: 8px;
            letter-spacing: -0.02em;
        }

        .loading-desc {
            font-size: 0.88rem;
            color: #52525b;
            line-height: 1.45;
            margin: 0;
        }

        /* Form Controls */
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

        /* Crisp Solid Black Border Input */
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

        /* Eye Icon Button */
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

        /* Remember Row */
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

        /* Submit Button matching image */
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

        /* Card Footer */
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

        /* Proper Login Loading Modal */
        .login-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.65);
            backdrop-filter: blur(5px);
            z-index: 10000;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .login-modal-box {
            background-color: #ffffff;
            border: 2.5px solid #000000;
            border-radius: 20px;
            box-shadow: 8px 8px 0px #000000;
            width: 100%;
            max-width: 400px;
            padding: 38px 30px;
            text-align: center;
            position: relative;
            animation: modalPop 0.25s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes modalPop {
            from { opacity: 0; transform: scale(0.92); }
            to { opacity: 1; transform: scale(1); }
        }

        .login-modal-icon-wrap {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            border: 2.5px solid #000000;
            background-color: #dcfce7;
            margin: 0 auto 18px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-modal-title {
            font-size: 1.45rem;
            font-weight: 800;
            color: #000000;
            margin-bottom: 6px;
            letter-spacing: -0.02em;
        }

        .login-modal-desc {
            font-size: 0.9rem;
            color: #52525b;
            margin-bottom: 22px;
            line-height: 1.45;
        }

        .login-progress-track {
            width: 100%;
            height: 8px;
            background-color: #f4f4f5;
            border: 2px solid #000000;
            border-radius: 999px;
            overflow: hidden;
            margin-bottom: 12px;
        }

        .login-progress-bar {
            width: 0%;
            height: 100%;
            background-color: #000000;
            border-radius: 999px;
            transition: width 1.25s cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        .login-redirect-text {
            font-size: 0.78rem;
            font-weight: 700;
            color: #71717a;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            display: block;
        }
    </style>

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

        window.showLoginSuccessModal = function (userName, redirectUrl) {
            function executeModal() {
                var modal = document.getElementById('loginSuccessModal');
                var userEl = document.getElementById('loginModalUserName');
                var progressBar = document.getElementById('loginProgressBar');
                if (userEl) userEl.textContent = userName || 'User';
                if (modal) modal.style.display = 'flex';
                setTimeout(function () {
                    if (progressBar) progressBar.style.width = '100%';
                }, 50);
                setTimeout(function () {
                    window.location.href = redirectUrl;
                }, 1300);
            }

            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', executeModal);
            } else {
                executeModal();
            }
        };
        var showLoginSuccessModal = window.showLoginSuccessModal;

        function showLoadingScreen(title, desc) {
            var overlay = document.getElementById('loadingOverlay');
            if (title) document.getElementById('loadingTitle').textContent = title;
            if (desc) document.getElementById('loadingDesc').textContent = desc;
            if (overlay) overlay.style.display = 'flex';
        }

        function hideLoadingScreen() {
            var overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'none';
        }

        function dismissToast(btn) {
            var toast = btn.closest('.toast-box');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(16px)';
                setTimeout(function () { toast.style.display = 'none'; }, 250);
            }
        }

        function handleLoginError() {
            showLoadingScreen('Authenticating...', 'Verifying credentials with the database...');
            setTimeout(function () {
                hideLoadingScreen();
                var errToast = document.querySelector('.toast-box.toast-error');
                if (errToast) {
                    setTimeout(function () {
                        var btn = errToast.querySelector('.toast-close-btn');
                        if (btn) dismissToast(btn);
                    }, 5000);
                }
            }, 650);
        }

        function autoDismissSuccessToast() {
            var successToast = document.querySelector('.toast-box.toast-success');
            if (successToast) {
                setTimeout(function () {
                    var btn = successToast.querySelector('.toast-close-btn');
                    if (btn) dismissToast(btn);
                }, 5000);
            }
        }

        window.addEventListener('DOMContentLoaded', function () {
            autoDismissSuccessToast();
        });
    </script>
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
