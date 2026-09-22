# 12 - Education Repository Guide (Full CRUD Operations)

## 1. What is the `EducationRepository`?
The **`EducationRepository`** is the data access layer dedicated to managing user educational background records in `dbo.Educations`.
Because a user can list multiple schools, colleges, and degrees (1-to-Many relationship), this repository provides full CRUD (Create, Read, Update, Delete) methods using the `Education` model:
- **`Create`**: Inserts a new educational record linked to a user's `UserID`.
- **`GetByUserId`**: Retrieves all education entries for a user as a `List<Education>`.
- **`GetById`**: Retrieves a single education entry by its primary key `EducationID`.
- **`Update`**: Saves modifications made to an existing degree, university, start year, and end year.
- **`Delete`**: Removes an education record from the database.

---

## 2. SQL Schema Mapping
This repository maps to the **`dbo.Educations`** table created in `01_Schema.sql`:

| Column | Data Type | Constraint | C# Model Property | Description |
| :--- | :--- | :--- | :--- | :--- |
| `EducationID` | `INT` | `IDENTITY(1,1)`, PK | `education.EducationID` | Auto-generated primary key |
| `UserID` | `INT` | FK to `dbo.Users` | `education.UserID` | Associates education record with user |
| `CourseName` | `NVARCHAR(150)` | `NOT NULL` | `education.CourseName` | Degree, Program, or Strand name |
| `University` | `NVARCHAR(150)` | `NOT NULL` | `education.University` | School, College, or University name |
| `StartYear` | `NVARCHAR(10)` | `NOT NULL` | `education.StartYear` | Starting year (e.g. '2020') |
| `EndYear` | `NVARCHAR(10)` | `NULL` | `education.EndYear` | Ending year or 'Present' |
| `CreatedAt` | `DATETIME2` | `DEFAULT SYSUTCDATETIME()` | `education.CreatedAt` | Creation timestamp |

---

## 3. Directory & Namespace Convention

- **Repository File**: `241611JalopPersonalWebsite/Repository/EducationRepository.cs`
- **Model File**: `241611JalopPersonalWebsite/Model/Education.cs`

Import both namespaces in your code-behind files:
```csharp
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;
```

---

## 4. Entire Code Snippet for `EducationRepository.cs`

File: `241611JalopPersonalWebsite/Repository/EducationRepository.cs`

```csharp
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class EducationRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Education Record
        // =========================================================================
        public static bool Create(Education education, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (education == null)
            {
                errorMessage = "Education details cannot be null.";
                return false;
            }

            if (education.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.CourseName))
            {
                errorMessage = "Course / Degree name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.University))
            {
                errorMessage = "University / School name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.StartYear))
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
                        INSERT INTO dbo.Educations (UserID, CourseName, University, StartYear, EndYear, CreatedAt)
                        VALUES (@UserID, @CourseName, @University, @StartYear, @EndYear, SYSUTCDATETIME());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = education.UserID;
                        cmd.Parameters.Add("@CourseName", SqlDbType.NVarChar, 150).Value = education.CourseName.Trim();
                        cmd.Parameters.Add("@University", SqlDbType.NVarChar, 150).Value = education.University.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = education.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(education.EndYear) ? (object)DBNull.Value : education.EndYear.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            education.EducationID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated EducationID.";
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
        // 2. READ ALL: Get All Education Records by UserID
        // =========================================================================
        public static List<Education> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Education> list = new List<Education>();

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
                        SELECT EducationID, UserID, CourseName, University, StartYear, EndYear, CreatedAt
                        FROM dbo.Educations
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
        // 3. READ ONE: Get Single Education Record by EducationID
        // =========================================================================
        public static Education GetById(int educationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (educationId <= 0)
            {
                errorMessage = "Invalid EducationID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT EducationID, UserID, CourseName, University, StartYear, EndYear, CreatedAt
                        FROM dbo.Educations
                        WHERE EducationID = @EducationID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@EducationID", SqlDbType.Int).Value = educationId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Education record not found.";
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
        // 4. UPDATE: Update Existing Education Record
        // =========================================================================
        public static bool Update(Education education, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (education == null)
            {
                errorMessage = "Education details cannot be null.";
                return false;
            }

            if (education.EducationID <= 0)
            {
                errorMessage = "Invalid EducationID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.CourseName))
            {
                errorMessage = "Course / Degree name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.University))
            {
                errorMessage = "University / School name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.StartYear))
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
                        UPDATE dbo.Educations
                        SET CourseName = @CourseName,
                            University = @University,
                            StartYear = @StartYear,
                            EndYear = @EndYear
                        WHERE EducationID = @EducationID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@EducationID", SqlDbType.Int).Value = education.EducationID;
                        cmd.Parameters.Add("@CourseName", SqlDbType.NVarChar, 150).Value = education.CourseName.Trim();
                        cmd.Parameters.Add("@University", SqlDbType.NVarChar, 150).Value = education.University.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = education.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(education.EndYear) ? (object)DBNull.Value : education.EndYear.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Education record not found to update.";
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
        // 5. DELETE: Remove Education Record by EducationID
        // =========================================================================
        public static bool Delete(int educationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (educationId <= 0)
            {
                errorMessage = "Invalid EducationID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "DELETE FROM dbo.Educations WHERE EducationID = @EducationID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@EducationID", SqlDbType.Int).Value = educationId;

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Education record not found to delete.";
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
        // HELPER: Map SqlDataReader to Education Model
        // =========================================================================
        private static Education MapFromReader(SqlDataReader reader)
        {
            return new Education
            {
                EducationID = reader.GetInt32(reader.GetOrdinal("EducationID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                CourseName = reader.GetString(reader.GetOrdinal("CourseName")),
                University = reader.GetString(reader.GetOrdinal("University")),
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

### Instruction 1: Adding Education Background (`EducationRepository.Create`)
```csharp
protected void btnAddEducation_Click(object sender, EventArgs e)
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // 1. Bundle form textboxes into Education model
    Education newEducation = new Education
    {
        UserID = currentUserId,
        CourseName = txtCourseName.Text.Trim(),
        University = txtUniversity.Text.Trim(),
        StartYear = txtStartYear.Text.Trim(),
        EndYear = string.IsNullOrWhiteSpace(txtEndYear.Text) ? "Present" : txtEndYear.Text.Trim()
    };

    // 2. Call Create in EducationRepository
    if (EducationRepository.Create(newEducation, out string error))
    {
        lblStatus.ForeColor = System.Drawing.Color.Green;
        lblStatus.Text = "Education record saved successfully!";
        LoadEducationList(); // Refresh list
    }
    else
    {
        lblStatus.ForeColor = System.Drawing.Color.Red;
        lblStatus.Text = error;
    }
}
```

---

### Instruction 2: Loading Education Records for a User (`EducationRepository.GetByUserId`)
Call this on `Page_Load` to bind a `GridView` or `Repeater`:

```csharp
private void LoadEducationList()
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // Returns a List<Education>
    List<Education> list = EducationRepository.GetByUserId(currentUserId, out string error);

    gvEducation.DataSource = list;
    gvEducation.DataBind();
}
```

---

### Instruction 3: Editing and Updating an Education Entry (`EducationRepository.GetById` & `Update`)
```csharp
// A. When user clicks "Edit" on a specific row:
protected void gvEducation_SelectedIndexChanged(object sender, EventArgs e)
{
    int selectedId = Convert.ToInt32(gvEducation.SelectedDataKey.Value);
    Education edu = EducationRepository.GetById(selectedId, out string error);

    if (edu != null)
    {
        hfEducationId.Value = edu.EducationID.ToString();
        txtCourseName.Text = edu.CourseName;
        txtUniversity.Text = edu.University;
        txtStartYear.Text = edu.StartYear;
        txtEndYear.Text = edu.EndYear;
        btnSave.Text = "Update Education";
    }
}

// B. When user saves their edit:
protected void btnSave_Click(object sender, EventArgs e)
{
    Education eduToUpdate = new Education
    {
        EducationID = Convert.ToInt32(hfEducationId.Value),
        CourseName = txtCourseName.Text.Trim(),
        University = txtUniversity.Text.Trim(),
        StartYear = txtStartYear.Text.Trim(),
        EndYear = txtEndYear.Text.Trim()
    };

    if (EducationRepository.Update(eduToUpdate, out string error))
    {
        lblStatus.Text = "Education record updated successfully!";
        LoadEducationList();
    }
    else
    {
        lblStatus.Text = error;
    }
}
```

---

### Instruction 4: Deleting an Education Entry (`EducationRepository.Delete`)
Call this when the user clicks a delete button in your grid:

```csharp
protected void gvEducation_RowDeleting(object sender, GridViewDeleteEventArgs e)
{
    int educationId = Convert.ToInt32(gvEducation.DataKeys[e.RowIndex].Value);

    if (EducationRepository.Delete(educationId, out string error))
    {
        lblStatus.Text = "Education record deleted!";
        LoadEducationList();
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
- `10_AffiliationRepository_Guide.md`: Affiliation repository (full CRUD operations).
- `11_Education_Model_Guide.md`: Education model and schema mapping.
- `12_EducationRepository_Guide.md`: Education repository (full CRUD operations and code-behind instructions).
