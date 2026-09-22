<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Onboarding.aspx.cs" Inherits="_241611JalopPersonalWebsite.Frontend.User.Onboarding" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Portfolio Onboarding & Setup | Personal Portfolio</title>
    <meta name="description" content="Set up your personal portfolio details, education, skills, affiliations, hobbies, and social links." />

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
            padding: 44px 40px 40px;
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.05);
        }

        .card-header {
            text-align: center;
            margin-bottom: 28px;
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
            margin-bottom: 12px;
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
            justify-content: space-between;
            align-items: center;
            position: relative;
            margin-bottom: 36px;
            padding: 0 10px;
        }

        .step-indicator::before {
            content: '';
            position: absolute;
            top: 18px;
            left: 20px;
            right: 20px;
            height: 2px;
            background-color: #e2e8f0;
            z-index: 1;
        }

        .step-progress-fill {
            position: absolute;
            top: 18px;
            left: 20px;
            height: 2px;
            background-color: #000000;
            z-index: 2;
            transition: width 0.3s ease;
            width: 0%;
        }

        .step-item {
            position: relative;
            z-index: 3;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            background: transparent;
            border: none;
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

        /* Status Alerts */
        .alert-box {
            padding: 12px 16px;
            border-radius: var(--radius-input);
            font-size: 0.88rem;
            font-weight: 600;
            margin-bottom: 24px;
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

        /* Section Item Box (for items like secondary education, multiple skills) */
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

        /* Wizard Footer Controls */
        .wizard-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 36px;
            padding-top: 24px;
            border-top: 2px solid var(--border-black);
        }

        .btn {
            height: 48px;
            padding: 0 28px;
            font-family: inherit;
            font-size: 1rem;
            font-weight: 800;
            letter-spacing: -0.01em;
            border-radius: var(--radius-btn);
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
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
                padding: 28px 18px 24px;
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
                gap: 12px;
            }
            .wizard-footer .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="onboarding-container">
        <div class="card">
            <!-- Header -->
            <div class="card-header">
                <span class="badge-tag">Portfolio Creator</span>
                <h1 class="card-title">Profile Onboarding</h1>
                <p class="card-subtitle">Complete your personal details to automatically power your portfolio website.</p>
            </div>

            <form id="onboardingForm" runat="server" enctype="multipart/form-data">
                <!-- Status Alerts -->
                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert-box alert-danger">
                    <asp:Label ID="lblErrorMessage" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert-box alert-success">
                    <asp:Label ID="lblSuccessMessage" runat="server" />
                </asp:Panel>

                <!-- 5-Step Progress Bar -->
                <div class="step-indicator">
                    <div class="step-progress-fill" id="stepProgressFill"></div>
                    
                    <button type="button" class="step-item active" id="indicator1" onclick="jumpToStep(1);">
                        <div class="step-bubble">1</div>
                        <span class="step-label">Profile</span>
                    </button>

                    <button type="button" class="step-item" id="indicator2" onclick="jumpToStep(2);">
                        <div class="step-bubble">2</div>
                        <span class="step-label">Education</span>
                    </button>

                    <button type="button" class="step-item" id="indicator3" onclick="jumpToStep(3);">
                        <div class="step-bubble">3</div>
                        <span class="step-label">Skills</span>
                    </button>

                    <button type="button" class="step-item" id="indicator4" onclick="jumpToStep(4);">
                        <div class="step-bubble">4</div>
                        <span class="step-label">Affiliations & Hobbies</span>
                    </button>

                    <button type="button" class="step-item" id="indicator5" onclick="jumpToStep(5);">
                        <div class="step-bubble">5</div>
                        <span class="step-label">Social Links</span>
                    </button>
                </div>

                <!-- Hidden field to preserve current step across postbacks -->
                <asp:HiddenField ID="hfCurrentStep" runat="server" Value="1" />
                <asp:HiddenField ID="hfExistingImagePath" runat="server" Value="" />

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
                                <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-input" MaxLength="50" required="required" placeholder="e.g. John" />
                            </div>
                            <div class="form-group">
                                <label for="txtLastName" class="form-label">Last Name *</label>
                                <asp:TextBox ID="txtLastName" runat="server" CssClass="form-input" MaxLength="50" required="required" placeholder="e.g. Doe" />
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
                                <asp:TextBox ID="txtContactEmail" runat="server" TextMode="Email" CssClass="form-input" MaxLength="255" placeholder="e.g. contact@johndoe.com" />
                            </div>
                            <div class="form-group">
                                <label for="txtContactNum" class="form-label">Contact / Mobile Number</label>
                                <asp:TextBox ID="txtContactNum" runat="server" CssClass="form-input" MaxLength="30" placeholder="e.g. +63 912 345 6789" />
                            </div>
                        </div>

                        <!-- Description / Bio -->
                        <div class="form-group">
                            <label for="txtDescription" class="form-label">About Me / Bio</label>
                            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-textarea" placeholder="Write a summary about yourself, your background, and your career aspirations..." />
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <div></div>
                        <button type="button" class="btn btn-solid" onclick="nextStep(1);">Continue to Education &rarr;</button>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 2: Education (Education)                           -->
                <!-- ======================================================= -->
                <div class="step-section" id="step2">
                    <div class="section-header">
                        <h2 class="section-title">Step 2: Education History</h2>
                        <p class="section-desc">Add your academic background, universities, and degrees.</p>
                    </div>

                    <div class="form-grid">
                        <!-- Primary Education Card -->
                        <div class="item-card">
                            <div class="item-card-title">Primary Degree / Education *</div>
                            <div class="form-group">
                                <label for="txtCourse1" class="form-label">Degree / Course Name *</label>
                                <asp:TextBox ID="txtCourse1" runat="server" CssClass="form-input" MaxLength="150" placeholder="e.g. Bachelor of Science in Information Technology" />
                            </div>
                            <div class="form-group">
                                <label for="txtUniversity1" class="form-label">University / Institution *</label>
                                <asp:TextBox ID="txtUniversity1" runat="server" CssClass="form-input" MaxLength="150" placeholder="e.g. University of Science and Technology of Southern Philippines" />
                            </div>
                            <div class="form-row-dual">
                                <div class="form-group">
                                    <label for="txtEduStartYear1" class="form-label">Start Year *</label>
                                    <asp:TextBox ID="txtEduStartYear1" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. 2021" />
                                </div>
                                <div class="form-group">
                                    <label for="txtEduEndYear1" class="form-label">End Year (or 'Present')</label>
                                    <asp:TextBox ID="txtEduEndYear1" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. 2025" />
                                </div>
                            </div>
                        </div>

                        <!-- Secondary Education Card (Optional) -->
                        <div class="item-card">
                            <div class="item-card-title">Secondary Education <span class="label-hint">(Optional)</span></div>
                            <div class="form-group">
                                <label for="txtCourse2" class="form-label">Degree / Course / Strand</label>
                                <asp:TextBox ID="txtCourse2" runat="server" CssClass="form-input" MaxLength="150" placeholder="e.g. Senior High School - STEM Track" />
                            </div>
                            <div class="form-group">
                                <label for="txtUniversity2" class="form-label">School / Institution</label>
                                <asp:TextBox ID="txtUniversity2" runat="server" CssClass="form-input" MaxLength="150" placeholder="e.g. Cagayan de Oro National High School" />
                            </div>
                            <div class="form-row-dual">
                                <div class="form-group">
                                    <label for="txtEduStartYear2" class="form-label">Start Year</label>
                                    <asp:TextBox ID="txtEduStartYear2" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. 2019" />
                                </div>
                                <div class="form-group">
                                    <label for="txtEduEndYear2" class="form-label">End Year</label>
                                    <asp:TextBox ID="txtEduEndYear2" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. 2021" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <button type="button" class="btn btn-outline" onclick="prevStep(2);">&larr; Back</button>
                        <button type="button" class="btn btn-solid" onclick="nextStep(2);">Continue to Skills &rarr;</button>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 3: Skills (Skill)                                  -->
                <!-- ======================================================= -->
                <div class="step-section" id="step3">
                    <div class="section-header">
                        <h2 class="section-title">Step 3: Skills & Competencies</h2>
                        <p class="section-desc">Highlight your technical proficiencies, frameworks, and tools.</p>
                    </div>

                    <div class="form-grid">
                        <!-- Skill 1 -->
                        <div class="item-card">
                            <div class="item-card-title">Primary Skill 1 *</div>
                            <div class="form-group">
                                <label for="txtSkill1" class="form-label">Skill Name *</label>
                                <asp:TextBox ID="txtSkill1" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. C# & ASP.NET Web Forms / MVC" />
                            </div>
                            <div class="form-group">
                                <label for="txtSkillDesc1" class="form-label">Description / Proficiency Details</label>
                                <asp:TextBox ID="txtSkillDesc1" runat="server" CssClass="form-input" placeholder="e.g. Backend architecture, ADO.NET, REST APIs, Session state" />
                            </div>
                        </div>

                        <!-- Skill 2 -->
                        <div class="item-card">
                            <div class="item-card-title">Skill 2</div>
                            <div class="form-group">
                                <label for="txtSkill2" class="form-label">Skill Name</label>
                                <asp:TextBox ID="txtSkill2" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. Microsoft SQL Server & Database Design" />
                            </div>
                            <div class="form-group">
                                <label for="txtSkillDesc2" class="form-label">Description / Proficiency Details</label>
                                <asp:TextBox ID="txtSkillDesc2" runat="server" CssClass="form-input" placeholder="e.g. Relational modeling, stored procedures, indexing, migrations" />
                            </div>
                        </div>

                        <!-- Skill 3 -->
                        <div class="item-card">
                            <div class="item-card-title">Skill 3</div>
                            <div class="form-group">
                                <label for="txtSkill3" class="form-label">Skill Name</label>
                                <asp:TextBox ID="txtSkill3" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. Frontend Technologies (HTML5, CSS3, JavaScript)" />
                            </div>
                            <div class="form-group">
                                <label for="txtSkillDesc3" class="form-label">Description / Proficiency Details</label>
                                <asp:TextBox ID="txtSkillDesc3" runat="server" CssClass="form-input" placeholder="e.g. Responsive wireframing, monochromatic UI design, DOM manipulation" />
                            </div>
                        </div>

                        <!-- Skill 4 -->
                        <div class="item-card">
                            <div class="item-card-title">Skill 4</div>
                            <div class="form-group">
                                <label for="txtSkill4" class="form-label">Skill Name</label>
                                <asp:TextBox ID="txtSkill4" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. Git & Version Control" />
                            </div>
                            <div class="form-group">
                                <label for="txtSkillDesc4" class="form-label">Description / Proficiency Details</label>
                                <asp:TextBox ID="txtSkillDesc4" runat="server" CssClass="form-input" placeholder="e.g. Branching workflows, GitHub repository maintenance, code reviews" />
                            </div>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <button type="button" class="btn btn-outline" onclick="prevStep(3);">&larr; Back</button>
                        <button type="button" class="btn btn-solid" onclick="nextStep(3);">Continue to Affiliations & Hobbies &rarr;</button>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 4: Affiliations & Hobbies (Affiliation & Hobby)    -->
                <!-- ======================================================= -->
                <div class="step-section" id="step4">
                    <div class="section-header">
                        <h2 class="section-title">Step 4: Affiliations & Hobbies</h2>
                        <p class="section-desc">Showcase your organization memberships and personal passions.</p>
                    </div>

                    <div class="form-grid">
                        <!-- Affiliation 1 -->
                        <div class="item-card">
                            <div class="item-card-title">Organization Affiliation 1</div>
                            <div class="form-row-dual">
                                <div class="form-group">
                                    <label for="txtOrg1" class="form-label">Organization Name</label>
                                    <asp:TextBox ID="txtOrg1" runat="server" CssClass="form-input" MaxLength="150" placeholder="e.g. Junior Philippine Computer Society" />
                                </div>
                                <div class="form-group">
                                    <label for="txtRole1" class="form-label">Position / Role</label>
                                    <asp:TextBox ID="txtRole1" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. Vice President for Technical Affairs" />
                                </div>
                            </div>
                            <div class="form-row-dual">
                                <div class="form-group">
                                    <label for="txtOrgStart1" class="form-label">Start Year</label>
                                    <asp:TextBox ID="txtOrgStart1" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. 2022" />
                                </div>
                                <div class="form-group">
                                    <label for="txtOrgEnd1" class="form-label">End Year</label>
                                    <asp:TextBox ID="txtOrgEnd1" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. 2024" />
                                </div>
                            </div>
                        </div>

                        <!-- Affiliation 2 (Optional) -->
                        <div class="item-card">
                            <div class="item-card-title">Organization Affiliation 2 <span class="label-hint">(Optional)</span></div>
                            <div class="form-row-dual">
                                <div class="form-group">
                                    <label for="txtOrg2" class="form-label">Organization Name</label>
                                    <asp:TextBox ID="txtOrg2" runat="server" CssClass="form-input" MaxLength="150" placeholder="e.g. Student Council / Tech Guild" />
                                </div>
                                <div class="form-group">
                                    <label for="txtRole2" class="form-label">Position / Role</label>
                                    <asp:TextBox ID="txtRole2" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. Committee Member" />
                                </div>
                            </div>
                            <div class="form-row-dual">
                                <div class="form-group">
                                    <label for="txtOrgStart2" class="form-label">Start Year</label>
                                    <asp:TextBox ID="txtOrgStart2" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. 2023" />
                                </div>
                                <div class="form-group">
                                    <label for="txtOrgEnd2" class="form-label">End Year</label>
                                    <asp:TextBox ID="txtOrgEnd2" runat="server" CssClass="form-input" MaxLength="10" placeholder="e.g. Present" />
                                </div>
                            </div>
                        </div>

                        <!-- Hobby 1 -->
                        <div class="item-card">
                            <div class="item-card-title">Personal Hobby / Interest 1</div>
                            <div class="form-group">
                                <label for="txtHobby1" class="form-label">Hobby Name</label>
                                <asp:TextBox ID="txtHobby1" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. Competitive Programming" />
                            </div>
                            <div class="form-group">
                                <label for="txtHobbyDesc1" class="form-label">Description</label>
                                <asp:TextBox ID="txtHobbyDesc1" runat="server" CssClass="form-input" placeholder="e.g. Solving algorithmic challenges on LeetCode & Codeforces" />
                            </div>
                        </div>

                        <!-- Hobby 2 -->
                        <div class="item-card">
                            <div class="item-card-title">Personal Hobby / Interest 2</div>
                            <div class="form-group">
                                <label for="txtHobby2" class="form-label">Hobby Name</label>
                                <asp:TextBox ID="txtHobby2" runat="server" CssClass="form-input" MaxLength="100" placeholder="e.g. Photography & Digital Art" />
                            </div>
                            <div class="form-group">
                                <label for="txtHobbyDesc2" class="form-label">Description</label>
                                <asp:TextBox ID="txtHobbyDesc2" runat="server" CssClass="form-input" placeholder="e.g. Capturing architecture and minimalist urban landscapes" />
                            </div>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <button type="button" class="btn btn-outline" onclick="prevStep(4);">&larr; Back</button>
                        <button type="button" class="btn btn-solid" onclick="nextStep(4);">Continue to Social Links &rarr;</button>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- STEP 5: Social Links (SocialLink — Final Step)          -->
                <!-- ======================================================= -->
                <div class="step-section" id="step5">
                    <div class="section-header">
                        <h2 class="section-title">Step 5: Social & Web Presence</h2>
                        <p class="section-desc">Connect your online profiles and portfolio URLs for visitors to reach you.</p>
                    </div>

                    <div class="form-grid">
                        <!-- GitHub -->
                        <div class="form-group">
                            <label for="txtGithubLink" class="form-label">GitHub URL</label>
                            <asp:TextBox ID="txtGithubLink" runat="server" CssClass="form-input" MaxLength="500" placeholder="https://github.com/yourusername" />
                        </div>

                        <!-- LinkedIn -->
                        <div class="form-group">
                            <label for="txtLinkedinLink" class="form-label">LinkedIn URL</label>
                            <asp:TextBox ID="txtLinkedinLink" runat="server" CssClass="form-input" MaxLength="500" placeholder="https://linkedin.com/in/yourusername" />
                        </div>

                        <!-- Personal Website / Portfolio -->
                        <div class="form-group">
                            <label for="txtWebsiteLink" class="form-label">Personal Website / Portfolio URL</label>
                            <asp:TextBox ID="txtWebsiteLink" runat="server" CssClass="form-input" MaxLength="500" placeholder="https://yourportfolio.dev" />
                        </div>

                        <!-- Twitter / X -->
                        <div class="form-group">
                            <label for="txtTwitterLink" class="form-label">Twitter / X URL</label>
                            <asp:TextBox ID="txtTwitterLink" runat="server" CssClass="form-input" MaxLength="500" placeholder="https://x.com/yourusername" />
                        </div>

                        <!-- Other Social / Instagram / Facebook -->
                        <div class="form-group">
                            <label for="txtOtherSocialLink" class="form-label">Other Social Link (Instagram / Facebook)</label>
                            <asp:TextBox ID="txtOtherSocialLink" runat="server" CssClass="form-input" MaxLength="500" placeholder="https://instagram.com/yourusername" />
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <button type="button" class="btn btn-outline" onclick="prevStep(5);">&larr; Back</button>
                        <asp:Button ID="btnCompleteOnboarding" runat="server" Text="Complete & Launch Portfolio" CssClass="btn btn-solid" OnClick="btnCompleteOnboarding_Click" />
                    </div>
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

            // Update progress line fill percentage
            var progressPercent = ((step - 1) / (totalSteps - 1)) * 100;
            var fill = document.getElementById('stepProgressFill');
            if (fill) fill.style.width = progressPercent + '%';

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
            // Allow jumping back to earlier steps or current step anytime
            if (step <= currentStep || validateStep(currentStep)) {
                setStep(step);
            }
        }

        function validateStep(step) {
            if (step === 1) {
                var fn = document.getElementById('<%= txtFirstName.ClientID %>').value.trim();
                var ln = document.getElementById('<%= txtLastName.ClientID %>').value.trim();
                if (!fn || !ln) {
                    alert('Please provide your First Name and Last Name to proceed.');
                    return false;
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

        // Initialize state on load
        window.addEventListener('DOMContentLoaded', function () {
            var hfStep = document.getElementById('<%= hfCurrentStep.ClientID %>');
            var initStep = hfStep && hfStep.value ? parseInt(hfStep.value) : 1;
            if (isNaN(initStep) || initStep < 1 || initStep > totalSteps) initStep = 1;
            setStep(initStep);
        });
    </script>
</body>
</html>
