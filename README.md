# 🚀 Portfolio Maker
http://pixyz-bit.runasp.net/Frontend/User/Portfolio.aspx?userId=1
An interactive, database-driven web application built with **ASP.NET Web Forms (C#)** and **Microsoft SQL Server** that empowers students, developers, and professionals to build, customize, and publish their personal portfolios without writing code.

---

## 🌟 Purpose & Features

Portfolio Maker transforms personal web presentation into a streamlined, automated experience:

- **Interactive 5-Step Onboarding:** Step-by-step wizard guiding users through personal details, avatar uploads, education credentials, skill proficiencies, organizational affiliations, hobbies, and social links.
- **Modular Component Engine:** Public portfolios are dynamically rendered using modular ASP.NET User Controls (`.ascx`), ensuring lightweight page loads and reusable layout components.
- **Real-Time Client & Server Validation:** Validates contact numbers (11 digits), email formatting, and required inputs with animated retro-brutalist toast notifications and inline feedback.
- **100% Stored Procedure Architecture:** Data interactions are governed by parameterized SQL Server Stored Procedures via ADO.NET for robust security and performance.
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
