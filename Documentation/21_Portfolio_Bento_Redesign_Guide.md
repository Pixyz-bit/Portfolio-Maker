# Guide 21: Portfolio Bento Redesign (Monochromatic Timeline & Cards)

## 1. Overview
The Personal Portfolio page (`Frontend/User/Portfolio.aspx`) has been formatted to match the target bento grid design specification:
- **Top Header Card (2-Column Details with 1:1 Square Photo)**:
  - Full Name in large bold typography.
  - **Left Column**:
    - **Birthday:** `{Birthday formatted as MMMM d, yyyy}`
    - **Address:** `{Address}`
  - **Right Column**:
    - **Contact#:** `{ContactNum}`
    - **Email:** `{Email}`
  - **Profile Photo**: 1:1 square aspect ratio (`width: 170px; height: 170px; aspect-ratio: 1 / 1; object-fit: cover; border-radius: 12px; border: 2px solid #000;`).
- **Dedicated Summary Card**: Full-width card placed directly beneath the header card titled **Summary**, rendering the user's profile description (bio).
- **2x2 Bento Grid**:
  - **Top-Left**: Educational Attainment (vertical timeline with connected hollow circle nodes).
  - **Top-Right**: Technical Skills (vertical item list with bold titles and descriptions).
  - **Bottom-Left**: Affiliations (vertical timeline with connected hollow circle nodes).
  - **Bottom-Right**: Hobbies & Interest (vertical item list with bold titles and descriptions).
- **Dedicated "Connect with me!" Pill Bar (Bottom-Most)**:
  - Positioned directly below the 2x2 Bento Grid right above the footer.
  - Full-width stadium/pill container (`border-radius: 999px`) with solid black outline (`2.5px solid #000000`) and dot matrix background.
  - Left: **Connect with me!** title.
  - Right: Individual pill buttons with platform SVG icons (`Github`, `Instagram`, `Facebook`, `LinkedIn`, `Twitter / X`, etc.) and titles.
- **Aesthetic**: Monochromatic high-contrast outline styling with `2.5px solid #000000` borders, `20px` border radius, and `#cbd5e1` 16px dot matrix background pattern inside each card.

---

## 2. Key Architecture & File Updates

### `Frontend/User/Portfolio.aspx`
- Formatted `.profile-photo` to 1:1 square ratio (`170px x 170px` on desktop, `140px x 140px` on mobile, `aspect-ratio: 1 / 1`, `object-fit: cover`).
- Relocated `.connect-bar` to the bottom-most part of the main container, positioned between the 2x2 Bento Grid and the footer.
- Implemented stadium border radius (`border-radius: var(--radius-pill)`).
- Rendered SVG icons dynamically inside `.social-pill-btn` (`GetSocialIcon`).
- Formatted hero details into a clean 2-column grid (`.header-meta-grid`):
  - Column 1: `Birthday` and `Address`
  - Column 2: `Contact#` and `Email`
- Separated `Summary` into its own dedicated card (`<asp:Panel ID="pnlSummary" ... class="bento-card summary-card">`).
- Formatted 2x2 Bento Grid with equal row heights on desktop and responsive single-column layout on mobile (`<= 840px`).

### `Frontend/User/Portfolio.aspx.cs`
- Added `GetSocialIcon(string linkName)` providing platform SVGs for Github, Instagram, Facebook, LinkedIn, Twitter/X, YouTube, and generic links.
- Added `pnlConnect` visibility and `rptSocialLinks` data-binding.
- Bound User Profile fields (`Address`, `ContactEmail`, `ContactNum`, `Birthday`, and `ProfileImagePath`).

---

## 3. Visual Verification
Verified in the browser via `browser_subagent` at `http://localhost:51893/Frontend/User/Portfolio.aspx?userId=2`.
All cards, 2-column hero meta, 1:1 square profile photo, 2x2 bento grid, bottom-most "Connect with me!" stadium pill bar, timeline nodes, fonts, and responsive behaviors rendered with 0 errors and 0 warnings.
