<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.Login.Signup" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create Your Account | Personal Portfolio</title>
    <meta name="description" content="Sign up to create and manage your personal portfolio." />

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

        .signup-container {
            width: 100%;
            max-width: 500px;
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
            font-weight: 500;
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

        /* Form Structure */
        .form-grid {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .form-row-dual {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }

        @media (max-width: 480px) {
            .form-row-dual {
                grid-template-columns: 1fr;
            }
            .card {
                padding: 30px 20px 24px;
            }
            .card-title {
                font-size: 1.6rem;
            }
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
            margin-top: 24px;
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
    </style>
</head>
<body>
    <div class="signup-container">
        <div class="card">
            <!-- Header -->
            <div class="card-header">
                <h1 class="card-title">Create Your Account</h1>
                <p class="card-subtitle">Enter your details below to register your profile.</p>
            </div>

            <!-- Form -->
            <form id="signupForm" runat="server">
                <!-- Input Fields -->
                <asp:Panel ID="pnlFormFields" runat="server" CssClass="form-grid">
                    <!-- First Name & Last Name Dual Row -->
                    <div class="form-row-dual">
                        <div class="form-group">
                            <label for="txtFirstName" class="form-label">First Name</label>
                            <div class="input-container">
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-input" placeholder="" MaxLength="50" required="required" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="txtLastName" class="form-label">Last Name:</label>
                            <div class="input-container">
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-input" placeholder="" MaxLength="50" required="required" />
                            </div>
                        </div>
                    </div>

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

                    <!-- Confirm Password -->
                    <div class="form-group">
                        <label for="txtConfirmPassword" class="form-label">Confirm Password:</label>
                        <div class="input-container">
                            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-input input-with-icon" placeholder="" required="required" />
                            <button type="button" class="toggle-btn" onclick="togglePasswordVisibility('txtConfirmPassword', this);" aria-label="Toggle confirm password visibility">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                    <circle cx="12" cy="12" r="3"></circle>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <!-- Submit Button matching image -->
                    <div class="btn-wrapper">
                        <asp:Button ID="btnRegister" runat="server" Text="Create Account" CssClass="btn-submit" OnClick="btnRegister_Click" OnClientClick="if (this.form.checkValidity ? this.form.checkValidity() : true) { showLoadingScreen('Creating Account...', 'Registering your profile with the database...'); }" />
                    </div>
                </asp:Panel>

                <!-- Floating Lower-Right Toast Notifications -->
                <div class="toast-container" id="toastContainer">
                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="toast-box toast-error">
                        <div class="toast-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        </div>
                        <div class="toast-content">
                            <span class="toast-title">Registration Failed</span>
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
                Already have an account? <a href="Login.aspx">Sign in</a>
            </div>
        </div>
    </div>

    <!-- Universal Interactive Loading Screen Overlay -->
    <div class="loading-overlay" id="loadingOverlay" style="display: none;">
        <div class="loading-box">
            <div class="loading-spinner-wrap">
                <div class="retro-spinner"></div>
            </div>
            <h3 class="loading-title" id="loadingTitle">Creating Account...</h3>
            <p class="loading-desc" id="loadingDesc">Registering your profile with the database...</p>
        </div>
    </div>

    <!-- Client-Side Scripts -->
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

        function handleSignupError() {
            showLoadingScreen('Validating Registration...', 'Checking account availability...');
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

        function handleSignupSuccess() {
            showLoadingScreen('Account Created!', 'Redirecting you to sign in...');
            setTimeout(function () {
                hideLoadingScreen();
            }, 1000);
        }
    </script>
</body>
</html>
