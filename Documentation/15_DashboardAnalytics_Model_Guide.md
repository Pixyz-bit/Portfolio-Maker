# 15 - Dashboard Analytics Model Guide

## 1. What is the `DashboardAnalytics` Model?
The **`DashboardAnalytics`** model is a data transfer object dedicated to tracking overall user account statistics on the website dashboard.
It contains:
- **`TotalUsers`**: The total count of all registered user accounts.
- **`TotalActive`**: The count of active user accounts (`IsActive = 1`).
- **`TotalInactive`**: The count of inactive/deactivated user accounts (`IsActive = 0`).

---

## 2. SQL Schema Mapping
This model aggregates data from the **`dbo.Users`** table created in `01_Schema.sql`:

| Model Property | C# Data Type | SQL Source / Aggregation | Description |
| :--- | :--- | :--- | :--- |
| `TotalUsers` | `int` | `COUNT(*)` | Total registered accounts in `dbo.Users` |
| `TotalActive` | `int` | `SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END)` | Count of active users able to log in |
| `TotalInactive` | `int` | `SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END)` | Count of deactivated or disabled accounts |

---

## 3. Directory & Namespace Convention
- **Model File**: `241611JalopPersonalWebsite/Model/DashboardAnalytics.cs`
- **Namespace**: `_241611JalopPersonalWebsite.Model`

To use the model in your Web Forms code-behind files (`.aspx.cs`), import:
```csharp
using _241611JalopPersonalWebsite.Model;
```

---

## 4. Entire Code Snippet for `DashboardAnalytics.cs`

File: `241611JalopPersonalWebsite/Model/DashboardAnalytics.cs`

```csharp
namespace _241611JalopPersonalWebsite.Model
{
    public class DashboardAnalytics
    {
        public int TotalUsers { get; set; }
        public int TotalActive { get; set; }
        public int TotalInactive { get; set; }
    }
}
```

---

## 5. Step-by-Step Instructions: How to Use the Model in ASP.NET Web Forms

### Step 1: Populating the Model from Database (Single SQL Query)
When querying the counts in a repository method or code-behind:

```csharp
using System;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

public static DashboardAnalytics GetDashboardAnalytics(out string errorMessage)
{
    errorMessage = string.Empty;
    DashboardAnalytics stats = new DashboardAnalytics();

    try
    {
        using (SqlConnection conn = DatabaseConnection.GetConnection())
        {
            conn.Open();

            // Retrieves TotalUsers, TotalActive, and TotalInactive in a single query
            string query = @"
                SELECT 
                    COUNT(*) AS TotalUsers,
                    ISNULL(SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END), 0) AS TotalActive,
                    ISNULL(SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END), 0) AS TotalInactive
                FROM dbo.Users;";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        stats.TotalUsers = reader.GetInt32(reader.GetOrdinal("TotalUsers"));
                        stats.TotalActive = reader.GetInt32(reader.GetOrdinal("TotalActive"));
                        stats.TotalInactive = reader.GetInt32(reader.GetOrdinal("TotalInactive"));
                    }
                }
            }
        }
    }
    catch (Exception ex)
    {
        errorMessage = ex.Message;
    }

    return stats;
}
```

---

### Step 2: Displaying the Analytics on a Dashboard Page (`.aspx.cs`)
In your dashboard page code-behind:

```csharp
protected void Page_Load(object sender, EventArgs e)
{
    if (!IsPostBack)
    {
        LoadAnalytics();
    }
}

private void LoadAnalytics()
{
    DashboardAnalytics stats = GetDashboardAnalytics(out string error);

    if (string.IsNullOrEmpty(error))
    {
        // Bind to Label controls on your dashboard page
        lblTotalUsers.Text = stats.TotalUsers.ToString("N0");
        lblTotalActive.Text = stats.TotalActive.ToString("N0");
        lblTotalInactive.Text = stats.TotalInactive.ToString("N0");
    }
    else
    {
        lblStatus.Text = "Failed to load dashboard metrics: " + error;
    }
}
```

---

### Step 3: Example Web Forms Dashboard UI Markup (`.aspx`)
```html
<div class="row">
    <!-- Total Users Card -->
    <div class="col-md-4">
        <div class="card bg-primary text-white p-3 mb-3">
            <h5>Total Users</h5>
            <h2><asp:Label ID="lblTotalUsers" runat="server" Text="0" /></h2>
        </div>
    </div>

    <!-- Total Active Card -->
    <div class="col-md-4">
        <div class="card bg-success text-white p-3 mb-3">
            <h5>Total Active</h5>
            <h2><asp:Label ID="lblTotalActive" runat="server" Text="0" /></h2>
        </div>
    </div>

    <!-- Total Inactive Card -->
    <div class="col-md-4">
        <div class="card bg-danger text-white p-3 mb-3">
            <h5>Total Inactive</h5>
            <h2><asp:Label ID="lblTotalInactive" runat="server" Text="0" /></h2>
        </div>
    </div>
</div>
```

---

## 6. Sequential Documentation Index
- `01_Models_Guide.md`: Model architecture and `UserLogin` model.
- `02_UserRepository_Guide.md`: User repository (`Create`, `Login`, `ChangePassword`, `UpdateEmail`).
- `03_UserProfile_Guide.md`: Personal profile model and SQL schema mapping.
- `04_UserProfileRepository_Guide.md`: User profile repository (`Create`, `Update`, `GetByUserId`, `GetByProfileId`).
- `05_SocialLink_Model_Guide.md`: Social links model and schema mapping.
- `06_SocialLinkRepository_Guide.md`: Social links repository (full CRUD operations).
- `07_Hobby_Model_Guide.md`: Hobby model and web form walkthrough.
- `08_HobbyRepository_Guide.md`: Hobby repository (full CRUD operations).
- `09_Affiliation_Model_Guide.md`: Affiliation model and schema mapping.
- `10_AffiliationRepository_Guide.md`: Affiliation repository (full CRUD operations).
- `11_Education_Model_Guide.md`: Education model and schema mapping.
- `12_EducationRepository_Guide.md`: Education repository (full CRUD operations).
- `13_Skill_Model_Guide.md`: Skill model and SQL schema mapping.
- `14_SkillRepository_Guide.md`: Skill repository (full CRUD operations).
- `15_DashboardAnalytics_Model_Guide.md`: Dashboard analytics model (`TotalUsers`, `TotalActive`, `TotalInactive`).
