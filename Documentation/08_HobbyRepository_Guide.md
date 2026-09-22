# 08 - Hobby Repository Guide (Full CRUD Operations)

## 1. What is the `HobbyRepository`?
The **`HobbyRepository`** is the data access layer dedicated to managing user hobbies in `dbo.Hobbies`.
Because a user can have many hobbies (1-to-Many relationship), this repository provides full CRUD (Create, Read, Update, Delete) methods using the `Hobby` model:
- **`Create`**: Inserts a new hobby record tied to a user's `UserID`.
- **`GetByUserId`**: Retrieves all hobbies belonging to a user as a `List<Hobby>`.
- **`GetById`**: Retrieves a single hobby by its primary key `HobbyID`.
- **`Update`**: Saves modifications made to an existing hobby's name and description.
- **`Delete`**: Removes a hobby record from the database.

---

## 2. SQL Schema Mapping
This repository maps to the **`dbo.Hobbies`** table defined in `01_Schema.sql`:

| Column | Data Type | Constraint | C# Model Property | Description |
| :--- | :--- | :--- | :--- | :--- |
| `HobbyID` | `INT` | `IDENTITY(1,1)`, PK | `hobby.HobbyID` | Auto-generated primary key |
| `UserID` | `INT` | FK to `dbo.Users` | `hobby.UserID` | Associates hobby with user account |
| `HobbyName` | `NVARCHAR(100)` | `NOT NULL` | `hobby.HobbyName` | Name of the hobby / interest |
| `HobbyDescription` | `NVARCHAR(MAX)` | `NULL` | `hobby.HobbyDescription` | Optional detailed notes or bio |
| `CreatedAt` | `DATETIME2` | `DEFAULT SYSUTCDATETIME()` | `hobby.CreatedAt` | Creation timestamp |

---

## 3. Directory & Namespace Convention

- **Repository File**: `241611JalopPersonalWebsite/Repository/HobbyRepository.cs`
- **Model File**: `241611JalopPersonalWebsite/Model/Hobby.cs`

Import both namespaces in your code-behind files:
```csharp
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;
```

---

## 4. Entire Code Snippet for `HobbyRepository.cs`

File: `241611JalopPersonalWebsite/Repository/HobbyRepository.cs`

```csharp
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class HobbyRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Hobby
        // =========================================================================
        public static bool Create(Hobby hobby, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobby == null)
            {
                errorMessage = "Hobby details cannot be null.";
                return false;
            }

            if (hobby.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(hobby.HobbyName))
            {
                errorMessage = "Hobby name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        INSERT INTO dbo.Hobbies (UserID, HobbyName, HobbyDescription, CreatedAt)
                        VALUES (@UserID, @HobbyName, @HobbyDescription, SYSUTCDATETIME());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = hobby.UserID;
                        cmd.Parameters.Add("@HobbyName", SqlDbType.NVarChar, 100).Value = hobby.HobbyName.Trim();
                        cmd.Parameters.Add("@HobbyDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(hobby.HobbyDescription) ? (object)DBNull.Value : hobby.HobbyDescription.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            hobby.HobbyID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated HobbyID.";
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
        // 2. READ ALL: Get All Hobbies by UserID
        // =========================================================================
        public static List<Hobby> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Hobby> list = new List<Hobby>();

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
                        SELECT HobbyID, UserID, HobbyName, HobbyDescription, CreatedAt
                        FROM dbo.Hobbies
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
        // 3. READ ONE: Get Single Hobby by HobbyID
        // =========================================================================
        public static Hobby GetById(int hobbyId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobbyId <= 0)
            {
                errorMessage = "Invalid HobbyID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT HobbyID, UserID, HobbyName, HobbyDescription, CreatedAt
                        FROM dbo.Hobbies
                        WHERE HobbyID = @HobbyID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@HobbyID", SqlDbType.Int).Value = hobbyId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Hobby not found.";
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
        // 4. UPDATE: Update Existing Hobby
        // =========================================================================
        public static bool Update(Hobby hobby, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobby == null)
            {
                errorMessage = "Hobby details cannot be null.";
                return false;
            }

            if (hobby.HobbyID <= 0)
            {
                errorMessage = "Invalid HobbyID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(hobby.HobbyName))
            {
                errorMessage = "Hobby name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        UPDATE dbo.Hobbies
                        SET HobbyName = @HobbyName,
                            HobbyDescription = @HobbyDescription
                        WHERE HobbyID = @HobbyID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@HobbyID", SqlDbType.Int).Value = hobby.HobbyID;
                        cmd.Parameters.Add("@HobbyName", SqlDbType.NVarChar, 100).Value = hobby.HobbyName.Trim();
                        cmd.Parameters.Add("@HobbyDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(hobby.HobbyDescription) ? (object)DBNull.Value : hobby.HobbyDescription.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Hobby record not found to update.";
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
        // 5. DELETE: Remove Hobby by HobbyID
        // =========================================================================
        public static bool Delete(int hobbyId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobbyId <= 0)
            {
                errorMessage = "Invalid HobbyID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "DELETE FROM dbo.Hobbies WHERE HobbyID = @HobbyID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@HobbyID", SqlDbType.Int).Value = hobbyId;

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Hobby record not found to delete.";
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
        // HELPER: Map SqlDataReader to Hobby Model
        // =========================================================================
        private static Hobby MapFromReader(SqlDataReader reader)
        {
            return new Hobby
            {
                HobbyID = reader.GetInt32(reader.GetOrdinal("HobbyID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                HobbyName = reader.GetString(reader.GetOrdinal("HobbyName")),
                HobbyDescription = reader.IsDBNull(reader.GetOrdinal("HobbyDescription")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("HobbyDescription")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
```

---

## 5. Instructions: How to Use Each Function in Code-Behind

### Instruction 1: Adding a Hobby (`HobbyRepository.Create`)
```csharp
protected void btnAddHobby_Click(object sender, EventArgs e)
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // 1. Bundle form inputs into Hobby model
    Hobby newHobby = new Hobby
    {
        UserID = currentUserId,
        HobbyName = txtHobbyName.Text.Trim(),
        HobbyDescription = txtDescription.Text.Trim()
    };

    // 2. Call Create in HobbyRepository
    if (HobbyRepository.Create(newHobby, out string error))
    {
        lblStatus.ForeColor = System.Drawing.Color.Green;
        lblStatus.Text = "Hobby added successfully!";
        LoadHobbies(); // Refresh list
    }
    else
    {
        lblStatus.ForeColor = System.Drawing.Color.Red;
        lblStatus.Text = error;
    }
}
```

---

### Instruction 2: Loading All Hobbies for a User (`HobbyRepository.GetByUserId`)
Call this on `Page_Load` to bind a `GridView` or `Repeater`:

```csharp
private void LoadHobbies()
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // Returns a List<Hobby>
    List<Hobby> hobbies = HobbyRepository.GetByUserId(currentUserId, out string error);

    // Bind to UI
    gvHobbies.DataSource = hobbies;
    gvHobbies.DataBind();
}
```

---

### Instruction 3: Editing and Updating a Hobby (`HobbyRepository.GetById` & `Update`)
```csharp
// A. When the user clicks "Edit" on a specific row:
protected void gvHobbies_SelectedIndexChanged(object sender, EventArgs e)
{
    int selectedHobbyId = Convert.ToInt32(gvHobbies.SelectedDataKey.Value);

    Hobby hobby = HobbyRepository.GetById(selectedHobbyId, out string error);
    if (hobby != null)
    {
        hfHobbyId.Value = hobby.HobbyID.ToString();
        txtHobbyName.Text = hobby.HobbyName;
        txtDescription.Text = hobby.HobbyDescription;
        btnSave.Text = "Update Hobby";
    }
}

// B. When the user saves the changes:
protected void btnSave_Click(object sender, EventArgs e)
{
    Hobby hobbyToUpdate = new Hobby
    {
        HobbyID = Convert.ToInt32(hfHobbyId.Value),
        HobbyName = txtHobbyName.Text.Trim(),
        HobbyDescription = txtDescription.Text.Trim()
    };

    if (HobbyRepository.Update(hobbyToUpdate, out string error))
    {
        lblStatus.Text = "Hobby updated successfully!";
        LoadHobbies();
    }
    else
    {
        lblStatus.Text = error;
    }
}
```

---

### Instruction 4: Deleting a Hobby (`HobbyRepository.Delete`)
Call this when the user clicks a delete button in your table:

```csharp
protected void gvHobbies_RowDeleting(object sender, GridViewDeleteEventArgs e)
{
    int hobbyId = Convert.ToInt32(gvHobbies.DataKeys[e.RowIndex].Value);

    if (HobbyRepository.Delete(hobbyId, out string error))
    {
        lblStatus.Text = "Hobby deleted successfully!";
        LoadHobbies(); // Refresh list
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
- `08_HobbyRepository_Guide.md`: Hobby repository (full CRUD operations and code-behind instructions).
