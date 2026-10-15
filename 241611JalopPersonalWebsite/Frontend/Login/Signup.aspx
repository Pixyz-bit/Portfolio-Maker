<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.Login.Signup" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create Your Account | Personal Portfolio</title>
    <meta name="description" content="Sign up to create and manage your personal portfolio." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />

    <link rel="stylesheet" href="../Assets/css/signup.css" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Frontend/Assets/css/accessibility.css") %>?v=20261015e" />
    <script src="<%= ResolveUrl("~/Frontend/Assets/js/accessibility.js") %>?v=20261015e" defer></script>
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
                                <asp:TextBox ID="txtFirstName" runat="server" aria-required="true" CssClass="form-input" placeholder="" MaxLength="50" required="required" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="txtLastName" class="form-label">Last Name:</label>
                            <div class="input-container">
                                <asp:TextBox ID="txtLastName" runat="server" aria-required="true" CssClass="form-input" placeholder="" MaxLength="50" required="required" />
                            </div>
                        </div>
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <label for="txtEmail" class="form-label">Email:</label>
                        <div class="input-container">
                            <asp:TextBox ID="txtEmail" runat="server" aria-required="true" TextMode="Email" CssClass="form-input" placeholder="" MaxLength="255" required="required" />
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
                    <asp:Panel ID="pnlError" runat="server" role="alert" aria-live="assertive" aria-atomic="true" Visible="false" CssClass="toast-box toast-error">
                        <div class="toast-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        </div>
                        <div class="toast-content">
                            <span class="toast-title">Registration Failed</span>
                            <asp:Label ID="lblErrorMessage" runat="server" CssClass="toast-message" />
                        </div>
                        <button aria-label="Dismiss message" type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
                    </asp:Panel>

                    <asp:Panel ID="pnlSuccess" runat="server" role="status" aria-live="polite" aria-atomic="true" Visible="false" CssClass="toast-box toast-success">
                        <div class="toast-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                        </div>
                        <div class="toast-content">
                            <span class="toast-title">Success</span>
                            <asp:Label ID="lblSuccessMessage" runat="server" CssClass="toast-message" />
                        </div>
                        <button aria-label="Dismiss message" type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>
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
    <script src="../Assets/js/signup.js?v=20261015e"></script>
</body>
</html>
