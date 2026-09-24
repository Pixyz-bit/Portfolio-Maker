# 07 - External Assets Separation & Directory Structure Guide

## Overview
To improve maintainability, browser caching performance, and clean separation of concerns, all inline `<style>` and `<script>` blocks across `.aspx` pages and `.ascx` user controls have been extracted into dedicated static `.css` and `.js` asset files.

All assets are organized under a centralized directory structure:
```
241611JalopPersonalWebsite/
└── Frontend/
    └── Assets/
        ├── css/
        │   ├── login.css
        │   ├── signup.css
        │   ├── admin-dashboard.css
        │   ├── user-dashboard.css
        │   ├── onboarding.css
        │   ├── portfolio.css
        │   └── user-menu.css
        └── js/
            ├── login.js
            ├── signup.js
            ├── admin-dashboard.js
            ├── onboarding.js
            ├── portfolio.js
            └── user-menu.js
```

---

## 1. Asset Mapping Matrix

| Page / Control | Extracted CSS File | Extracted JS File | Details & Responsibilities |
| :--- | :--- | :--- | :--- |
| **Login.aspx** | `Frontend/Assets/css/login.css` | `Frontend/Assets/js/login.js` | Glassmorphism card, glowing accents, password toggle & submit loading spinner. |
| **Signup.aspx** | `Frontend/Assets/css/signup.css` | `Frontend/Assets/js/signup.js` | Account creation form, password reveal, client validation UX. |
| **Admin Dashboard** (`Dashboard.aspx`) | `Frontend/Assets/css/admin-dashboard.css` | `Frontend/Assets/js/admin-dashboard.js` | Statistics grid, user data table, client search/status filter, toggle status modal, edit user details modal. |
| **User Dashboard** (`Dashboard.aspx`) | `Frontend/Assets/css/user-dashboard.css` | *(Inherits global)* | Overview cards, action links, quick statistics. |
| **Onboarding.aspx** | `Frontend/Assets/css/onboarding.css` | `Frontend/Assets/js/onboarding.js` | Multi-step portfolio wizard, dynamic item add/remove repeaters, form client validation. |
| **Portfolio.aspx** & Sub-Controls | `Frontend/Assets/css/portfolio.css` | `Frontend/Assets/js/portfolio.js` | Consolidates all 7 section sub-controls (`Hero`, `Summary`, `Education`, `Skills`, `Affiliations`, `Hobbies`, `SocialLinks`), share clipboard action, `@media print` vector export rules. |
| **UserMenu.ascx** | `Frontend/Assets/css/user-menu.css` | `Frontend/Assets/js/user-menu.js` | Floating avatar dropdown, logout action trigger, outside-click dismissal. |

---

## 2. Key Architecture Patterns

### A. ASP.NET Server Control ID Decoupling
Because static `.js` files are served directly by IIS without server-side ASPX compilation tags (`<%= ... %>`), we implemented a universal client-side element resolution helper:
```javascript
function getEl(id) {
    return document.getElementById(id) || 
           document.querySelector('[id$="' + id + '"]') || 
           document.querySelector('[name$="' + id + '"]');
}
```
This guarantees reliable element selection whether ASP.NET emits a direct `id="txtSearch"` or an automatically qualified hierarchy ID like `id="ctl00_MainContent_txtSearch"`.

### B. Shared User Control Linking via `ResolveUrl`
The navigation user control ([`Frontend/User/Controls/UserMenu.ascx`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Controls/UserMenu.ascx)) is embedded across both `Admin/` and `User/` folder hierarchies. To avoid broken relative paths, its assets are linked via:
```html
<link rel="stylesheet" href="<%= Page.ResolveUrl("~/Frontend/Assets/css/user-menu.css") %>" />
<script src="<%= Page.ResolveUrl("~/Frontend/Assets/js/user-menu.js") %>" defer></script>
```

### C. Consolidated Portfolio CSS
Instead of generating 7 tiny 20-line stylesheets for each portfolio sub-control (`HeroSection.ascx`, `EducationSection.ascx`, etc.), all portfolio section styling was merged into a single [`Frontend/Assets/css/portfolio.css`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Assets/css/portfolio.css).
- Reduces browser HTTP roundtrips to 1 request.
- Centralizes print media rules and typography tokens.
- Eliminates code duplication across components.

---

## 3. MSBuild Project Integration
All 13 new static files were registered in [`241611JalopPersonalWebsite.csproj`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/241611JalopPersonalWebsite.csproj) under `<ItemGroup>`:
```xml
<Content Include="Frontend\Assets\css\admin-dashboard.css" />
<Content Include="Frontend\Assets\css\login.css" />
<Content Include="Frontend\Assets\css\onboarding.css" />
<Content Include="Frontend\Assets\css\portfolio.css" />
<Content Include="Frontend\Assets\css\signup.css" />
<Content Include="Frontend\Assets\css\user-dashboard.css" />
<Content Include="Frontend\Assets\css\user-menu.css" />
<Content Include="Frontend\Assets\js\admin-dashboard.js" />
<Content Include="Frontend\Assets\js\login.js" />
<Content Include="Frontend\Assets\js\onboarding.js" />
<Content Include="Frontend\Assets\js\portfolio.js" />
<Content Include="Frontend\Assets\js\signup.js" />
<Content Include="Frontend\Assets\js\user-menu.js" />
```
Compilation with MSBuild builds cleanly with **0 Warnings, 0 Errors**.
