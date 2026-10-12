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

    <link rel="stylesheet" href="../Assets/css/onboarding.css" />
</head>
<body>
    <div class="onboarding-container">
        <div class="card" id="mainCard" runat="server">
            <form id="onboardingForm" runat="server" enctype="multipart/form-data">
                <div class="top-action-bar">
                    <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                        <span class="badge-tag">Portfolio Content Editor</span>
                        <asp:Panel ID="pnlAdminBadge" runat="server" Visible="false" style="display: inline-flex; align-items: center; gap: 6px; background-color: #000000; color: #ffffff; padding: 4px 10px; border-radius: 6px; font-size: 0.72rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em;">
                            Admin Editing: <asp:Literal ID="litAdminTargetUserName" runat="server" />
                        </asp:Panel>
                    </div>
                    <asp:HyperLink ID="lnkReturnToAdmin" runat="server" Visible="false" NavigateUrl="~/Frontend/Admin/Dashboard.aspx" CssClass="btn btn-outline btn-sm" style="background: #ffffff; text-decoration: none; padding: 6px 14px; font-weight: 800; font-size: 0.8rem; border: 2px solid #000; border-radius: 8px;">
                        Return to Admin Console
                    </asp:HyperLink>
                </div>

                <div class="card-header">
                    <h1 class="card-title"><asp:Literal ID="litPageTitle" runat="server" Text="Profile Onboarding" /></h1>
                    <p class="card-subtitle"><asp:Literal ID="litPageSubtitle" runat="server" Text="Fill in your information at your own pace. Save & Exit anytime to view the live portfolio." /></p>
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
                <asp:HiddenField ID="hfTargetUserId" runat="server" Value="" />
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

                        <!-- Portfolio Visibility Choice -->
                        <div class="visibility-card-setting" style="display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; border: 2px solid #000; border-radius: 12px; background: #fafafa; margin-top: 6px;">
                            <div>
                                <div style="font-weight: 800; font-size: 0.92rem; color: #000; display: flex; align-items: center; gap: 8px;">
                                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="2" y1="12" x2="22" y2="12"></line><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1 4-10z"></path></svg>
                                    Portfolio Visibility
                                </div>
                                <p style="font-size: 0.8rem; color: #52525b; margin: 3px 0 0;">Control whether your portfolio is public or private. Public portfolios appear on the Explore directory.</p>
                            </div>
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <asp:CheckBox ID="chkIsPublic" runat="server" Checked="true" style="transform: scale(1.25); cursor: pointer; accent-color: #000;" />
                                <label for="<%= chkIsPublic.ClientID %>" style="font-size: 0.86rem; font-weight: 700; cursor: pointer; margin-bottom: 0;">Public</label>
                            </div>
                        </div>
                    </div>

                    <div class="wizard-footer">
                        <div class="footer-actions-left">
                            <asp:HyperLink ID="lnkBackStep1" runat="server" CssClass="btn btn-outline" NavigateUrl="Portfolio.aspx" ToolTip="Return without saving changes">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="display:inline-block; vertical-align:-2px; margin-right:4px;"><polyline points="15 18 9 12 15 6"></polyline></svg>
                                Back without saving
                            </asp:HyperLink>
                        </div>
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
    <script src="../Assets/js/onboarding.js"></script>
</body>
</html>
