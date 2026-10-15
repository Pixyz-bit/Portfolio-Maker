# Workflow, database setup and accessibility fixes — 15 October 2026

All nine areas selected for this pass are addressed in the local source. No production database, account, password or uploaded photo was modified, and nothing was deployed to the public host.

## What changed

| Requested area | Result |
|---|---|
| Consistent database setup | All migration scripts use the selected connection database. A single `manifest.txt` defines the correct dependency order. [Tools/InitializeDatabase.ps1](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/Tools/InitializeDatabase.ps1>) applies that manifest transactionally and refuses system databases. All five listed scripts are included in publication. README and the older database guide now point to this workflow. |
| Names silently cut off | Signup, admin creation, account editing and legacy profile write helpers reject first/last names longer than 50 characters before SQL. The editor retains its existing 50-character validation. Account inputs expose matching limits; rejected updates preserve original data. |
| Biography text causing HTTP 500 | Only the biography textbox opts out of ASP.NET's HTML request rejection. It remains bounded to 20,000 characters and is encoded when displayed. Literal `<b>…</b>` and `<script>…</script>` text saves and displays as text, without executing. Request validation remains enabled elsewhere. |
| Photo files left after account deletion | The deletion transaction captures the stored image path, commits account deletion, then removes the file only if no other profile references it. Both legacy and protected storage work. Invalid paths are refused. Storage failures produce an explicit “account deleted, photo cleanup incomplete” message. A preview-first orphan cleanup tool handles older leftover files. |
| Privacy controls shown to nonowners | The complete visibility card is rendered only when the viewer can edit that portfolio. Server authorization remains in place for forged requests. |
| Confusing failures and closed forms | Invalid Add/Edit forms reopen with nonsecret values preserved, persistent inline errors and invalid-field associations. Duplicate signup gives an actionable account message. Search distinguishes no matches, no records and read failures. Login/signup errors no longer show a fake validation delay or disappear automatically; editor/account errors also remain available. |
| Unpaged admin lists and misleading summaries | The directory fetches 12 accounts per SQL page, with deterministic ordering, clamped page bounds and full-database search/status/role filters. Search, Enter, Next/Previous and Reset use server state. Summary content is fetched in one connection/round trip, and it is bound only after every result set succeeds. Read failures show a recovery message rather than empty sections. |
| Mobile overflow from long names | Name/email flex children can shrink and wrap; action rows wrap on narrow screens. A 101-character full name (two valid 50-character names plus a space) fits without document overflow at 320, 390 and 768 CSS pixels. |
| Accessibility of controls | Menus synchronize expanded/hidden/inert state and restore focus on Escape. Dialogs focus invalid fields and recover the opener after validation postbacks. Feedback has alert/status semantics and dismissal names. Wizard steps have descriptive accessible names, current-step state and heading focus; reduced-motion preferences are respected. Required fields are identified, and visible action targets have a 44-pixel minimum. |

The existing visual design, typography and layout identity were preserved. Changed asset URLs use a stable new version so clients fetch the repaired scripts and styles.

As part of reliable edit-form recovery, admin account/profile/password changes now commit in one guarded transaction. Short or mismatched passwords do not save any account details, and a forced password-write failure rolls back the account/profile changes too. Successful combined edits were verified by signing into the disposable account with its new password.

## Main code locations

- Account validation, pagination and deletion: [Backend/Common/InputSafety.cs](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Common/InputSafety.cs>), [Backend/Repository/UserRepository.cs](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Repository/UserRepository.cs>), [Backend/Repository/UserProfileRepository.cs](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Repository/UserProfileRepository.cs>), [Backend/Common/ProfileImages.cs](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Common/ProfileImages.cs>).
- Complete summary loading: [Backend/Repository/PortfolioReadRepository.cs](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Repository/PortfolioReadRepository.cs>), [Backend/Model/UserSummaryData.cs](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Model/UserSummaryData.cs>), [Frontend/Admin/Dashboard.aspx.cs](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Admin/Dashboard.aspx.cs>).
- Form feedback and pagination: [Frontend/Admin/Dashboard.aspx](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Admin/Dashboard.aspx>), its code-behind/designer, [Frontend/User/PublicDashboard.aspx](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/PublicDashboard.aspx>) and its code-behind/designer, login/signup scripts.
- Biography handling: [Frontend/User/Onboarding.aspx](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Onboarding.aspx>); output encoding remains in the portfolio controls and admin summary.
- Permissions/menu state: [Frontend/User/Controls/UserMenu.ascx](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/User/Controls/UserMenu.ascx>), its code-behind/designer, [Frontend/Assets/js/user-menu.js](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Assets/js/user-menu.js>).
- Mobile/accessibility: [Frontend/Assets/css/admin-dashboard.css](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Assets/css/admin-dashboard.css>), [Frontend/Assets/css/accessibility.css](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Assets/css/accessibility.css>), [Frontend/Assets/js/accessibility.js](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Assets/js/accessibility.js>), [Frontend/Assets/js/onboarding.js](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Frontend/Assets/js/onboarding.js>).
- Setup/maintenance: [Backend/Database/Migration/manifest.txt](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/241611JalopPersonalWebsite/Backend/Database/Migration/manifest.txt>), [Tools/InitializeDatabase.ps1](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/Tools/InitializeDatabase.ps1>), [Tools/CleanupOrphanedProfileImages.ps1](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/Tools/CleanupOrphanedProfileImages.ps1>), README and database guide 05.

File links point to the current workspace.

## Verification

| Check | Outcome |
|---|---|
| Database/security/image regressions | **102 assertions passed**, including the real migration manifest without stripping target statements, schema reruns, all name-write paths, paginated admin filters, complete summaries, forced read failure and physical image cleanup. |
| Workflow HTTP suite | **55 assertions passed**, including 42 prerequisite baseline/priority assertions and 13 workflow assertions. |
| Additional account-edit HTTP checks | **5 new assertions passed**: short password, mismatch, forced password-write rollback, successful combined save and login with the saved credential. Its 42 repeated prerequisite assertions are not counted again. |
| Visibility JavaScript interactions | **36 assertions passed** against the production event handlers. |
| Ordered installer | Reran successfully against the populated disposable fixture. |
| Orphan cleanup tool | Preview did not delete files; Apply removed only the old unreferenced synthetic image, preserving a referenced image and a recent image. |
| Release publication | Passed; every migration named by the manifest was present in output. |
| ASP.NET precompilation | Passed, including all modified pages, controls and designer bindings. |
| Static checks | Seven JavaScript files, new PowerShell scripts and repository whitespace passed. The mechanical design detector reported no findings for the inspected changed interaction targets. |

Browser checks exercised Add User validation/value preservation, keyboard directory search, menu state/Escape, wizard names/current-step/heading focus and visible button sizes. Responsive measurements used emulated viewports:

| Viewport width | Document client width | Document scroll width |
|---:|---:|---:|
| 320 | 305 | 305 |
| 390 | 375 | 375 |
| 768 | 753 | 753 |

The 15-pixel difference is the browser scrollbar. Equal client/scroll widths show no horizontal document overflow. The tested full name had 101 characters. Screenshot export was unavailable in the browser tool; actual DOM measurements and functional results were retained instead. These checks do not certify every physical device or screen-reader combination.

Tests used synthetic records in unique `PortfolioAudit_<guid>` LocalDB databases and the copied localhost site. Read failures and password-write failures were injected only into the disposable database and restored immediately. Nonsecret logs and browser measurements are retained under `Documentation/Workflow_Fix_Evidence_2026-10-15`.

## Deployment and maintenance

Deploy the updated assembly, markup, versioned JavaScript and styles together. The previous image-handler/Web.config protection must remain installed. Give the application identity permission to delete unreferenced files in both image storage folders. No new table is required for pagination or summaries.

For database initialization, configure `SQLCONNSTR_DefaultConnection` to an explicitly selected existing application database and run [Tools/InitializeDatabase.ps1](<C:/Martin Archive/Programming/ASP NET/241611JalopPersonalWebsite/Tools/InitializeDatabase.ps1>). The manifest is authoritative; do not infer order from legacy numeric filenames. Fresh installations then use the first-administrator setup tool. Existing accounts remain unchanged.

For older leftover images, run `Tools/CleanupOrphanedProfileImages.ps1 -ApplicationRoot <site-root>` to preview candidates. Review its output before adding `-Apply`. It preserves referenced images and images newer than the configured grace period (24 hours by default, minimum one hour). If immediate deletion encounters a storage permission failure, the account remains deleted and its image is inaccessible through the protected handler; the administrator receives a cleanup warning.

The older database guide contained a hardcoded database password. It was removed from the current guide and replaced with the configured-connection workflow. If that credential is still active, rotate it through the database host. Editing documentation does not revoke a credential or erase Git history.

Other findings outside this request remain separate work, including login retry throttling, image resizing/output size, the deactivation/publication policy, the omitted legacy avatar asset, duplicate user-menu CSS and production HTTPS. This pass does not claim those are fixed.

Cleanup completed: temporary browser tabs were closed, browser viewport/visibility overrides were restored, the disposable IIS Express server and retained fixture database were removed, and the verified workspace `Tests/Temp` directory was deleted after preserving nonsecret evidence. The standalone final database regression run removed its own separate database.

