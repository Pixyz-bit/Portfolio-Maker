# 19 - Onboarding.aspx Frontend & Code-Behind Guide

## 1. Overview
**`Onboarding.aspx`** is the multi-step profile onboarding wizard for the personal portfolio platform (`Frontend/User/Onboarding.aspx`).
It collects and synchronizes all primary personal, academic, technical, organizational, and social details needed to build the user's personal portfolio website.

### Visual Design & Aesthetic System
Following the project's signature monochromatic dotted-grid design:
- **Canvas Background**: High-contrast pure white (`#ffffff`) with subtle radial dot grid (`radial-gradient(#cbd5e1 1.2px, transparent 1.2px) 16px 16px`).
- **Cards & Outlines**: Clean 2.5px solid black border (`border: 2.5px solid #000000; border-radius: 20px;`) with matching internal dot matrix.
- **Progress Tracker**: 5-step numbered progress bar (1 to 5) with connected progress line and active/completed states.
- **Controls & Inputs**: 2px solid black borders (`border: 2px solid #000000; border-radius: 10px;`), high-contrast typography, and smooth transitions.
- **Profile Photo Upload**: Dedicated preview box and file uploader saving to `~/Uploads/Profiles/`.

---

## 2. Models & Repositories Integrated

| Step | Section Name | Dedicated Model | Dedicated Repository | Database Table |
|---|---|---|---|---|
| **Step 1** | Personal Profile | `UserProfile` | `UserProfileRepository` | `dbo.UserProfiles` |
| **Step 2** | Education History | `Education` | `EducationRepository` | `dbo.Educations` |
| **Step 3** | Skills & Competencies | `Skill` | `SkillRepository` | `dbo.Skills` |
| **Step 4** | Affiliations & Hobbies | `Affiliation` & `Hobby` | `AffiliationRepository` & `HobbyRepository` | `dbo.Affiliations` & `dbo.Hobbies` |
| **Step 5** | Social Links (*Last Step*) | `SocialLink` | `SocialLinkRepository` | `dbo.SocialLinks` |

---

## 3. Page & Directory Structure
- **Web Form**: `241611JalopPersonalWebsite/Frontend/User/Onboarding.aspx`
- **Code-Behind**: `241611JalopPersonalWebsite/Frontend/User/Onboarding.aspx.cs`
- **Designer File**: `241611JalopPersonalWebsite/Frontend/User/Onboarding.aspx.designer.cs`
- **Upload Directory**: `241611JalopPersonalWebsite/Uploads/Profiles/`
- **Dashboard Web Form**: `241611JalopPersonalWebsite/Frontend/User/Dashboard.aspx`

---

## 4. Multi-Step Form Fields (Strict Schema Alignment)

### Step 1: Personal Profile (`dbo.UserProfiles`)
- **Profile Image (`ProfileImagePath`)**: File upload control supporting `.jpg`, `.jpeg`, `.png`, and `.webp` up to 2MB.
- **First Name (`FirstName`)**: Required text input (max 50 chars).
- **Last Name (`LastName`)**: Required text input (max 50 chars).
- **Birthday (`Birthday`)**: Date input format.
- **Location / Address (`Address`)**: Text input (max 255 chars).
- **Public Contact Email (`ContactEmail`)**: Email input (max 255 chars).
- **Contact Number (`ContactNum`)**: Phone text input (max 30 chars).
- **About Me / Bio (`Description`)**: Multi-line text area for portfolio introduction.

### Step 2: Education (`dbo.Educations`)
- **Primary Education**:
  - `CourseName`: Degree / Course (max 150 chars).
  - `University`: School / University (max 150 chars).
  - `StartYear` & `EndYear`: Year strings (e.g., "2021" to "2025" or "Present").
- **Secondary Education (Optional)**:
  - Supports entering high school, diploma, or secondary degree.

### Step 3: Skills (`dbo.Skills`)
- Up to 4 dedicated skill cards:
  - `SkillName`: Name of skill / tool (max 100 chars).
  - `SkillDescription`: Proficiency details or technology summary.

### Step 4: Affiliations & Hobbies (`dbo.Affiliations` & `dbo.Hobbies`)
- **Affiliations**:
  - `OrganizationName`: Organization / Association name (max 150 chars).
  - `Position`: Role / Position held (max 100 chars).
  - `StartYear` & `EndYear`: Active period.
- **Hobbies**:
  - `HobbyName`: Name of interest (max 100 chars).
  - `HobbyDescription`: Short description of passion/activity.

### Step 5: Social Links (`dbo.SocialLinks` — Final Step)
- **GitHub**: `https://github.com/username`
- **LinkedIn**: `https://linkedin.com/in/username`
- **Personal Website / Portfolio**: `https://yourdomain.com`
- **Twitter / X**: `https://x.com/username`
- **Other Social (Instagram / Facebook)**: `https://instagram.com/username`
- **Action**: "Complete & Launch Portfolio" button that persists all sections via repositories and redirects to the user dashboard.

---

## 5. Summary of Architecture & Data Persistence Flow
1. **User Authentication**: Inspects `Session["UserID"]`. If not logged in, redirects to `Login.aspx`.
2. **Pre-population**: On `!IsPostBack`, fetches existing rows from SQL Server via `GetByUserId` across all 6 repositories, populating the form for frictionless editing.
3. **Image Upload**: Saves incoming file to `~/Uploads/Profiles/` with a sanitized GUID filename and stores the virtual path in `UserProfile.ProfileImagePath`.
4. **Clean Updates**: Calls `UserProfileRepository.Update` (or `Create` if first time). Refreshes child tables (`Educations`, `Skills`, `Affiliations`, `Hobbies`, `SocialLinks`) cleanly using their respective repository `Delete` and `Create` methods.
5. **Success Handling**: Displays feedback and redirects the user to `Dashboard.aspx`.
