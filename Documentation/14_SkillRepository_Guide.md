# 14 - Skill Repository Guide (Full CRUD Operations)

## 1. What is the `SkillRepository`?
The **`SkillRepository`** is the data access layer that manages user technical and soft skills in the `dbo.Skills` table.
Because each user can have multiple skills (1-to-Many relationship), this repository provides full CRUD (Create, Read, Update, Delete) methods using the `Skill` model:
- **`Create`**: Inserts a new skill linked to a user's `UserID` and returns the generated `SkillID`.
- **`GetByUserId`**: Retrieves all skills belonging to a user as a `List<Skill>`.
- **`GetById`**: Retrieves a single skill entry by its primary key `SkillID`.
- **`Update`**: Saves modifications made to an existing skill's name and description.
- **`Delete`**: Removes a skill from the database.

---

## 2. SQL Schema Mapping
This repository maps to the **`dbo.Skills`** table created in `01_Schema.sql`:

| Column | Data Type | Constraint | C# Model Property | Description |
| :--- | :--- | :--- | :--- | :--- |
| `SkillID` | `INT` | `IDENTITY(1,1)`, PK | `skill.SkillID` | Auto-generated primary key |
| `UserID` | `INT` | FK to `dbo.Users` | `skill.UserID` | Associates skill with a specific user |
| `SkillName` | `NVARCHAR(100)` | `NOT NULL` | `skill.SkillName` | Name of skill (e.g. 'C#', 'SQL Server') |
| `SkillDescription` | `NVARCHAR(MAX)` | `NULL` | `skill.SkillDescription` | Optional notes or proficiency level |
| `CreatedAt` | `DATETIME2` | `DEFAULT SYSUTCDATETIME()` | `skill.CreatedAt` | Creation timestamp |

---

## 3. Directory & Namespace Convention
- **Repository File**: `241611JalopPersonalWebsite/Repository/SkillRepository.cs`
- **Model File**: `241611JalopPersonalWebsite/Model/Skill.cs`

Import both namespaces in your code-behind files:
```csharp
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;
```

---

## 4. Entire Code Snippet for `SkillRepository.cs`

File: `241611JalopPersonalWebsite/Repository/SkillRepository.cs`

```csharp
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class SkillRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Skill
        // =========================================================================
        public static bool Create(Skill skill, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skill == null)
            {
                errorMessage = "Skill details cannot be null.";
                return false;
            }

            if (skill.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(skill.SkillName))
            {
                errorMessage = "Skill name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        INSERT INTO dbo.Skills (UserID, SkillName, SkillDescription, CreatedAt)
                        VALUES (@UserID, @SkillName, @SkillDescription, SYSUTCDATETIME());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = skill.UserID;
                        cmd.Parameters.Add("@SkillName", SqlDbType.NVarChar, 100).Value = skill.SkillName.Trim();
                        cmd.Parameters.Add("@SkillDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(skill.SkillDescription) ? (object)DBNull.Value : skill.SkillDescription.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            skill.SkillID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated SkillID.";
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
        // 2. READ ALL: Get All Skills by UserID
        // =========================================================================
        public static List<Skill> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Skill> list = new List<Skill>();

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
                        SELECT SkillID, UserID, SkillName, SkillDescription, CreatedAt
                        FROM dbo.Skills
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
        // 3. READ ONE: Get Single Skill by SkillID
        // =========================================================================
        public static Skill GetById(int skillId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skillId <= 0)
            {
                errorMessage = "Invalid SkillID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT SkillID, UserID, SkillName, SkillDescription, CreatedAt
                        FROM dbo.Skills
                        WHERE SkillID = @SkillID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@SkillID", SqlDbType.Int).Value = skillId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Skill not found.";
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
        // 4. UPDATE: Update Existing Skill
        // =========================================================================
        public static bool Update(Skill skill, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skill == null)
            {
                errorMessage = "Skill details cannot be null.";
                return false;
            }

            if (skill.SkillID <= 0)
            {
                errorMessage = "Invalid SkillID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(skill.SkillName))
            {
                errorMessage = "Skill name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        UPDATE dbo.Skills
                        SET SkillName = @SkillName,
                            SkillDescription = @SkillDescription
                        WHERE SkillID = @SkillID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@SkillID", SqlDbType.Int).Value = skill.SkillID;
                        cmd.Parameters.Add("@SkillName", SqlDbType.NVarChar, 100).Value = skill.SkillName.Trim();
                        cmd.Parameters.Add("@SkillDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(skill.SkillDescription) ? (object)DBNull.Value : skill.SkillDescription.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Skill record not found to update.";
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
        // 5. DELETE: Remove Skill by SkillID
        // =========================================================================
        public static bool Delete(int skillId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skillId <= 0)
            {
                errorMessage = "Invalid SkillID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "DELETE FROM dbo.Skills WHERE SkillID = @SkillID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@SkillID", SqlDbType.Int).Value = skillId;

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Skill record not found to delete.";
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
        // HELPER: Map SqlDataReader to Skill Model
        // =========================================================================
        private static Skill MapFromReader(SqlDataReader reader)
        {
            return new Skill
            {
                SkillID = reader.GetInt32(reader.GetOrdinal("SkillID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                SkillName = reader.GetString(reader.GetOrdinal("SkillName")),
                SkillDescription = reader.IsDBNull(reader.GetOrdinal("SkillDescription")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("SkillDescription")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
```

---

## 5. Instructions: How to Use Each Function in Code-Behind

### Instruction 1: Adding a New Skill (`SkillRepository.Create`)
```csharp
protected void btnAddSkill_Click(object sender, EventArgs e)
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // 1. Bundle form textboxes into Skill model
    Skill newSkill = new Skill
    {
        UserID = currentUserId,
        SkillName = txtSkillName.Text.Trim(),
        SkillDescription = string.IsNullOrWhiteSpace(txtSkillDescription.Text) ? null : txtSkillDescription.Text.Trim()
    };

    // 2. Call Create in SkillRepository
    if (SkillRepository.Create(newSkill, out string error))
    {
        lblStatus.ForeColor = System.Drawing.Color.Green;
        lblStatus.Text = "Skill added successfully!";
        txtSkillName.Text = string.Empty;
        txtSkillDescription.Text = string.Empty;
        LoadSkillList(); // Refresh list / GridView
    }
    else
    {
        lblStatus.ForeColor = System.Drawing.Color.Red;
        lblStatus.Text = error;
    }
}
```

---

### Instruction 2: Loading Skills for a User (`SkillRepository.GetByUserId`)
Call this on `Page_Load` to bind a `GridView`, `Repeater`, or badge container:

```csharp
private void LoadSkillList()
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // Returns a List<Skill>
    List<Skill> skills = SkillRepository.GetByUserId(currentUserId, out string error);

    gvSkills.DataSource = skills;
    gvSkills.DataBind();
}
```

---

### Instruction 3: Editing and Updating a Skill (`SkillRepository.GetById` & `Update`)
```csharp
// A. When user clicks "Edit" on a specific row:
protected void gvSkills_SelectedIndexChanged(object sender, EventArgs e)
{
    int selectedSkillId = Convert.ToInt32(gvSkills.SelectedDataKey.Value);
    Skill skill = SkillRepository.GetById(selectedSkillId, out string error);

    if (skill != null)
    {
        hfSkillId.Value = skill.SkillID.ToString();
        txtSkillName.Text = skill.SkillName;
        txtSkillDescription.Text = skill.SkillDescription;
        btnSave.Text = "Update Skill";
    }
}

// B. When user submits their edit:
protected void btnSave_Click(object sender, EventArgs e)
{
    Skill skillToUpdate = new Skill
    {
        SkillID = Convert.ToInt32(hfSkillId.Value),
        SkillName = txtSkillName.Text.Trim(),
        SkillDescription = string.IsNullOrWhiteSpace(txtSkillDescription.Text) ? null : txtSkillDescription.Text.Trim()
    };

    if (SkillRepository.Update(skillToUpdate, out string error))
    {
        lblStatus.ForeColor = System.Drawing.Color.Green;
        lblStatus.Text = "Skill updated successfully!";
        LoadSkillList();
    }
    else
    {
        lblStatus.ForeColor = System.Drawing.Color.Red;
        lblStatus.Text = error;
    }
}
```

---

### Instruction 4: Deleting a Skill (`SkillRepository.Delete`)
Call this when the user clicks a delete button in your grid:

```csharp
protected void gvSkills_RowDeleting(object sender, GridViewDeleteEventArgs e)
{
    int skillId = Convert.ToInt32(gvSkills.DataKeys[e.RowIndex].Value);

    if (SkillRepository.Delete(skillId, out string error))
    {
        lblStatus.ForeColor = System.Drawing.Color.Green;
        lblStatus.Text = "Skill deleted successfully!";
        LoadSkillList();
    }
    else
    {
        lblStatus.ForeColor = System.Drawing.Color.Red;
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
- `12_EducationRepository_Guide.md`: Education repository (full CRUD operations).
- `13_Skill_Model_Guide.md`: Skill model and SQL schema mapping.
- `14_SkillRepository_Guide.md`: Skill repository (full CRUD operations and code-behind instructions).
