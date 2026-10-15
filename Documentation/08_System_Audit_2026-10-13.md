# System audit — 13 October 2026

Scope: ASP.NET Web Forms source, repositories, migrations, Release build, and deployed UI at pixyz-bit.runasp.net. Application source was not changed. Existing account and portfolio records were not edited, created, deleted, or toggled. The authorized administrator was signed out after testing.

## Verification

- Release MSBuild completed successfully with no reported warnings or errors. Initial sandbox registry restrictions were resolved by running the installed MSBuild with approved access.
- IIS Express started locally, but local HTTP requests returned empty 404 responses and the in-app browser blocked localhost. Local end-to-end verification was therefore unavailable. The deployed site may differ from this checkout.
- Deployed tests passed: administrator login, status filtering (two deactivated accounts), reset filters, unmatched search empty state, public directory navigation, own portfolio rendering, account menu opening, onboarding navigation between steps 1, 2, and 5, logout, and anonymous admin-route redirect to login.
- Sampled 390 × 844 viewport: admin dashboard, public directory, own portfolio, and onboarding. Measured dashboard, portfolio, and onboarding document widths did not exceed the viewport; own portfolio and onboarding had no broken images. Physical-device touch behavior, full keyboard navigation, contrast, and PDF output were not verified.
- A synthetic, database-free simulation using the built application confirmed that the login comparison accepts the stored SHA-256 hash itself as a password. It also confirmed identical passwords produce identical hashes. No real account hashes were retrieved.
- The Impeccable detector ran over Frontend. Its font/style preference warnings were excluded from functional defects; familiar fonts alone are not errors.
- No destructive save-path or security exploit was executed against the live database. Findings below distinguish runtime confirmation from source evidence.

## Prioritized findings

### 1. [P1] Login accepts a stored password hash as the password

Location: `Backend/Repository/UserRepository.cs:163–165`, hashing at `:766–783`.

Evidence: password verification compares both HashPassword(password) and password.Trim() against the database hash. Synthetic simulation returned true when the submitted password was the stored hash. This turns an exposed database hash into a usable login credential. Hashing is also unsalted, single-pass SHA-256, allowing identical-password correlation and fast guessing after a database leak.

Fix: remove the plaintext/hash equality fallback. Use a salted, adaptive password hash with versioned storage and an explicit legacy migration. Do not treat stored hashes as passwords.

### 2. [P1] Saving a portfolio can delete data and still report success

Location: `Frontend/User/Onboarding.aspx.cs:388–556`, helper methods `:588–643`.

Evidence: each section deletes existing rows before parsing replacement JSON. Malformed JSON, null items, missing required fields, repository validation failures, or database insert failures can leave a section empty or partly recreated. Deletes and inserts discard return values and errors; parse exceptions only reach Debug output. The page subsequently displays success. No transaction covers the profile and section changes.

Reproduction in a disposable database: save a profile containing existing skills with malformed hfSkillsJson, or a replacement record rejected by its repository. Check old rows and the displayed success message. This was not run on production.

Fix: deserialize and validate all sections before any writes; persist all database changes in one transaction; propagate every failure and roll back. Update existing records or replace sections atomically. This also reduces unnecessary delete/insert traffic and changing record IDs.

### 3. [P1] Portfolio sections render user content without HTML encoding

Location: `Frontend/User/Controls/SkillsSection.ascx:11–12`, `HobbiesSection.ascx:11–12`, `EducationSection.ascx:12–15`, `AffiliationsSection.ascx:12–15`, `SocialLinksSection.ascx:7–9`; `Backend/Repository/SocialLinkRepository.cs:34–44`.

Evidence: raw Eval expressions render stored strings in HTML, including a single-quoted href. The social-link repository checks only nonempty name/URL and accepts arbitrary schemes. JSON hidden fields are deserialized into these values without output sanitization. Request validation on the original form does not replace contextual encoding of decoded JSON values.

Impact: stored HTML/attribute injection and potentially script execution when visitors or administrators view a portfolio. Exploitation was not attempted against live users.

Fix: HTML-encode plain-text bindings using encoded binding expressions; attribute-encode href values and allow only absolute http/https URLs. Keep intentional trusted SVG separate from user-controlled content. Encode raw Literal assignments for names and messages as well.

### 4. [P1] Deactivation and role changes do not invalidate existing sessions

Location: `Frontend/Admin/Dashboard.aspx.cs:16`, `Frontend/User/Onboarding.aspx.cs:84–89`, `Frontend/User/Controls/UserMenu.ascx.cs:159–160`, login session setup at `Frontend/Login/Login.aspx.cs:90–95`.

Evidence: protected actions trust UserID and Role copied into Session at login. They do not check the current Users.IsActive or current database role. A deactivated user or demoted administrator can continue with the old session until it expires or is abandoned. Password resets likewise have no session-version check.

Fix: centralize authentication/authorization, check current account status and authorization version on protected requests, and invalidate sessions after deactivation, role change, or credential reset. Verify with two sessions in a disposable environment.

### 5. [P1] Visibility mutation lacks authentication and ownership checks

Location: `Frontend/User/Controls/UserMenu.ascx.cs:126–144`; `Frontend/User/Portfolio.aspx.cs:17`.

Evidence: btnToggleVisibility_Click takes its target from ViewState and updates the database without validating the current session or ownership/admin rights. Portfolio only configures user visibility/permissions on initial GET. A signed postback captured while logged in can retain the target after logout or expiration; ViewState integrity does not authenticate the current caller. No ViewStateUserKey binding was found.

Fix: authorize inside every mutation handler using current account status and owner/admin rules. Bind postbacks to the session and add CSRF protection. Do not rely on hidden controls or signed ViewState as access control. Replay was not attempted on the live site.

### 6. [P1] Account Settings can silently replace the login email

Location: `Frontend/User/Controls/UserMenu.ascx.cs:50–52`, `:155`, `:188`.

Runtime confirmed: the account email field did not equal the administrator's authorized login email. Source shows it prefers UserProfiles.ContactEmail. Saving then passes that field to AdminUpdateUser, which updates Users.Email.

Impact: saving a name or another unrelated setting can replace the login address with the public contact address, or fail because that address already belongs to another account.

Fix: load account email from Users.Email. Keep public contact email in the portfolio editor. Verify account-only changes preserve the login email. No save was submitted during this test.

### 7. [P1] Admin dialogs lack accessible labels and modal behavior

Location: `Frontend/Admin/Dashboard.aspx` add-user modal; `Frontend/User/Controls/UserMenu.ascx:101–178`; `Frontend/Assets/js/user-menu.js:142–152`.

Runtime confirmed: Add New User opens with focus still on its background trigger; the page contains no role=dialog. Visible add-user inputs lack associated labels. Account Settings likewise has no dialog role; its labels lack for/AssociatedControlID and password inputs rely on placeholders. Dynamic onboarding rows also expose placeholder-based textbox names rather than associated field labels.

Impact: screen-reader users cannot reliably identify fields or dialog boundaries; keyboard users can remain outside the modal. Relevant accessibility concerns include programmatic label relationships and focus order.

Fix: associate labels with actual generated control IDs; add dialog role, aria-modal and an accessible title; move focus inside on opening, contain Tab navigation, and restore focus on closing. Announce validation errors. Full keyboard/assistive-technology testing remains necessary.

### 8. [P2] Admin viewing another portfolio gets the wrong visibility state

Location: `Frontend/User/Portfolio.aspx.cs:182–184`; `Frontend/User/Controls/UserMenu.ascx.cs:68–81`, `:128–140`.

Evidence: Portfolio passes the logged-in administrator's menuProfile plus the viewed portfolio's targetUserId. BindUser reads IsPublic from the administrator profile, while the toggle writes to the target user. When their visibility values differ, the label is wrong and a click may write the target's current state rather than changing it.

Fix: separate menu identity from target portfolio state; fetch/read visibility for the same user the action modifies. Runtime mutation was not performed.

### 9. [P2] A database helper may execute a write twice and hide the original failure

Location: `Backend/Repository/DatabaseConnection.cs:103–119`.

Evidence: ExecuteNonQueryCount executes ExecuteScalar first, swallows any exception, and then executes the same command with ExecuteNonQuery if no usable scalar is returned. Procedures without a scalar result can therefore execute twice; a successful first write followed by a zero-row second write may be reported as failure. An exception after partial side effects can trigger a second attempt without a transaction.

Fix: define one affected-row contract per procedure and execute once. Preserve exceptions. Current procedures that return an integer scalar avoid the fallback; this is a helper failure mode, not a claim that every present operation runs twice.

### 10. [P2] Public search loads the whole directory and all active users' skills

Location: `Backend/Repository/UserProfileRepository.cs:272–363`; `Frontend/User/Portfolio.aspx.cs:246–259`.

Evidence: public directory fetches every active public portfolio, then all skills belonging to active users (including users absent from the returned directory), and filters in memory. There is no pagination. Each portfolio view also performs separate repository calls for profile and five sections.

Impact: database work, memory, response size, and request latency grow with total users instead of the visible result page. This is a scalability finding; no load benchmark was run.

Fix: filter and paginate in SQL, restrict skills to selected users, and consider one multi-result query for portfolio sections. Onboarding is another round-trip hotspot because every deleted and inserted row opens its own repository connection.

### 11. [P2] Uploads validate only the extension and retain unused files

Location: `Frontend/User/Onboarding.aspx.cs:293–321`.

Evidence: allowed extensions and 2 MB limit are checked, but image bytes are never decoded or verified. A renamed nonimage can be saved as a profile image. A new file is saved before database persistence; failed saves and replaced images have no cleanup. Existing image path is trusted from a client-editable hidden field.

Fix: validate image content/dimensions, re-encode supported formats, use the database's existing image path, stage new files, and clean up failed or superseded uploads after a successful commit. This finding does not claim arbitrary executable uploads: .aspx is not allowed by the extension check.

### 12. [P2] Every login page load probes the database and exposes diagnostic details

Location: `Frontend/Login/Login.aspx.cs:22`, `:137–210`.

Evidence: initial login GET opens a database connection and runs SELECT 1 before rendering, then registers browser-console output containing database/server identifiers and failure text. Repository exceptions are also surfaced directly in several pages.

Impact: a database outage can delay even the login form; anonymous requests incur an avoidable database round trip and receive infrastructure/error details.

Fix: put connection diagnostics behind a development-only switch or protected health endpoint. Log detailed errors server-side; return stable user-facing messages and correlation IDs.

### 13. [P2] Invalid or absent portfolio targets fall back to an unrelated user

Location: `Frontend/User/Portfolio.aspx.cs:77–134`.

Evidence: after invalid token/unauthorized numeric target handling and session fallback, the code unconditionally selects the latest active user. The comment says development-only, but there is no environment guard. A bad link can show an unrelated portfolio instead of a not-found result; logged-in users can be silently sent to their own portfolio. This does not by itself bypass the later private-portfolio check.

Fix: distinguish no target (own portfolio or public directory) from an invalid explicit target (404). Remove the development fallback from deployed behavior.

## Interface health (provisional)

These scores reflect source checks and sampled deployed screens, not WCAG certification or a performance benchmark.

| Dimension | Score / 4 | Evidence |
|---|---:|---|
| Accessibility | 1 | Missing dialog semantics, label associations, and opening focus management |
| Performance | 2 | Local fonts; unbounded directory queries and repeated database calls |
| Responsive design | 3 | Sampled mobile layouts fit; touch gestures and text scaling not tested |
| Theming | 2 | CSS variables exist, but tokens are duplicated across page styles |
| Implementation integrity | 2 | Consistent portfolio presentation; state and persistence contracts have defects |
| Total | 10 / 20 | Significant work needed |

Implementation verdict: the UI has a coherent portfolio-specific structure, but state ownership and save/error handling need correction before it can be considered reliable. Detector font warnings are aesthetic preferences, not verified errors.

Positive practices: Release compilation succeeds; repositories largely use parameterized SQL; onboarding checks current owner/admin targeting; anonymous admin navigation redirects correctly; private portfolios have a server-side content gate; social links use noopener/noreferrer; fonts are local; sampled responsive layouts fit; search provides an explicit empty state.

## Recommended order

Seven P1 findings and six P2 findings; no P0 outage was demonstrated on the deployed site.

1. Correct password verification, atomic portfolio saves, output encoding, and action-level authorization.
2. Correct account email defaults and session revocation, then target visibility state.
3. Repair dialog labels/focus with `$impeccable harden`.
4. Fix database helper execution, uploads, and invalid-target routing.
5. Optimize SQL search/pagination and diagnostics; use `$impeccable optimize` for the interface performance pass.
6. Finish with `$impeccable polish`, then rerun the audit and disposable-database tests.

The interface commands can be requested individually or together. Backend/security fixes require corresponding C#/SQL work. Regression verification should include malformed section JSON, repository insert failures, two concurrent sessions after demotion/deactivation, replayed logged-out postbacks, different login/contact emails, and opposite owner/target visibility values.

Not verified: actual database migration state, production deployment transforms, load behavior, destructive account management, password changes, file upload/save, complete PDF export, and security exploits against deployed data. No production data change was needed to establish the reported source defects.
