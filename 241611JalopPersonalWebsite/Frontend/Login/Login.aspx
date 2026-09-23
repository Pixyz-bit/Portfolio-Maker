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

        /* Status Alerts */
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

    <!-- Scripts are defined in head -->
</body>
</html>
