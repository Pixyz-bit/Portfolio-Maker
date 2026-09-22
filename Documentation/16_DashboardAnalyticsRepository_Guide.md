# 16 - Dashboard Analytics Repository Guide

## 1. What is the `DashboardAnalyticsRepository`?
The **`DashboardAnalyticsRepository`** is the data access layer dedicated to retrieving system user metrics and account status counts for the dashboard.
It executes optimized aggregation queries against `dbo.Users` and populates the `DashboardAnalytics` model.

### Available Methods:
- **`GetDashboardAnalytics`**: Retrieves all metrics (`TotalUsers`, `TotalActive`, `TotalInactive`) simultaneously in a single fast SQL query.
- **`GetTotalUsers`**: Returns the total count of registered accounts as an integer.
- **`GetTotalActiveUsers`**: Returns the count of accounts where `IsActive = 1`.
- **`GetTotalInactiveUsers`**: Returns the count of accounts where `IsActive = 0`.

---

## 2. SQL Schema Mapping & Query Logic
This repository operates on the **`dbo.Users`** table (`01_Schema.sql`):

| Method | SQL Query | Return Type | Description |
| :--- | :--- | :--- | :--- |
| `GetDashboardAnalytics` | Aggregated query with `COUNT` and conditional `SUM` | `DashboardAnalytics` | Populates entire model in 1 round trip |
| `GetTotalUsers` | `SELECT COUNT(*) FROM dbo.Users;` | `int` | Total count of users |
| `GetTotalActiveUsers` | `SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 1;` | `int` | Count of active users |
| `GetTotalInactiveUsers` | `SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 0;` | `int` | Count of deactivated users |

---

## 3. Directory & Namespace Convention
- **Repository File**: `241611JalopPersonalWebsite/Repository/DashboardAnalyticsRepository.cs`
- **Model File**: `241611JalopPersonalWebsite/Model/DashboardAnalytics.cs`

To use the repository in any Web Forms code-behind file (`.aspx.cs`), import:
```csharp
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;
```

---

## 4. Entire Code Snippet for `DashboardAnalyticsRepository.cs`

File: `241611JalopPersonalWebsite/Repository/DashboardAnalyticsRepository.cs`

```csharp
using System;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class DashboardAnalyticsRepository
    {
        // =========================================================================
        // 1. GET ALL ANALYTICS: Retrieve TotalUsers, TotalActive, and TotalInactive
        // =========================================================================
        public static DashboardAnalytics GetDashboardAnalytics(out string errorMessage)
        {
            errorMessage = string.Empty;
            DashboardAnalytics analytics = new DashboardAnalytics();

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

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
                                analytics.TotalUsers = reader.GetInt32(reader.GetOrdinal("TotalUsers"));
                                analytics.TotalActive = reader.GetInt32(reader.GetOrdinal("TotalActive"));
                                analytics.TotalInactive = reader.GetInt32(reader.GetOrdinal("TotalInactive"));
                                return analytics;
                            }
                            else
                            {
                                errorMessage = "No data returned from Users table.";
                                return analytics;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return analytics;
            }
        }

        // =========================================================================
        // 2. GET TOTAL USERS: Count of all registered users
        // =========================================================================
        public static int GetTotalUsers(out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "SELECT COUNT(*) FROM dbo.Users;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int total))
                        {
                            return total;
                        }
                        return 0;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return 0;
            }
        }

        // =========================================================================
        // 3. GET TOTAL ACTIVE USERS: Count of active users (IsActive = 1)
        // =========================================================================
        public static int GetTotalActiveUsers(out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 1;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int activeTotal))
                        {
                            return activeTotal;
                        }
                        return 0;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return 0;
            }
        }

        // =========================================================================
        // 4. GET TOTAL INACTIVE USERS: Count of inactive/deactivated users (IsActive = 0)
        // =========================================================================
        public static int GetTotalInactiveUsers(out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 0;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int inactiveTotal))
                        {
                            return inactiveTotal;
                        }
                        return 0;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return 0;
            }
        }
    }
}
```

---

## 5. Instructions: How to Use Each Function in Code-Behind

### Instruction 1: Fetching and Displaying the Complete Analytics (`GetDashboardAnalytics`)
Recommended for dashboard pages to populate all count cards in one call:

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
    DashboardAnalytics stats = DashboardAnalyticsRepository.GetDashboardAnalytics(out string errorMessage);

    if (string.IsNullOrEmpty(errorMessage))
    {
        lblTotalUsers.Text = stats.TotalUsers.ToString("N0");
        lblTotalActive.Text = stats.TotalActive.ToString("N0");
        lblTotalInactive.Text = stats.TotalInactive.ToString("N0");
    }
    else
    {
        lblStatus.ForeColor = System.Drawing.Color.Red;
        lblStatus.Text = "Error loading analytics: " + errorMessage;
    }
}
```

---

### Instruction 2: Fetching Individual Counts
If you only need a single stat in a sidebar or status badge:

```csharp
// Total Users
int total = DashboardAnalyticsRepository.GetTotalUsers(out string error1);

// Active Users
int active = DashboardAnalyticsRepository.GetTotalActiveUsers(out string error2);

// Inactive Users
int inactive = DashboardAnalyticsRepository.GetTotalInactiveUsers(out string error3);
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
- `16_DashboardAnalyticsRepository_Guide.md`: Dashboard analytics repository functions and code-behind instructions.
