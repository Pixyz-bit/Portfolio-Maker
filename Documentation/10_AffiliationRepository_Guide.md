# 10 - Affiliation Repository Guide (Full CRUD Operations)

## 1. What is the `AffiliationRepository`?
The **`AffiliationRepository`** is the data access layer dedicated to managing user affiliations, organizations, clubs, and volunteer positions in `dbo.Affiliations`.
Because a user can be affiliated with multiple organizations (1-to-Many relationship), this repository provides full CRUD (Create, Read, Update, Delete) methods using the `Affiliation` model:
- **`Create`**: Inserts a new organization or role record linked to a user's `UserID`.
- **`GetByUserId`**: Retrieves all organizations and memberships for a user as a `List<Affiliation>`.
- **`GetById`**: Retrieves a single affiliation by primary key `AffiliationID`.
- **`Update`**: Saves modifications made to an existing affiliation (organization name, position, start and end years).
- **`Delete`**: Removes an affiliation record from the database.

---

## 2. SQL Schema Mapping
This repository maps to the **`dbo.Affiliations`** table created in `02_Alter_Profile_Affiliations_SocialLinks.sql`:

| Column | Data Type | Constraint | C# Model Property | Description |
| :--- | :--- | :--- | :--- | :--- |
| `AffiliationID` | `INT` | `IDENTITY(1,1)`, PK | `affiliation.AffiliationID` | Auto-generated primary key |
| `UserID` | `INT` | FK to `dbo.Users` | `affiliation.UserID` | Associates affiliation with user |
| `OrganizationName` | `NVARCHAR(150)` | `NOT NULL` | `affiliation.OrganizationName` | Name of organization or club |
| `Position` | `NVARCHAR(100)` | `NOT NULL` | `affiliation.Position` | Role or title held |
| `StartYear` | `NVARCHAR(10)` | `NOT NULL` | `affiliation.StartYear` | Starting year (e.g. '2021') |
| `EndYear` | `NVARCHAR(10)` | `NULL` | `affiliation.EndYear` | Ending year (e.g. '2024' or 'Present') |
| `CreatedAt` | `DATETIME2` | `DEFAULT SYSUTCDATETIME()` | `affiliation.CreatedAt` | Creation timestamp |

---

## 3. Directory & Namespace Convention

- **Repository File**: `241611JalopPersonalWebsite/Repository/AffiliationRepository.cs`
- **Model File**: `241611JalopPersonalWebsite/Model/Affiliation.cs`

Import both namespaces in your code-behind files:
```csharp
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;
```

---

## 4. Entire Code Snippet for `AffiliationRepository.cs`

File: `241611JalopPersonalWebsite/Repository/AffiliationRepository.cs`

```csharp
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class AffiliationRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Affiliation
        // =========================================================================
        public static bool Create(Affiliation affiliation, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliation == null)
            {
                errorMessage = "Affiliation details cannot be null.";
                return false;
            }

            if (affiliation.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.OrganizationName))
            {
                errorMessage = "Organization name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.Position))
            {
                errorMessage = "Position / Role is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.StartYear))
            {
                errorMessage = "Start Year is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        INSERT INTO dbo.Affiliations (UserID, OrganizationName, Position, StartYear, EndYear, CreatedAt)
                        VALUES (@UserID, @OrganizationName, @Position, @StartYear, @EndYear, SYSUTCDATETIME());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = affiliation.UserID;
                        cmd.Parameters.Add("@OrganizationName", SqlDbType.NVarChar, 150).Value = affiliation.OrganizationName.Trim();
                        cmd.Parameters.Add("@Position", SqlDbType.NVarChar, 100).Value = affiliation.Position.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = affiliation.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(affiliation.EndYear) ? (object)DBNull.Value : affiliation.EndYear.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            affiliation.AffiliationID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated AffiliationID.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return false;
            }
        }

        // =========================================================================
        // 2. READ ALL: Get All Affiliations by UserID
        // =========================================================================
        public static List<Affiliation> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Affiliation> list = new List<Affiliation>();

            if (userId <= 0)
            {
                errorMessage = "Invalid UserID.";
                return list;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT AffiliationID, UserID, OrganizationName, Position, StartYear, EndYear, CreatedAt
                        FROM dbo.Affiliations
                        WHERE UserID = @UserID
                        ORDER BY CreatedAt ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                list.Add(MapFromReader(reader));
                            }
                        }
                    }
                }

                return list;
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return list;
            }
        }

        // =========================================================================
        // 3. READ ONE: Get Single Affiliation by AffiliationID
        // =========================================================================
        public static Affiliation GetById(int affiliationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliationId <= 0)
            {
                errorMessage = "Invalid AffiliationID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT AffiliationID, UserID, OrganizationName, Position, StartYear, EndYear, CreatedAt
                        FROM dbo.Affiliations
                        WHERE AffiliationID = @AffiliationID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@AffiliationID", SqlDbType.Int).Value = affiliationId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Affiliation not found.";
                                return null;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return null;
            }
        }

        // =========================================================================
        // 4. UPDATE: Update Existing Affiliation
        // =========================================================================
        public static bool Update(Affiliation affiliation, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliation == null)
            {
                errorMessage = "Affiliation details cannot be null.";
                return false;
            }

            if (affiliation.AffiliationID <= 0)
            {
                errorMessage = "Invalid AffiliationID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.OrganizationName))
            {
                errorMessage = "Organization name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.Position))
            {
                errorMessage = "Position / Role is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.StartYear))
            {
                errorMessage = "Start Year is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        UPDATE dbo.Affiliations
                        SET OrganizationName = @OrganizationName,
                            Position = @Position,
                            StartYear = @StartYear,
                            EndYear = @EndYear
                        WHERE AffiliationID = @AffiliationID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@AffiliationID", SqlDbType.Int).Value = affiliation.AffiliationID;
                        cmd.Parameters.Add("@OrganizationName", SqlDbType.NVarChar, 150).Value = affiliation.OrganizationName.Trim();
                        cmd.Parameters.Add("@Position", SqlDbType.NVarChar, 100).Value = affiliation.Position.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = affiliation.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(affiliation.EndYear) ? (object)DBNull.Value : affiliation.EndYear.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Affiliation record not found to update.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return false;
            }
        }

        // =========================================================================
        // 5. DELETE: Remove Affiliation by AffiliationID
        // =========================================================================
        public static bool Delete(int affiliationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliationId <= 0)
            {
                errorMessage = "Invalid AffiliationID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "DELETE FROM dbo.Affiliations WHERE AffiliationID = @AffiliationID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@AffiliationID", SqlDbType.Int).Value = affiliationId;

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Affiliation record not found to delete.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return false;
            }
        }

        // =========================================================================
        // HELPER: Map SqlDataReader to Affiliation Model
        // =========================================================================
        private static Affiliation MapFromReader(SqlDataReader reader)
        {
            return new Affiliation
            {
                AffiliationID = reader.GetInt32(reader.GetOrdinal("AffiliationID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                OrganizationName = reader.GetString(reader.GetOrdinal("OrganizationName")),
                Position = reader.GetString(reader.GetOrdinal("Position")),
                StartYear = reader.GetString(reader.GetOrdinal("StartYear")),
                EndYear = reader.IsDBNull(reader.GetOrdinal("EndYear")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("EndYear")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
```

---

## 5. Instructions: How to Use Each Function in Code-Behind

### Instruction 1: Adding an Affiliation (`AffiliationRepository.Create`)
```csharp
protected void btnAddAffiliation_Click(object sender, EventArgs e)
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // 1. Bundle form textboxes into Affiliation model
    Affiliation newAffiliation = new Affiliation
    {
        UserID = currentUserId,
        OrganizationName = txtOrgName.Text.Trim(),
        Position = txtPosition.Text.Trim(),
        StartYear = txtStartYear.Text.Trim(),
        EndYear = string.IsNullOrWhiteSpace(txtEndYear.Text) ? "Present" : txtEndYear.Text.Trim()
    };

    // 2. Call Create in AffiliationRepository
    if (AffiliationRepository.Create(newAffiliation, out string error))
    {
        lblStatus.ForeColor = System.Drawing.Color.Green;
        lblStatus.Text = "Affiliation saved successfully!";
        LoadAffiliations(); // Refresh list
    }
    else
    {
        lblStatus.ForeColor = System.Drawing.Color.Red;
        lblStatus.Text = error;
    }
}
```

---

### Instruction 2: Loading Affiliations for a User (`AffiliationRepository.GetByUserId`)
Call this in `Page_Load` to bind a `GridView` or `Repeater`:

```csharp
private void LoadAffiliations()
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // Returns a List<Affiliation>
    List<Affiliation> affiliations = AffiliationRepository.GetByUserId(currentUserId, out string error);

    gvAffiliations.DataSource = affiliations;
    gvAffiliations.DataBind();
}
```

---

### Instruction 3: Editing and Updating an Affiliation (`AffiliationRepository.GetById` & `Update`)
```csharp
// A. When user clicks "Edit" on a specific row:
protected void gvAffiliations_SelectedIndexChanged(object sender, EventArgs e)
{
    int selectedId = Convert.ToInt32(gvAffiliations.SelectedDataKey.Value);
    Affiliation aff = AffiliationRepository.GetById(selectedId, out string error);

    if (aff != null)
    {
        hfAffiliationId.Value = aff.AffiliationID.ToString();
        txtOrgName.Text = aff.OrganizationName;
        txtPosition.Text = aff.Position;
        txtStartYear.Text = aff.StartYear;
        txtEndYear.Text = aff.EndYear;
        btnSave.Text = "Update Affiliation";
    }
}

// B. When user saves their edit:
protected void btnSave_Click(object sender, EventArgs e)
{
    Affiliation affToUpdate = new Affiliation
    {
        AffiliationID = Convert.ToInt32(hfAffiliationId.Value),
        OrganizationName = txtOrgName.Text.Trim(),
        Position = txtPosition.Text.Trim(),
        StartYear = txtStartYear.Text.Trim(),
        EndYear = txtEndYear.Text.Trim()
    };

    if (AffiliationRepository.Update(affToUpdate, out string error))
    {
        lblStatus.Text = "Affiliation updated successfully!";
        LoadAffiliations();
    }
    else
    {
        lblStatus.Text = error;
    }
}
```

---

### Instruction 4: Deleting an Affiliation (`AffiliationRepository.Delete`)
Call this when the user clicks a delete button in your grid:

```csharp
protected void gvAffiliations_RowDeleting(object sender, GridViewDeleteEventArgs e)
{
    int affiliationId = Convert.ToInt32(gvAffiliations.DataKeys[e.RowIndex].Value);

    if (AffiliationRepository.Delete(affiliationId, out string error))
    {
        lblStatus.Text = "Affiliation deleted!";
        LoadAffiliations(); // Refresh list
    }
    else
    {
        lblStatus.Text = error;
    }
}
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
- `10_AffiliationRepository_Guide.md`: Affiliation repository (full CRUD operations and code-behind instructions).
