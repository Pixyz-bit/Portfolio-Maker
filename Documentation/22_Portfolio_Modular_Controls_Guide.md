# 22. Modular Portfolio Web User Controls Guide

## Overview
To improve maintainability, reduce monolithic template clutter, and enable isolated feature development, the portfolio page ([Portfolio.aspx](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx)) was refactored into **7 modular ASP.NET Web User Controls (`.ascx`)**. 

As requested, all styling remains **internal** within the `<style>` block of [Portfolio.aspx](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx) so that no separate stylesheet files are needed.

---

## Modular Component Directory Structure
All user controls reside under `Frontend/User/Controls/`:

```
Frontend/
└── User/
    ├── Portfolio.aspx
    ├── Portfolio.aspx.cs
    ├── Portfolio.aspx.designer.cs
    └── Controls/
        ├── HeroSection.ascx
        ├── HeroSection.ascx.cs
        ├── HeroSection.ascx.designer.cs
        ├── SummarySection.ascx
        ├── SummarySection.ascx.cs
        ├── SummarySection.ascx.designer.cs
        ├── EducationSection.ascx
        ├── EducationSection.ascx.cs
        ├── EducationSection.ascx.designer.cs
        ├── SkillsSection.ascx
        ├── SkillsSection.ascx.cs
        ├── SkillsSection.ascx.designer.cs
        ├── AffiliationsSection.ascx
        ├── AffiliationsSection.ascx.cs
        ├── AffiliationsSection.ascx.designer.cs
        ├── HobbiesSection.ascx
        ├── HobbiesSection.ascx.cs
        ├── HobbiesSection.ascx.designer.cs
        ├── SocialLinksSection.ascx
        ├── SocialLinksSection.ascx.cs
        └── SocialLinksSection.ascx.designer.cs
```

---

## User Control Breakdown

### 1. HeroSection (`HeroSection.ascx`)
- **Responsibility**: Displays the user's 1:1 square profile picture (`170px x 170px`), full name, and 2-column contact metadata (Birthday, Address, Contact Number, Email).
- **Public Method**: `BindProfile(UserProfile profile)`

### 2. SummarySection (`SummarySection.ascx`)
- **Responsibility**: Displays the user's introductory statement / summary in a dedicated card directly beneath the hero section. Automatically toggles visibility if empty.
- **Public Method**: `BindSummary(string description)`

### 3. EducationSection (`EducationSection.ascx`)
- **Responsibility**: Formats educational attainment records as a vertical timeline with hollow bullet nodes.
- **Public Method**: `BindEducation(List<Education> educations)`
- **Helper**: `FormatPeriod(object startYear, object endYear)`

### 4. SkillsSection (`SkillsSection.ascx`)
- **Responsibility**: Renders skills as categorized tags.
- **Public Method**: `BindSkills(List<Skill> skills)`

### 5. AffiliationsSection (`AffiliationsSection.ascx`)
- **Responsibility**: Formats organization roles and memberships in a vertical timeline matching the education style.
- **Public Method**: `BindAffiliations(List<Affiliation> affiliations)`
- **Helper**: `FormatPeriod(object startYear, object endYear)`

### 6. HobbiesSection (`HobbiesSection.ascx`)
- **Responsibility**: Renders hobbies and interests with clean badge tags and descriptions.
- **Public Method**: `BindHobbies(List<Hobby> hobbies)`

### 7. SocialLinksSection (`SocialLinksSection.ascx`)
- **Responsibility**: Renders bottom-most stadium pill container with SVG icons for GitHub, LinkedIn, Instagram, Facebook, X/Twitter, YouTube, and website links.
- **Public Method**: `BindSocialLinks(List<SocialLink> socialLinks)`
- **Helper**: `GetSocialIcon(string linkName)`

---

## Parent Page Integration (`Portfolio.aspx`)

### Register Directives
```aspx
<%@ Register Src="~/Frontend/User/Controls/HeroSection.ascx" TagPrefix="uc" TagName="HeroSection" %>
<%@ Register Src="~/Frontend/User/Controls/SummarySection.ascx" TagPrefix="uc" TagName="SummarySection" %>
<%@ Register Src="~/Frontend/User/Controls/EducationSection.ascx" TagPrefix="uc" TagName="EducationSection" %>
<%@ Register Src="~/Frontend/User/Controls/SkillsSection.ascx" TagPrefix="uc" TagName="SkillsSection" %>
<%@ Register Src="~/Frontend/User/Controls/AffiliationsSection.ascx" TagPrefix="uc" TagName="AffiliationsSection" %>
<%@ Register Src="~/Frontend/User/Controls/HobbiesSection.ascx" TagPrefix="uc" TagName="HobbiesSection" %>
<%@ Register Src="~/Frontend/User/Controls/SocialLinksSection.ascx" TagPrefix="uc" TagName="SocialLinksSection" %>
```

### Markup Declarations
```aspx
<main class="portfolio-wrap">
    <!-- 1. Hero Card -->
    <uc:HeroSection ID="ucHero" runat="server" />

    <!-- 2. Summary Card -->
    <uc:SummarySection ID="ucSummary" runat="server" />

    <!-- 3. 2x2 Bento Grid -->
    <div class="bento-grid">
        <uc:EducationSection ID="ucEducation" runat="server" />
        <uc:SkillsSection ID="ucSkills" runat="server" />
        <uc:AffiliationsSection ID="ucAffiliations" runat="server" />
        <uc:HobbiesSection ID="ucHobbies" runat="server" />
    </div>

    <!-- 4. Bottom-Pinned Social Links -->
    <uc:SocialLinksSection ID="ucSocialLinks" runat="server" />
</main>
```

### Component-Scoped CSS (Single File Component Pattern)
Each user control embeds its own `<style>` block directly at the top of the `.ascx` file. This encapsulates component styles alongside component markup and codebehind, enabling true modularity:

| User Control | Scoped Styles Contained Within |
| :--- | :--- |
| **`HeroSection.ascx`** | `.header-card`, `.header-left`, `.header-name`, `.header-meta-grid`, `.meta-col`, `.detail-row`, `.profile-photo`, and mobile media queries. |
| **`SummarySection.ascx`** | `.summary-card`, `.summary-text`. |
| **`EducationSection.ascx`** | `.timeline-list`, `.timeline-item`, vertical connector line (`::before`), hollow bullet node (`::after`), `.timeline-row`, `.timeline-period`. |
| **`SkillsSection.ascx`** | `.list-group`, `.list-item`, `.list-title`, `.list-desc`. |
| **`AffiliationsSection.ascx`** | Timeline layout matching education with hollow bullet nodes and period formatting. |
| **`HobbiesSection.ascx`** | Categorized list layout with titles and descriptions. |
| **`SocialLinksSection.ascx`** | `.connect-bar` stadium pill, `.social-pill-btn`, SVG layout, and hover micro-animations. |

### Global Styles in `Portfolio.aspx`
[Portfolio.aspx](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx) only retains layout and document-level styles:
- Google Font definitions & `:root` variables
- Page reset & dot-matrix background
- Top action bar navigation
- Bento grid container layout (`.bento-grid`)
- Base card padding & shadow (`.bento-card`)
- Portfolio footer (`.portfolio-footer`)
