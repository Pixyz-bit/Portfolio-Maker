# 20 - Portfolio.aspx Frontend & Code-Behind Guide

## 1. Overview
**`Portfolio.aspx`** is the dynamic, fully responsive public & personal portfolio display page (`Frontend/User/Portfolio.aspx`).
It renders all information entered through the onboarding form across 6 dedicated models and repositories:
- **`UserProfile`** (`UserProfileRepository`): Hero section with full name, location, public contact details, profile portrait, and bio / narrative.
- **`Education`** (`EducationRepository`): Academic history cards with degrees, institutions, and study periods.
- **`Skill`** (`SkillRepository`): Interactive grid of technical proficiencies and competencies with descriptions.
- **`Affiliation`** (`AffiliationRepository`): Student & professional organization leadership roles, association names, and active terms.
- **`Hobby`** (`HobbyRepository`): Personal interests, creative pursuits, and descriptions.
- **`SocialLink`** (`SocialLinkRepository`): GitHub, LinkedIn, Personal Website, Twitter/X, and other external profiles with interactive link cards.

---

## 2. Visual Design & Responsive System
- **Background**: High-contrast white canvas with subtle dotted matrix (`radial-gradient(#cbd5e1 1.2px, transparent 1.2px) 16px 16px`).
- **Cards & Outlines**: Clean 2.5px solid black borders (`border: 2.5px solid #000000; border-radius: 20px;`) with matching internal dot pattern and subtle hover shadow.
- **Typography**: Google Fonts `Plus Jakarta Sans` (headlines, numbers, buttons) and `Inter` (body copy, descriptions, metadata).
- **Responsive Layout**:
  - **Desktop (1080px max-width)**: 2-column hero layout with 140px portrait, 2-to-3 column grids for education, skills, affiliations, and hobbies, side-by-side contact & social section.
  - **Tablet & Mobile (<= 768px)**: Seamless single-column flex-direction collapse, centered hero elements, hidden desktop jump links, full-width touch-friendly cards.

---

## 3. Dynamic Routing & Multi-User Resolution
`Portfolio.aspx.cs` automatically resolves the target portfolio:
1. **Direct Query String**: `Portfolio.aspx?userId=X` displays the public profile of user `X`.
2. **Current Session**: If no query string is passed, defaults to `Session["UserID"]`.
3. **Owner Detection**: If the currently authenticated user is the owner of the viewed profile, an **"Edit Portfolio"** button dynamically appears in the top navigation bar, linking back to `Onboarding.aspx`.
4. **Testing Fallback**: If unauthenticated and without a query string during development, it safely queries the latest active user in the database so testing in Visual Studio runs without errors.

---

## 4. Page & Directory Structure
- **Web Form**: `241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx`
- **Code-Behind**: `241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx.cs`
- **Designer File**: `241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx.designer.cs`
- **Dashboard Web Form**: `241611JalopPersonalWebsite/Frontend/User/Dashboard.aspx`
- **Onboarding Web Form**: `241611JalopPersonalWebsite/Frontend/User/Onboarding.aspx`
