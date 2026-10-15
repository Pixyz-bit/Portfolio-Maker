# 🚀 Portfolio Maker
[Open Portfolio Maker](http://pixyz-bit.runasp.net/Frontend/User/PublicDashboard.aspx)

An interactive, database-driven web application built with **ASP.NET Web Forms (C#)** and **Microsoft SQL Server** that empowers students, developers, and professionals to build, customize, and publish their personal portfolios without writing code.

---

## 🌟 Purpose & Features

Portfolio Maker transforms personal web presentation into a streamlined, automated experience:

- **Interactive 5-Step Onboarding:** Step-by-step wizard guiding users through personal details, avatar uploads, education credentials, skill proficiencies, organizational affiliations, hobbies, and social links.
- **Modular Component Engine:** Public portfolios are dynamically rendered using modular ASP.NET User Controls (`.ascx`), ensuring lightweight page loads and reusable layout components.
- **Real-Time Client & Server Validation:** Validates contact numbers (11 digits), email formatting, and required inputs with animated retro-brutalist toast notifications and inline feedback.
- **Parameterized Data Access:** ADO.NET uses stored procedures and parameterized SQL, with transactional portfolio saves and paginated directory queries.
- **Self-Contained & Offline-Ready:** Embeds local typography and clean CSS tokens without external CDN dependencies.
- **Role-Based Access Control:** Separate workflows for registered portfolio owners and administrative users with dashboard metrics.

---

## 🛠️ Technology Stack

- **Backend:** C#, ASP.NET Web Forms (.NET Framework 4.7.2+)
- **Data Access:** ADO.NET, Transact-SQL (T-SQL Stored Procedures)
- **Database:** Microsoft SQL Server
- **Frontend:** HTML5, CSS3 (Custom Neo-Brutalist Design Tokens), JavaScript
- **Fonts:** Plus Jakarta Sans & Inter (Offline Hosted)

---

## 📁 Key Project Structure

```text
241611JalopPersonalWebsite/
├── Backend/
│   ├── Database/
│   │   └── Migration/           # Master SQL scripts & Stored Procedures
│   ├── Models/                  # Strong-typed domain models
│   └── Repository/              # Data access repositories calling Stored Procedures
├── Frontend/
│   ├── Assets/                  # CSS styles, local fonts, and static media
│   ├── Login/                   # Authentication (Login, Signup, Recovery)
│   ├── Admin/                   # Administrative dashboards & metrics
│   └── User/
│       ├── Controls/            # Reusable modular portfolio ASCX sections
│       ├── Dashboard.aspx       # User management overview
│       ├── Onboarding.aspx      # 5-Step interactive portfolio wizard
│       └── Portfolio.aspx       # Live public-facing rendered portfolio
└── Web.config                   # Application configuration & connection strings
```

## Database initialization and first administrator

Create an empty application database using your SQL host's database-management tools, and set `SQLCONNSTR_DefaultConnection` in your process to that database. Run `Tools/InitializeDatabase.ps1`; it applies the single ordered manifest at `241611JalopPersonalWebsite/Backend/Database/Migration/manifest.txt` in a transaction. All scripts use the selected database and none creates or switches to another one. The manifest places the visibility column migration before the procedures that require it, and includes the separate work/projects/gallery tables last. Legacy numeric filename prefixes alone are not the execution order. Existing data is preserved on rerun; back up an existing database before schema updates. No account or password is seeded.

Build the application, set `SQLCONNSTR_DefaultConnection` in a trusted operator's process to the intended database, and run `Tools/InitializeAdministrator.ps1` in Windows PowerShell 5.1 with `-FirstName`, `-LastName`, and `-Email`. It securely prompts for a unique password of at least 12 characters and its confirmation. It refuses to bootstrap if any administrator already exists, including an inactive one. There is no web bootstrap endpoint. Existing installations must separately review/reset any old default administrator credential; schema reruns never silently delete or replace accounts.

## Protected profile images

New uploads are stored in `App_Data/ProfileImages`. Every rendered avatar uses `Frontend/User/ProfileImage.ashx`, which checks the portfolio's current visibility and the viewer's account permissions. Existing `~/Uploads/Profiles/...` database paths continue to work through the same endpoint, while IIS request filtering blocks their old static URLs. Deploy the updated `Web.config`, handler, application assembly and markup together, retain legacy image files, and give the application identity write permission to the new image directory. Image responses use `no-store`; previously downloaded copies cannot be recalled.

See `Tests/README.md` for isolated regression and browser testing instructions.

Account deletion also removes an unreferenced avatar from the legacy or protected storage directory after the database transaction commits. Shared files are preserved until the final reference is deleted. If disk cleanup fails, the admin sees a message that the account was deleted but the photo needs cleanup. `Tools/CleanupOrphanedProfileImages.ps1 -ApplicationRoot <site-directory>` previews unreferenced images older than 24 hours; add `-Apply` to remove them. It uses the explicitly selected `SQLCONNSTR_DefaultConnection`, preserves referenced/recent files, and checks storage path containment. No cleanup tool runs automatically against production.
