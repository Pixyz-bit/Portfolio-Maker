# 26 - Portfolio PDF Export Implementation Guide

## Overview
This guide documents the implementation of the high-fidelity **"Export PDF"** feature on [`Frontend/User/Portfolio.aspx`](file:///c:/Martin%20Archive/Programming/ASP%20NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Portfolio.aspx).

The PDF export utilizes browser-native, vector-quality PDF rendering powered by a custom `@media print` stylesheet and a one-click action button.

---

## 1. How It Works

1. **Top Bar Button**: An **"Export PDF"** button is placed in the top action bar next to "Share":
   ```html
   <button type="button" class="btn-top-link" id="btnExportPdf" onclick="exportPortfolioToPdf()" title="Export Portfolio to PDF">
       <svg ...>...</svg>
       <span>Export PDF</span>
   </button>
   ```
2. **Automated Filename Suggestion**:
   When clicked, `exportPortfolioToPdf()` dynamically reads the user's name from `.header-name` and sets `document.title = "[FullName] - Portfolio"`. When the browser's PDF save dialog opens, it automatically defaults to `[FullName] - Portfolio.pdf`.
3. **High-Fidelity `@media print` Styles**:
   - **Screen Media Query Isolation**: Mobile responsive rules use `@media screen and (max-width: 840px)` so mobile-screen collapse rules never hijack the print/PDF rendering engine.
   - **No Word Wrap Distortion**: Enforces `word-break: normal` and `word-wrap: normal` on headers and details, preventing the print engine from collapsing flex columns into 1-character vertical columns.
   - **Horizontal Hero Card**: Locks `.header-card` into a 2-column horizontal resume layout with the photo on the right (`flex: 0 0 125px`) and details cleanly spaced in two 50% columns.
   - **Hides Chrome**: Automatically removes the sticky top bar, share button, export button, edit button, and user dropdown menu from the printable PDF.
   - **Print Colors & Contrast**: Enforces `-webkit-print-color-adjust: exact; print-color-adjust: exact;` so borders, badges, and avatars print with high contrast.
   - **Page Break Controls**: Applies `break-inside: avoid;` and `page-break-inside: avoid;` on cards and list rows so sections like Education or Skills never awkwardly split across pages.
   - **Clean White Canvas**: Removes web dot matrix patterns (`background-image: none !important;`) to save ink and ensure vector-crisp typography.

---

## 2. Browser Print Settings for Best Output

When clicking **Export PDF**:
1. Destination: **Save as PDF** (or **Microsoft Print to PDF**)
2. Layout: **Portrait**
3. Paper size: **A4** (or **Letter**)
4. Margins: **Default** (custom `@page` margins of 10–12mm are automatically applied)
5. Options:
   - Ensure **Background graphics** is checked if you wish to include badges and subtle borders.
   - Uncheck **Headers and footers** if you do not want browser URL/date stamps at the top/bottom of the page.
