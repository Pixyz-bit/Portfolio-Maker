# Six priority fixes — 15 October 2026

The six issues selected from the final audit are addressed in the local source. The changes have not been deployed to the public host, and no production accounts, credentials or portfolios were changed.

## Changes

1. **Malformed section data cannot clear content.** The parser inspects the actual JSON root before converting it to section models. Objects such as `{}`, scalars, nulls, and arrays containing nonobjects are rejected before any save. Valid object arrays work; an explicit `[]` still intentionally clears a section. HTTP regressions verify existing skills survive rejected submissions.

2. **The visibility card saves through one path.** Card-text/background clicks invoke the same anchor action as direct switch clicks. The double-submit guard runs only in the anchor handler. The public/private label and checked state remain at the last confirmed server value until the committed result is rendered. Pending requests have a busy state, duplicate clicks are suppressed, and a failed navigation can be retried. The script URL has a new stable version so deployed clients fetch the repair.

3. **Self-deactivation and last-admin lockout are guarded centrally.** Account Settings renders the signed-in account's Active checkbox checked and disabled. Its save handler also rejects self-deactivation. The repository wraps account editing, separate status/role changes and deletion in one shared guard. A serializable transaction locks the active-admin set before changing the target, so concurrent demotions cannot both remove the final usable administrator. Rejected changes do not partially update profile/account details. Self-demotion remains possible when another active administrator exists.

4. **Images enforce current portfolio permissions.** New uploads go to `App_Data/ProfileImages`. All avatar rendering uses `Frontend/User/ProfileImage.ashx`, which looks up the indexed owner ID, verifies the filename belongs to that profile, and authorizes public access or the current active owner/administrator. Invalid/missing/unauthorized image requests return 404. Image responses are marked `no-store` and `nosniff`. Existing `~/Uploads/Profiles/...` records work through this handler without rewriting database paths; IIS request filtering blocks their old static URLs. Replacement-image cleanup still handles both storage locations.

5. **Schema reruns preserve data.** `01_Schema.sql` contains no table drops. It creates only missing base tables and indexes inside an XACT_ABORT transaction. Regression tests rerun it on an evolved, populated schema and check row counts across seven tables plus an existing content value. This bootstrap preserves existing objects; changes to existing column definitions still require explicit migrations.

6. **No predictable admin is seeded.** Fresh schema creation inserts no accounts. A trusted operator can run `Tools/InitializeAdministrator.ps1` in Windows PowerShell 5.1 after building the application and selecting the database through `SQLCONNSTR_DefaultConnection`. Names/email are command arguments; a unique password of at least 12 characters and its confirmation are prompted securely. `AdministratorSetup.CreateFirst` uses the existing salted PBKDF2 hashing and creates the account/profile transactionally. Setup refuses to run once any administrator exists, including an inactive one. There is no public web setup endpoint. The stored-procedure script now uses the selected database rather than switching to a hardcoded host database.

## Validation

- Release build, local filesystem publication and ASP.NET precompilation passed.
- **74 database/security/image regression assertions passed**, including fresh-schema/no-default-login checks, first-admin setup, repeated-bootstrap rejection, schema rerun preservation, each guarded account-change path and simultaneous admin demotions.
- **42 HTTP assertions passed**: the 18 baseline assertions plus JSON preservation, disabled/omitted self-status input, new and legacy image authorization, static-path blocking, no-store caching, immediate privacy changes, filename/owner mismatch, missing owner, traversal, missing image and protected markup checks.
- **36 JavaScript interaction assertions passed** using the production code with event bubbling: card/direct/Space activation in both initial states, confirmed-state labels, double-submit protection and retry behavior.
- Multipart probes rejected renamed nonimages, disallowed extensions and an over-2-MB upload; a valid PNG was accepted and saved under protected App_Data storage.
- In the browser, card-text clicks saved private-to-public and public-to-private changes. Space and Enter also saved. The private result blocked an anonymous portfolio request. Account Settings showed Active checked/disabled, and uploaded protected avatars rendered successfully.
- The mechanical design detector reported no findings for the changed interaction targets. The existing visual design was preserved.

Tests use synthetic accounts in a unique `PortfolioAudit_<guid>` database and a copied site under `Tests/Temp`. Production configuration/credentials are excluded from that runtime copy. Local filesystem publication is only a packaging check and is never served against the real database. The interactive setup prompt itself was syntax-checked; its C# bootstrap behavior was tested with synthetic credentials rather than entering or changing real credentials.

## Deployment

- Deploy the assembly, updated page/control markup, versioned JavaScript, image handler and Web.config together. The request-filter rule is essential: shipping the handler alone does not protect legacy static files.
- Preserve existing legacy upload files and database paths. Ensure the application identity can write to `App_Data/ProfileImages`. Verify IIS accepts the request-filter configuration; it passed under the local IIS Express fixture.
- For a fresh installation, run base schema 01, profile/sections migration 02, visibility migration 04, then stored procedures 03 against the intended database. The optional work/projects/gallery extension is separate. Bootstrap the first administrator afterward using the operator command described above and in README.
- For an existing installation, do not run first-admin setup. Review any old default account separately and reset or disable its known credential through the authorized account-management workflow. Removing a seed from source does not rotate an existing password.
- Previously downloaded or cached image copies cannot be recalled. New handler responses prevent fresh shared-cache copies; current server-side access is checked for every request.

The other findings in the 14 October audit remain separate work, including production HTTPS, atomic multi-part account saves, login throttling, image resizing, orphan-file retention, mobile overflow and broader accessibility fixes. These six repairs are not a claim that every audit issue has been resolved.

Cleanup completed: the disposable IIS Express server, uniquely named fixture database, temporary browser tab and verified workspace `Tests/Temp` directory were removed. The final repository whitespace check passed. The screenshot and upload results are retained under `Documentation/Priority_Fix_Evidence_2026-10-15`.
