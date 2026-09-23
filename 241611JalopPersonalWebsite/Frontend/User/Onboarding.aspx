<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Onboarding.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Onboarding" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Portfolio Onboarding & Setup | Personal Portfolio</title>
    <meta name="description" content="Set up your personal portfolio details, education, skills, affiliations, hobbies, and social links." />

    <!-- Local Offline Fonts: Plus Jakarta Sans & Inter -->
    <link rel="stylesheet" href="../Assets/fonts/fonts.css" />

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
            padding: 40px 16px;
        }

        .onboarding-container {
            width: 100%;
            max-width: 840px;
        }

        /* Outline Card with Matching Dotted Grid */
        .card {
            background-color: var(--card-bg);
            background-image: radial-gradient(var(--dot-color) 1.2px, transparent 1.2px);
            background-size: 16px 16px;
            border: 2.5px solid var(--border-black);
            border-radius: var(--radius-card);
            padding: 40px 36px 36px;
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.05);
        }

        /* Top Action Bar */
        .top-action-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
        }

        .badge-tag {
            display: inline-block;
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            background-color: #000000;
            color: #ffffff;
            padding: 4px 12px;
            border-radius: 999px;
        }

        .quick-view-btn {
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            border-radius: var(--radius-btn);
            color: var(--text-black);
            font-family: inherit;
            font-size: 0.85rem;
            font-weight: 800;
            padding: 6px 14px;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: var(--transition);
        }

        .quick-view-btn:hover {
            background-color: #000000;
            color: #ffffff;
        }

        .card-header {
            text-align: center;
            margin-bottom: 26px;
        }

        .card-title {
            font-size: 2.1rem;
            font-weight: 800;
            letter-spacing: -0.03em;
            color: var(--text-black);
            margin-bottom: 6px;
        }

        .card-subtitle {
            font-size: 0.95rem;
            color: var(--text-muted);
            font-family: 'Inter', sans-serif;
            font-weight: 500;
        }

        /* Step Progress Wizard Bar */
        .step-indicator {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 34px;
            padding: 0 4px;
        }

        .step-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            background: transparent;
            border: none;
            flex-shrink: 0;
            padding: 0;
            z-index: 2;
        }

        /* Connecting Lines strictly between bubbles - NEVER exceeds outer circles */
        .step-line {
            flex: 1;
            height: 2.5px;
            background-color: #e2e8f0;
            margin-top: 18px; /* Aligned with the center of the 38px bubble */
            margin-left: 6px;
            margin-right: 6px;
            transition: background-color 0.25s ease;
        }

        .step-line.active {
            background-color: #000000;
        }

        .step-bubble {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            border: 2px solid #000000;
            background-color: #ffffff;
            color: #000000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.95rem;
            font-weight: 800;
            transition: var(--transition);
        }

        .step-item.active .step-bubble {
            background-color: #000000;
            color: #ffffff;
            box-shadow: 0 0 0 4px rgba(0, 0, 0, 0.1);
        }

        .step-item.completed .step-bubble {
            background-color: #000000;
            color: #ffffff;
        }

        .step-label {
            font-size: 0.78rem;
            font-weight: 700;
            color: var(--text-muted);
            white-space: nowrap;
            transition: var(--transition);
        }

        .step-item.active .step-label {
            color: #000000;
            font-weight: 800;
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

        /* Wizard Step Content */
        .step-section {
            display: none;
            animation: fadeIn 0.25s ease-in-out;
        }

        .step-section.active-step {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .section-header {
            margin-bottom: 22px;
            padding-bottom: 12px;
            border-bottom: 2px solid #000000;
        }

        .section-title {
            font-size: 1.35rem;
            font-weight: 800;
            letter-spacing: -0.02em;
        }

        .section-desc {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-family: 'Inter', sans-serif;
            margin-top: 3px;
        }

        /* Form Layout */
        .form-grid {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .form-row-dual {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .form-label {
            font-size: 0.86rem;
            font-weight: 700;
            color: var(--text-black);
            display: flex;
            justify-content: space-between;
        }

        .label-hint {
            font-size: 0.78rem;
            font-weight: 500;
            color: var(--text-muted);
        }

        .form-input, .form-textarea {
            width: 100%;
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

        .form-input {
            height: 44px;
            padding: 0 14px;
        }

        .form-textarea {
            padding: 12px 14px;
            resize: vertical;
            min-height: 90px;
        }

        .form-input:focus, .form-textarea:focus {
            box-shadow: 0 0 0 2px rgba(0, 0, 0, 0.18);
        }

        .form-input.is-invalid, .form-textarea.is-invalid {
            border-color: #ef4444 !important;
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.25) !important;
        }

        /* Profile Image Upload Box */
        .photo-upload-wrapper {
            display: flex;
            align-items: center;
            gap: 20px;
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            border-radius: var(--radius-card);
            padding: 16px 20px;
            margin-bottom: 6px;
        }

        .avatar-preview {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 2px solid var(--border-black);
            object-fit: cover;
            background-color: #f4f4f5;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
        }

        .avatar-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .avatar-info {
            flex-grow: 1;
        }

        .avatar-info h4 {
            font-size: 0.92rem;
            font-weight: 800;
            margin-bottom: 4px;
        }

        .avatar-info p {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-bottom: 10px;
            font-family: 'Inter', sans-serif;
        }

        .file-upload-input {
            font-size: 0.82rem;
            font-family: 'Inter', sans-serif;
        }

        /* Section Item Box */
        .item-card {
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            border-radius: 12px;
            padding: 18px;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .item-card-title {
            font-size: 0.95rem;
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .item-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 10px;
            border-bottom: 1.5px solid #e2e8f0;
            margin-bottom: 2px;
        }

        .item-card-badge {
            font-size: 0.88rem;
            font-weight: 800;
            color: var(--text-black);
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-delete-card {
            background-color: transparent;
            border: 1.5px solid #dc2626;
            color: #dc2626;
            font-size: 0.8rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 6px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: var(--transition);
        }

        .btn-delete-card:hover {
            background-color: #dc2626;
            color: #ffffff;
        }

        .btn-add-item {
            width: auto;
            height: 44px;
            padding: 0 20px;
            font-size: 0.9rem;
            font-weight: 800;
            border: 2px dashed var(--border-black);
            background-color: #fafafa;
        }

        .btn-add-item:hover {
            background-color: #000000;
            color: #ffffff;
            border-style: solid;
        }

        .dynamic-list-container {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .sub-section-title {
            font-size: 1.15rem;
            font-weight: 800;
            margin-bottom: 12px;
            letter-spacing: -0.01em;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .dynamic-empty-hint {
            padding: 18px;
            background-color: #f8fafc;
            border: 1.5px dashed #cbd5e1;
            border-radius: 10px;
            font-size: 0.88rem;
            color: #64748b;
            text-align: center;
        }

        /* Wizard Footer Controls */
        .wizard-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 36px;
            padding-top: 24px;
            border-top: 2px solid var(--border-black);
            gap: 12px;
            flex-wrap: wrap;
        }

        .footer-actions-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .footer-actions-right {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .btn {
            height: 48px;
            padding: 0 24px;
            font-family: inherit;
            font-size: 0.95rem;
            font-weight: 800;
            letter-spacing: -0.01em;
            border-radius: var(--radius-btn);
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-outline {
            background-color: #ffffff;
            border: 2px solid var(--border-black);
            color: var(--text-black);
        }

        .btn-outline:hover {
            background-color: #f4f4f5;
        }

        .btn-solid {
            background-color: #000000;
            border: 2px solid #000000;
            color: #ffffff;
        }

        .btn-solid:hover {
            background-color: #27272a;
            border-color: #27272a;
        }

        .btn:active {
            transform: scale(0.98);
        }

        @media (max-width: 640px) {
            .card {
                padding: 26px 18px 24px;
            }
            .form-row-dual {
                grid-template-columns: 1fr;
            }
            .step-label {
                display: none;
            }
            .photo-upload-wrapper {
                flex-direction: column;
                text-align: center;
            }
            .wizard-footer {
                flex-direction: column;
                align-items: stretch;
            }
            .footer-actions-right, .footer-actions-left {
                width: 100%;
                flex-direction: column;
            }
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="onboarding-container">
        <div class="card">
            <form id="onboardingForm" runat="server" enctype="multipart/form-data">
                <div class="card-header">
                    <span class="badge-tag">Portfolio Creator</span>
                    <h1 class="card-title">Profile Onboarding</h1>
                    <p class="card-subtitle">Fill in your information at your own pace. Save & Exit anytime to view your portfolio.</p>
                </div>

                <!-- 5-Step Progress Bar with Segmented Connectors -->
                <div class="step-indicator">
                    <button type="button" class="step-item active" id="indicator1" onclick="jumpToStep(1);">
                        <div class="step-bubble">1</div>
                        <span class="step-label">Profile</span>
                    </button>
                    <div class="step-line" id="line1"></div>

                    <button type="button" class="step-item" id="indicator2" onclick="jumpToStep(2);">
                        <div class="step-bubble">2</div>
                        <span class="step-label">Education</span>
                    </button>
                    <div class="step-line" id="line2"></div>

                    <button type="button" class="step-item" id="indicator3" onclick="jumpToStep(3);">
                        <div class="step-bubble">3</div>
                        <span class="step-label">Skills</span>
                    </button>
                    <div class="step-line" id="line3"></div>

                    <button type="button" class="step-item" id="indicator4" onclick="jumpToStep(4);">
                        <div class="step-bubble">4</div>
                        <span class="step-label">Affiliations & Hobbies</span>
                    </button>
                    <div class="step-line" id="line4"></div>

                    <button type="button" class="step-item" id="indicator5" onclick="jumpToStep(5);">
                        <div class="step-bubble">5</div>
                        <span class="step-label">Social Links</span>
                    </button>
                </div>

                <!-- Hidden fields to preserve state across postbacks -->
                <asp:HiddenField ID="hfCurrentStep" runat="server" Value="1" />
                <asp:HiddenField ID="hfExistingImagePath" runat="server" Value="" />
                <asp:HiddenField ID="hfEducationsJson" runat="server" Value="" />
                <asp:HiddenField ID="hfSkillsJson" runat="server" Value="" />
                <asp:HiddenField ID="hfAffiliationsJson" runat="server" Value="" />
                <asp:HiddenField ID="hfHobbiesJson" runat="server" Value="" />
                <asp:HiddenField ID="hfSocialLinksJson" runat="server" Value="" />

                <!-- ======================================================= -->
                <!-- STEP 1: Personal Profile (UserProfile)                  -->
                <!-- ======================================================= -->
                <div class="step-section active-step" id="step1">
                    <div class="section-header">
                        <h2 class="section-title">Step 1: Personal Profile</h2>
                        <p class="section-desc">Manage your core identity, biography, and contact credentials.</p>
                    </div>

                    <div class="form-grid">
                        <!-- Profile Image Upload -->
                        <div class="photo-upload-wrapper">
                            <div class="avatar-preview">
                                <asp:Image ID="imgProfilePreview" runat="server" ImageUrl="data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='80' height='80' viewBox='0 0 24 24' fill='none' stroke='%23000' stroke-width='1.5'><path d='M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2'></path><circle cx='12' cy='7' r='4'></circle></svg>" AlternateText="Profile Preview" />
                            </div>
                            <div class="avatar-info">
                                <h4>Profile Picture</h4>
                                <p>Upload a high-resolution JPG, PNG, or WEBP portrait (max 2MB).</p>
                                <asp:FileUpload ID="fileProfileImage" runat="server" CssClass="file-upload-input" onchange="previewAvatar(this);" />
                            </div>
                        </div>

                        <!-- First Name & Last Name -->
                        <div class="form-row-dual">
                            <div class="form-group">
                                <label for="txtFirstName" class="form-label">First Name *</label>
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-input" MaxLength="50" placeholder="e.g. John" />
                            </div>
                            <div class="form-group">
                                <label for="txtLastName" class="form-label">Last Name *</label>
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-input" MaxLength="50" placeholder="e.g. Doe" />
                            </div>
                        </div>

                        <!-- Birthday & Address -->
                        <div class="form-row-dual">
                            <div class="form-group">
                                <label for="txtBirthday" class="form-label">Date of Birth</label>
                                <asp:TextBox ID="txtBirthday" runat="server" TextMode="Date" CssClass="form-input" />
                            </div>
                            <div class="form-group">
                                <label for="txtAddress" class="form-label">Location / Address</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-input" MaxLength="255" placeholder="e.g. Cagayan de Oro City, Philippines" />
                            </div>
                        </div>

                        <!-- Contact Email & Contact Number -->
                        <div class="form-row-dual">
                            <div class="form-group">
                                <label for="txtContactEmail" class="form-label">Public Contact Email</label>
                                <asp:TextBox ID="txtContactEmail" runat="server" TextMode="Email" CssClass="form-input" MaxLength="255" placeholder="e.g. name@example.com" />
                            </div>
                            <div class="form-group">
                                <label for="txtContactNum" class="form-label">Contact / Mobile Number</label>
                                <asp:TextBox ID="txtContactNum" runat="server" CssClass="form-input" MaxLength="11" placeholder="e.g. 09123456789" oninput="this.value = this.value.replace(/\D/g, '').slice(0, 11);" />
                            </div>
                        </div>

                        <!-- Description / Bio -->
                        <div class="form-group">
                            <label for="txtDescription" class="form-label">About Me / Bio</label>
                            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-textarea" placeholder="Write a summary about yourself, your background, and your career aspirations..." />
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <div class="footer-actions-left"></div>
                        <div class="footer-actions-right">
                            <asp:Button ID="btnSaveStep1" runat="server" Text="Save & Exit" CssClass="btn btn-outline" OnClick="btnSaveChanges_Click" CausesValidation="false" OnClientClick="if (!validateStep(1)) return false; serializeDynamicData();" />
                            <button type="button" class="btn btn-solid" onclick="nextStep(1);">Continue</button>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 2: Education (Education — Dynamic List)           -->
                <!-- ======================================================= -->
                <div class="step-section" id="step2">
                    <div class="section-header">
                        <h2 class="section-title">Step 2: Education History</h2>
                        <p class="section-desc">Add your academic background, universities, degrees, and graduation years.</p>
                    </div>

                    <div class="form-grid">
                        <div class="dynamic-list-container" id="educationList"></div>
                        <div>
                            <button type="button" class="btn btn-outline btn-add-item" onclick="addEducation();">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                Add Another Education
                            </button>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <div class="footer-actions-left">
                            <button type="button" class="btn btn-outline" onclick="prevStep(2);">Back</button>
                        </div>
                        <div class="footer-actions-right">
                            <asp:Button ID="btnSaveStep2" runat="server" Text="Save & Exit" CssClass="btn btn-outline" OnClick="btnSaveChanges_Click" CausesValidation="false" OnClientClick="serializeDynamicData();" />
                            <button type="button" class="btn btn-solid" onclick="nextStep(2);">Continue</button>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 3: Skills (Skill — Dynamic List)                  -->
                <!-- ======================================================= -->
                <div class="step-section" id="step3">
                    <div class="section-header">
                        <h2 class="section-title">Step 3: Skills & Competencies</h2>
                        <p class="section-desc">Highlight your technical proficiencies, frameworks, tools, and expertise.</p>
                    </div>

                    <div class="form-grid">
                        <div class="dynamic-list-container" id="skillList"></div>
                        <div>
                            <button type="button" class="btn btn-outline btn-add-item" onclick="addSkill();">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                Add Another Skill
                            </button>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <div class="footer-actions-left">
                            <button type="button" class="btn btn-outline" onclick="prevStep(3);">Back</button>
                        </div>
                        <div class="footer-actions-right">
                            <asp:Button ID="btnSaveStep3" runat="server" Text="Save & Exit" CssClass="btn btn-outline" OnClick="btnSaveChanges_Click" CausesValidation="false" OnClientClick="serializeDynamicData();" />
                            <button type="button" class="btn btn-solid" onclick="nextStep(3);">Continue</button>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 4: Affiliations & Hobbies (Dynamic Lists)          -->
                <!-- ======================================================= -->
                <div class="step-section" id="step4">
                    <div class="section-header">
                        <h2 class="section-title">Step 4: Affiliations & Hobbies</h2>
                        <p class="section-desc">Showcase your organization memberships, leadership roles, and personal passions.</p>
                    </div>

                    <div class="form-grid">
                        <div class="sub-section-title">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                            Organizations & Affiliations
                        </div>
                        <div class="dynamic-list-container" id="affiliationList"></div>
                        <div style="margin-bottom: 24px;">
                            <button type="button" class="btn btn-outline btn-add-item" onclick="addAffiliation();">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                Add Another Affiliation
                            </button>
                        </div>

                        <div class="sub-section-title">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                            Personal Hobbies & Interests
                        </div>
                        <div class="dynamic-list-container" id="hobbyList"></div>
                        <div>
                            <button type="button" class="btn btn-outline btn-add-item" onclick="addHobby();">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                Add Another Hobby
                            </button>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <div class="footer-actions-left">
                            <button type="button" class="btn btn-outline" onclick="prevStep(4);">Back</button>
                        </div>
                        <div class="footer-actions-right">
                            <asp:Button ID="btnSaveStep4" runat="server" Text="Save & Exit" CssClass="btn btn-outline" OnClick="btnSaveChanges_Click" CausesValidation="false" OnClientClick="serializeDynamicData();" />
                            <button type="button" class="btn btn-solid" onclick="nextStep(4);">Continue</button>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 5: Social Links (SocialLink — Dynamic List)        -->
                <!-- ======================================================= -->
                <div class="step-section" id="step5">
                    <div class="section-header">
                        <h2 class="section-title">Step 5: Social & Web Presence</h2>
                        <p class="section-desc">Connect your online profiles, social channels, and portfolio links for visitors to reach you.</p>
                    </div>

                    <div class="form-grid">
                        <div class="dynamic-list-container" id="socialLinkList"></div>
                        <div>
                            <button type="button" class="btn btn-outline btn-add-item" onclick="addSocialLink();">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                                Add Another Social Link
                            </button>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <div class="footer-actions-left">
                            <button type="button" class="btn btn-outline" onclick="prevStep(5);">Back</button>
                        </div>
                        <div class="footer-actions-right">
                            <asp:Button ID="btnSaveStep5" runat="server" Text="Save & Exit" CssClass="btn btn-outline" OnClick="btnSaveChanges_Click" CausesValidation="false" OnClientClick="serializeDynamicData();" />
                            <asp:Button ID="btnCompleteOnboarding" runat="server" Text="Complete & Launch Portfolio" CssClass="btn btn-solid" OnClick="btnCompleteOnboarding_Click" OnClientClick="if (!validateStep(1)) { setStep(1); return false; } serializeDynamicData();" />
                        </div>
                    </div>
                </div>

                <!-- Floating Lower-Right Toast Notifications -->
                <div class="toast-container" id="toastContainer">
                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="toast-box toast-error">
                        <div class="toast-icon">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
                        </div>
                        <div class="toast-content">
                            <span class="toast-title">Notice</span>
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
        </div>
    </div>

    <!-- Wizard Navigation & Avatar Preview Script -->
    <script>
        var currentStep = 1;
        var totalSteps = 5;

        function setStep(step) {
            currentStep = step;
            document.getElementById('<%= hfCurrentStep.ClientID %>').value = step;

            // Hide all sections
            for (var i = 1; i <= totalSteps; i++) {
                var sec = document.getElementById('step' + i);
                var ind = document.getElementById('indicator' + i);
                if (sec) sec.classList.remove('active-step');
                if (ind) {
                    ind.classList.remove('active');
                    if (i < step) ind.classList.add('completed');
                    else ind.classList.remove('completed');
                }
            }

            // Show active section
            var activeSec = document.getElementById('step' + step);
            var activeInd = document.getElementById('indicator' + step);
            if (activeSec) activeSec.classList.add('active-step');
            if (activeInd) activeInd.classList.add('active');

            // Update connector lines between bubbles
            for (var j = 1; j < totalSteps; j++) {
                var line = document.getElementById('line' + j);
                if (line) {
                    if (j < step) {
                        line.classList.add('active');
                    } else {
                        line.classList.remove('active');
                    }
                }
            }

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        function nextStep(current) {
            if (validateStep(current)) {
                if (current < totalSteps) {
                    setStep(current + 1);
                }
            }
        }

        function prevStep(current) {
            if (current > 1) {
                setStep(current - 1);
            }
        }

        function jumpToStep(step) {
            // Allow jumping freely between steps
            setStep(step);
        }

        function escapeToastHtml(str) {
            if (!str) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function showToast(title, message, isError) {
            if (typeof isError === 'undefined') isError = true;
            var container = document.getElementById('toastContainer');
            if (!container) {
                container = document.createElement('div');
                container.id = 'toastContainer';
                container.className = 'toast-container';
                document.body.appendChild(container);
            }

            // Remove previous client toasts to avoid clutter
            var oldToasts = container.querySelectorAll('.client-toast');
            for (var i = 0; i < oldToasts.length; i++) {
                if (oldToasts[i].parentNode) {
                    oldToasts[i].parentNode.removeChild(oldToasts[i]);
                }
            }

            var toast = document.createElement('div');
            toast.className = 'toast-box client-toast ' + (isError ? 'toast-error' : 'toast-success');

            var iconSvg = isError
                ? '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>'
                : '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>';

            toast.innerHTML =
                '<div class="toast-icon">' + iconSvg + '</div>' +
                '<div class="toast-content">' +
                    '<span class="toast-title">' + escapeToastHtml(title || (isError ? 'Validation Error' : 'Notice')) + '</span>' +
                    '<span class="toast-message">' + escapeToastHtml(message) + '</span>' +
                '</div>' +
                '<button type="button" class="toast-close-btn" onclick="dismissToast(this)">&times;</button>';

            container.appendChild(toast);

            // Auto dismiss after 5 seconds
            setTimeout(function () {
                var btn = toast.querySelector('.toast-close-btn');
                if (btn) dismissToast(btn);
            }, 5000);
        }

        function markInvalid(el) {
            if (!el) return;
            el.classList.add('is-invalid');
            el.focus();
            var removeHandler = function () {
                el.classList.remove('is-invalid');
                el.removeEventListener('input', removeHandler);
            };
            el.addEventListener('input', removeHandler);
        }

        function validateStep(step) {
            if (step === 1) {
                var fnEl = document.getElementById('<%= txtFirstName.ClientID %>');
                var lnEl = document.getElementById('<%= txtLastName.ClientID %>');
                var fn = fnEl ? fnEl.value.trim() : '';
                var ln = lnEl ? lnEl.value.trim() : '';

                if (!fn || !ln) {
                    showToast('Validation Error', 'Please enter your First Name and Last Name to continue.');
                    if (!fn && fnEl) markInvalid(fnEl);
                    else if (!ln && lnEl) markInvalid(lnEl);
                    return false;
                }

                var emailEl = document.getElementById('<%= txtContactEmail.ClientID %>');
                var email = emailEl ? emailEl.value.trim() : '';
                if (email) {
                    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(email)) {
                        showToast('Validation Error', 'Please enter a valid Public Contact Email address (e.g. name@example.com).');
                        markInvalid(emailEl);
                        return false;
                    }
                }

                var phoneEl = document.getElementById('<%= txtContactNum.ClientID %>');
                var phone = phoneEl ? phoneEl.value.trim() : '';
                if (phone) {
                    var cleanPhone = phone.replace(/\D/g, '');
                    if (cleanPhone.length !== 11) {
                        showToast('Validation Error', 'Contact / Mobile Number must be exactly 11 digits (e.g. 09123456789).');
                        markInvalid(phoneEl);
                        return false;
                    }
                }
            }
            return true;
        }

        function previewAvatar(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    var previewImg = document.getElementById('<%= imgProfilePreview.ClientID %>');
                    if (previewImg) previewImg.src = e.target.result;
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        // =========================================================================
        // Dynamic List Management (Add, Remove, Reindex, Serialize)
        // =========================================================================
        function escapeHtml(str) {
            if (str === null || str === undefined) return '';
            return String(str)
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#039;');
        }

        function removeDynamicCard(btn, containerId, titlePrefix) {
            var card = btn.closest('.item-card');
            if (!card) return;
            var container = document.getElementById(containerId);
            card.remove();
            reindexCards(containerId, titlePrefix);
            serializeDynamicData();
        }

        function reindexCards(containerId, titlePrefix) {
            var container = document.getElementById(containerId);
            if (!container) return;
            var cards = container.querySelectorAll('.item-card');
            cards.forEach(function (c, idx) {
                var badge = c.querySelector('.badge-title');
                if (badge) {
                    badge.textContent = titlePrefix + ' #' + (idx + 1);
                }
            });
        }

        // 1. Education
        function addEducation(data) {
            data = data || {};
            var container = document.getElementById('educationList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card education-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 10v6M2 10l10-5 10 5-10 5z"></path><path d="M6 12v5c3 3 9 3 12 0v-5"></path></svg>' +
                        '<span class="badge-title">Education #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'educationList\', \'Education\');" title="Remove this education record">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Degree / Course Name *</label>' +
                    '<input type="text" class="form-input edu-course" maxlength="150" placeholder="e.g. Bachelor of Science in Information Technology" value="' + escapeHtml(data.courseName || '') + '" />' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">University / Institution *</label>' +
                    '<input type="text" class="form-input edu-univ" maxlength="150" placeholder="e.g. University of Science and Technology of Southern Philippines" value="' + escapeHtml(data.university || '') + '" />' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Start Year *</label>' +
                        '<input type="text" class="form-input edu-start" maxlength="10" placeholder="e.g. 2021" value="' + escapeHtml(data.startYear || '') + '" />' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">End Year (or \'Present\')</label>' +
                        '<input type="text" class="form-input edu-end" maxlength="10" placeholder="e.g. 2025" value="' + escapeHtml(data.endYear || '') + '" />' +
                    '</div>' +
                '</div>';
            container.appendChild(card);
        }

        // 2. Skill
        function addSkill(data) {
            data = data || {};
            var container = document.getElementById('skillList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card skill-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"></polyline><polyline points="8 6 2 12 8 18"></polyline></svg>' +
                        '<span class="badge-title">Skill #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'skillList\', \'Skill\');" title="Remove this skill">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Skill Name *</label>' +
                    '<input type="text" class="form-input skill-name" maxlength="100" placeholder="e.g. C# & ASP.NET Web Forms / MVC" value="' + escapeHtml(data.skillName || '') + '" />' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Description / Proficiency Details</label>' +
                    '<input type="text" class="form-input skill-desc" placeholder="e.g. Backend architecture, ADO.NET, REST APIs, Session state" value="' + escapeHtml(data.skillDescription || '') + '" />' +
                '</div>';
            container.appendChild(card);
        }

        // 3. Affiliation
        function addAffiliation(data) {
            data = data || {};
            var container = document.getElementById('affiliationList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card affiliation-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>' +
                        '<span class="badge-title">Affiliation #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'affiliationList\', \'Affiliation\');" title="Remove this affiliation">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Organization Name *</label>' +
                        '<input type="text" class="form-input affil-org" maxlength="150" placeholder="e.g. Junior Philippine Computer Society" value="' + escapeHtml(data.organizationName || '') + '" />' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">Position / Role *</label>' +
                        '<input type="text" class="form-input affil-role" maxlength="100" placeholder="e.g. Vice President for Technical Affairs" value="' + escapeHtml(data.position || '') + '" />' +
                    '</div>' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Start Year</label>' +
                        '<input type="text" class="form-input affil-start" maxlength="10" placeholder="e.g. 2022" value="' + escapeHtml(data.startYear || '') + '" />' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">End Year (or \'Present\')</label>' +
                        '<input type="text" class="form-input affil-end" maxlength="10" placeholder="e.g. 2024" value="' + escapeHtml(data.endYear || '') + '" />' +
                    '</div>' +
                '</div>';
            container.appendChild(card);
        }

        // 4. Hobby
        function addHobby(data) {
            data = data || {};
            var container = document.getElementById('hobbyList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var card = document.createElement('div');
            card.className = 'item-card hobby-item-card';
            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>' +
                        '<span class="badge-title">Hobby #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'hobbyList\', \'Hobby\');" title="Remove this hobby">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Hobby / Interest Name *</label>' +
                    '<input type="text" class="form-input hobby-name" maxlength="100" placeholder="e.g. Competitive Programming" value="' + escapeHtml(data.hobbyName || '') + '" />' +
                '</div>' +
                '<div class="form-group">' +
                    '<label class="form-label">Description</label>' +
                    '<input type="text" class="form-input hobby-desc" placeholder="e.g. Solving algorithmic challenges on LeetCode & Codeforces" value="' + escapeHtml(data.hobbyDescription || '') + '" />' +
                '</div>';
            container.appendChild(card);
        }

        // 5. Social Link
        function addSocialLink(data) {
            data = data || {};
            var container = document.getElementById('socialLinkList');
            if (!container) return;
            var index = container.querySelectorAll('.item-card').length + 1;
            var currentPlatform = (data.socialLinkName || 'GitHub').trim();
            var card = document.createElement('div');
            card.className = 'item-card social-item-card';

            var platforms = ['GitHub', 'LinkedIn', 'Personal Website', 'Twitter / X', 'Instagram', 'Facebook', 'YouTube', 'Discord', 'TikTok', 'Other'];
            var optionsHtml = '';
            var matched = false;
            for (var i = 0; i < platforms.length; i++) {
                var p = platforms[i];
                var isSelected = (p.toLowerCase() === currentPlatform.toLowerCase());
                if (isSelected) matched = true;
                optionsHtml += '<option value="' + escapeHtml(p) + '"' + (isSelected ? ' selected' : '') + '>' + escapeHtml(p) + '</option>';
            }
            if (!matched && currentPlatform) {
                optionsHtml += '<option value="' + escapeHtml(currentPlatform) + '" selected>' + escapeHtml(currentPlatform) + '</option>';
            }

            card.innerHTML = 
                '<div class="item-card-header">' +
                    '<span class="item-card-badge">' +
                        '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path></svg>' +
                        '<span class="badge-title">Link #' + index + '</span>' +
                    '</span>' +
                    '<button type="button" class="btn-delete-card" onclick="removeDynamicCard(this, \'socialLinkList\', \'Link\');" title="Remove this social link">' +
                        'Delete' +
                    '</button>' +
                '</div>' +
                '<div class="form-row-dual">' +
                    '<div class="form-group">' +
                        '<label class="form-label">Platform / Network</label>' +
                        '<select class="form-input social-platform">' +
                            optionsHtml +
                        '</select>' +
                    '</div>' +
                    '<div class="form-group">' +
                        '<label class="form-label">Profile / Portfolio URL *</label>' +
                        '<input type="text" class="form-input social-url" maxlength="500" placeholder="https://..." value="' + escapeHtml(data.link || '') + '" />' +
                    '</div>' +
                '</div>';
            container.appendChild(card);
        }

        // =========================================================================
        // Serialization to Hidden Fields
        // =========================================================================
        function serializeDynamicData() {
            // 1. Educations
            var eduCards = document.querySelectorAll('#educationList .item-card');
            var eduData = [];
            eduCards.forEach(function (c) {
                var courseEl = c.querySelector('.edu-course');
                var univEl = c.querySelector('.edu-univ');
                var startEl = c.querySelector('.edu-start');
                var endEl = c.querySelector('.edu-end');
                var course = courseEl ? courseEl.value.trim() : '';
                var univ = univEl ? univEl.value.trim() : '';
                var start = startEl ? startEl.value.trim() : '';
                var end = endEl ? endEl.value.trim() : '';
                if (course || univ) {
                    eduData.push({ CourseName: course, University: univ, StartYear: start, EndYear: end });
                }
            });
            var hfEdu = document.getElementById('<%= hfEducationsJson.ClientID %>');
            if (hfEdu) hfEdu.value = JSON.stringify(eduData);

            // 2. Skills
            var skillCards = document.querySelectorAll('#skillList .item-card');
            var skillData = [];
            skillCards.forEach(function (c) {
                var nameEl = c.querySelector('.skill-name');
                var descEl = c.querySelector('.skill-desc');
                var name = nameEl ? nameEl.value.trim() : '';
                var desc = descEl ? descEl.value.trim() : '';
                if (name) {
                    skillData.push({ SkillName: name, SkillDescription: desc });
                }
            });
            var hfSkill = document.getElementById('<%= hfSkillsJson.ClientID %>');
            if (hfSkill) hfSkill.value = JSON.stringify(skillData);

            // 3. Affiliations
            var affilCards = document.querySelectorAll('#affiliationList .item-card');
            var affilData = [];
            affilCards.forEach(function (c) {
                var orgEl = c.querySelector('.affil-org');
                var roleEl = c.querySelector('.affil-role');
                var startEl = c.querySelector('.affil-start');
                var endEl = c.querySelector('.affil-end');
                var org = orgEl ? orgEl.value.trim() : '';
                var role = roleEl ? roleEl.value.trim() : '';
                var start = startEl ? startEl.value.trim() : '';
                var end = endEl ? endEl.value.trim() : '';
                if (org || role) {
                    affilData.push({ OrganizationName: org, Position: role, StartYear: start, EndYear: end });
                }
            });
            var hfAffil = document.getElementById('<%= hfAffiliationsJson.ClientID %>');
            if (hfAffil) hfAffil.value = JSON.stringify(affilData);

            // 4. Hobbies
            var hobbyCards = document.querySelectorAll('#hobbyList .item-card');
            var hobbyData = [];
            hobbyCards.forEach(function (c) {
                var nameEl = c.querySelector('.hobby-name');
                var descEl = c.querySelector('.hobby-desc');
                var name = nameEl ? nameEl.value.trim() : '';
                var desc = descEl ? descEl.value.trim() : '';
                if (name) {
                    hobbyData.push({ HobbyName: name, HobbyDescription: desc });
                }
            });
            var hfHobby = document.getElementById('<%= hfHobbiesJson.ClientID %>');
            if (hfHobby) hfHobby.value = JSON.stringify(hobbyData);

            // 5. Social Links
            var socialCards = document.querySelectorAll('#socialLinkList .item-card');
            var socialData = [];
            socialCards.forEach(function (c) {
                var platEl = c.querySelector('.social-platform');
                var urlEl = c.querySelector('.social-url');
                var plat = platEl ? platEl.value.trim() : 'Other';
                var url = urlEl ? urlEl.value.trim() : '';
                if (url) {
                    socialData.push({ SocialLinkName: plat, Link: url });
                }
            });
            var hfSocial = document.getElementById('<%= hfSocialLinksJson.ClientID %>');
            if (hfSocial) hfSocial.value = JSON.stringify(socialData);
        }

        // =========================================================================
        // Initialization
        // =========================================================================
        function initDynamicSections() {
            function parseJsonSafely(id) {
                var el = document.getElementById(id);
                if (!el || !el.value) return [];
                try {
                    return JSON.parse(el.value) || [];
                } catch (e) {
                    return [];
                }
            }

            // Educations
            var educations = parseJsonSafely('<%= hfEducationsJson.ClientID %>');
            if (educations.length > 0) {
                educations.forEach(function (item) { addEducation(item); });
            } else {
                addEducation();
            }

            // Skills
            var skills = parseJsonSafely('<%= hfSkillsJson.ClientID %>');
            if (skills.length > 0) {
                skills.forEach(function (item) { addSkill(item); });
            } else {
                addSkill();
            }

            // Affiliations
            var affiliations = parseJsonSafely('<%= hfAffiliationsJson.ClientID %>');
            if (affiliations.length > 0) {
                affiliations.forEach(function (item) { addAffiliation(item); });
            } else {
                addAffiliation();
            }

            // Hobbies
            var hobbies = parseJsonSafely('<%= hfHobbiesJson.ClientID %>');
            if (hobbies.length > 0) {
                hobbies.forEach(function (item) { addHobby(item); });
            } else {
                addHobby();
            }

            // Social Links
            var socialLinks = parseJsonSafely('<%= hfSocialLinksJson.ClientID %>');
            if (socialLinks.length > 0) {
                socialLinks.forEach(function (item) { addSocialLink(item); });
            } else {
                addSocialLink();
            }
        }

        function dismissToast(btn) {
            var toast = btn.closest('.toast-box');
            if (toast) {
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(16px)';
                setTimeout(function () {
                    if (toast.parentNode) {
                        toast.parentNode.removeChild(toast);
                    } else {
                        toast.style.display = 'none';
                    }
                }, 250);
            }
        }

        // Initialize state on load
        window.addEventListener('DOMContentLoaded', function () {
            var hfStep = document.getElementById('<%= hfCurrentStep.ClientID %>');
            var initStep = hfStep && hfStep.value ? parseInt(hfStep.value) : 1;
            if (isNaN(initStep) || initStep < 1 || initStep > totalSteps) initStep = 1;
            setStep(initStep);

            // Populate dynamic lists
            initDynamicSections();

            // Hook form submit
            var form = document.getElementById('<%= onboardingForm.ClientID %>');
            if (form) {
                form.addEventListener('submit', serializeDynamicData);
            }

            // Auto-dismiss any active toasts after 5 seconds
            var activeToasts = document.querySelectorAll('.toast-box');
            activeToasts.forEach(function (t) {
                setTimeout(function () {
                    var btn = t.querySelector('.toast-close-btn');
                    if (btn) dismissToast(btn);
                }, 5000);
            });
        });
    </script>
</body>
</html>
