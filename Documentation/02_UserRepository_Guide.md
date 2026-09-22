# 02 - User Repository Guide & Database Authentication

## 1. What is a Repository?
In an ASP.NET application, the **Repository Layer** is responsible for all database communication.
- Keeps SQL queries and database commands out of Web Forms (`.aspx` / `.aspx.cs`).
- Encapsulates connections, transactions, and security checks.
- Uses **Models** (such as `UserLogin`) to bundle and transfer data cleanly between the user interface and the database.

---

## 2. Why Use Models in the Repository?

Instead of passing 5 or 6 separate parameters (`firstName`, `lastName`, `email`, `password`, etc.) to repository methods:
1. **Data Bundling (Clean Code)**: A single `UserLogin` model encapsulates all user attributes into one object.
2. **Maintenance**: If new user attributes are added in the future, method signatures do not need to be broken.
3. **Two-Way Data Transfer**:
   - **For Sign Up (`Create`)**: The form bundles user inputs into a `UserLogin` object and passes it to the repository. The repository updates the model with the generated database `UserID`.
   - **For Sign In (`Login`)**: The repository queries the database, instantiates a `UserLogin` object populated with `UserID`, `FirstName`, `LastName`, and `Email`, and returns it so the caller can store user details in `Session`.

---

## 3. Data Flow Architecture

```text
[ Web Form (Register.aspx / Login.aspx / ChangePassword.aspx) ]
                             │
                             ▼  (Bundles inputs into UserLogin model)
                   [ UserLogin Model ]
                             │
                             ▼  (Passes model / parameters to repository)
                 [ UserRepository.cs ]
                             │
                             ▼  (SQL queries & transactions)
                [ Database: dbo.Users & dbo.UserProfiles ]
```

---

## 4. Directory & Namespace Convention

- **Repository File**: `241611JalopPersonalWebsite/Repository/UserRepository.cs`
- **Model File**: `241611JalopPersonalWebsite/Model/UserLogin.cs`

Any code-behind file using the repository and model must include:
```csharp
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;
```

---

## 5. Functions Explained

### Function 1: `Create(...)` (Sign Up with `UserLogin` Model)
```csharp
public static bool Create(
    UserLogin user, 
    string confirmPassword, 
    out string errorMessage)
```
Inserts credentials into `dbo.Users` and profile details into `dbo.UserProfiles` inside a `SqlTransaction`.

### Function 2: `Login(...)` (Authenticate & Return `UserLogin` Model)
```csharp
public static bool Login(
    string email, 
    string password, 
    out UserLogin authenticatedUser, 
    out string errorMessage)
```
Validates credentials against `dbo.Users` and returns a populated `UserLogin` model.

### Function 3: `ChangePassword(...)` (Update / Edit User Password)
```csharp
public static bool ChangePassword(
    int userId, 
    string currentPassword, 
    string newPassword, 
    string confirmNewPassword, 
    out string errorMessage)
```
Verifies the user's current password against the stored hash in `dbo.Users`, and updates it with the new SHA-256 hashed password.

### Function 4: `UpdateEmail(...)` (Update / Edit Login Email)
```csharp
public static bool UpdateEmail(
    int userId, 
    string newEmail, 
    out string errorMessage)
```
Validates format, checks for duplicates, and updates `dbo.Users.Email`.

---

## 6. Entire Code Snippet for `UserRepository.cs`

File: `241611JalopPersonalWebsite/Repository/UserRepository.cs`

```csharp
using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class UserRepository
    {
        // =========================================================================
        // 1. CREATE: Inserts into dbo.Users and dbo.UserProfiles with Transaction
        // =========================================================================
        public static bool Create(
            UserLogin user, 
            string confirmPassword, 
            out string errorMessage)
        {
            errorMessage = string.Empty;

            if (user == null)
            {
                errorMessage = "User details cannot be empty.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(user.FirstName))
            {
                errorMessage = "First Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(user.LastName))
            {
                errorMessage = "Last Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(user.Email))
            {
                errorMessage = "Email is required.";
                return false;
            }

            if (!Regex.IsMatch(user.Email.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                errorMessage = "Please enter a valid email address.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(user.Password))
            {
                errorMessage = "Password is required.";
                return false;
            }

            if (user.Password.Length < 6)
            {
                errorMessage = "Password must be at least 6 characters long.";
                return false;
            }

            if (user.Password != confirmPassword)
            {
                errorMessage = "Passwords do not match.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string checkEmailQuery = "SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkEmailQuery, conn))
                    {
                        checkCmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = user.Email.Trim();
                        int emailCount = Convert.ToInt32(checkCmd.ExecuteScalar());

                        if (emailCount > 0)
                        {
                            errorMessage = "An account with this email already exists.";
                            return false;
                        }
                    }

                    string hashedPassword = HashPassword(user.Password);

                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        int newUserId = 0;

                        try
                        {
                            string insertUserQuery = @"
                                INSERT INTO dbo.Users (Email, PasswordHash, Role, IsActive, CreatedAt, UpdatedAt)
                                VALUES (@Email, @PasswordHash, 'User', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
                                SELECT SCOPE_IDENTITY();";

                            using (SqlCommand userCmd = new SqlCommand(insertUserQuery, conn, transaction))
                            {
                                userCmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = user.Email.Trim();
                                userCmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 255).Value = hashedPassword;

                                object result = userCmd.ExecuteScalar();
                                if (result == null || !int.TryParse(result.ToString(), out newUserId))
                                {
                                    transaction.Rollback();
                                    errorMessage = "Failed to generate new user ID.";
                                    return false;
                                }
                            }

                            string insertProfileQuery = @"
                                INSERT INTO dbo.UserProfiles (UserID, FirstName, LastName, UpdatedAt)
                                VALUES (@UserID, @FirstName, @LastName, SYSUTCDATETIME());";

                            using (SqlCommand profileCmd = new SqlCommand(insertProfileQuery, conn, transaction))
                            {
                                profileCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = newUserId;
                                profileCmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = user.FirstName.Trim();
                                profileCmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = user.LastName.Trim();

                                profileCmd.ExecuteNonQuery();
                            }

                            transaction.Commit();

                            user.UserID = newUserId;
                            return true;
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            errorMessage = $"Error saving registration: {ex.Message}";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database connection error: {ex.Message}";
                return false;
            }
        }

        // =========================================================================
        // 2. LOGIN: Queries database and outputs a populated UserLogin model
        // =========================================================================
        public static bool Login(
            string email, 
            string password, 
            out UserLogin authenticatedUser, 
            out string errorMessage)
        {
            authenticatedUser = null;
            errorMessage = string.Empty;

            if (string.IsNullOrWhiteSpace(email))
            {
                errorMessage = "Email is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(password))
            {
                errorMessage = "Password is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT u.UserID, u.Email, u.PasswordHash, u.IsActive, 
                               p.FirstName, p.LastName
                        FROM dbo.Users u
                        LEFT JOIN dbo.UserProfiles p ON u.UserID = p.UserID
                        WHERE u.Email = @Email";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email.Trim();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                errorMessage = "Invalid email or password.";
                                return false;
                            }

                            int userId = reader.GetInt32(reader.GetOrdinal("UserID"));
                            string dbEmail = reader.GetString(reader.GetOrdinal("Email"));
                            string dbPasswordHash = reader.GetString(reader.GetOrdinal("PasswordHash"));
                            bool isActive = reader.GetBoolean(reader.GetOrdinal("IsActive"));
                            string firstName = reader.IsDBNull(reader.GetOrdinal("FirstName")) ? "" : reader.GetString(reader.GetOrdinal("FirstName"));
                            string lastName = reader.IsDBNull(reader.GetOrdinal("LastName")) ? "" : reader.GetString(reader.GetOrdinal("LastName"));

                            if (!isActive)
                            {
                                errorMessage = "Your account has been deactivated. Please contact an administrator.";
                                return false;
                            }

                            string enteredPasswordHash = HashPassword(password);
                            bool passwordMatches = string.Equals(dbPasswordHash, enteredPasswordHash, StringComparison.OrdinalIgnoreCase)
                                                || string.Equals(dbPasswordHash, password, StringComparison.Ordinal);

                            if (!passwordMatches)
                            {
                                errorMessage = "Invalid email or password.";
                                return false;
                            }

                            authenticatedUser = new UserLogin
                            {
                                UserID = userId,
                                FirstName = firstName,
                                LastName = lastName,
                                Email = dbEmail
                            };

                            return true;
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
        // 3. UPDATE / EDIT: Change User Password
        // =========================================================================
        public static bool ChangePassword(
            int userId, 
            string currentPassword, 
            string newPassword, 
            string confirmNewPassword, 
            out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid UserID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(currentPassword))
            {
                errorMessage = "Current password is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(newPassword))
            {
                errorMessage = "New password is required.";
                return false;
            }

            if (newPassword.Length < 6)
            {
                errorMessage = "New password must be at least 6 characters long.";
                return false;
            }

            if (newPassword != confirmNewPassword)
            {
                errorMessage = "New password and confirmation do not match.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string checkQuery = "SELECT PasswordHash FROM dbo.Users WHERE UserID = @UserID";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        object result = checkCmd.ExecuteScalar();

                        if (result == null)
                        {
                            errorMessage = "User account not found.";
                            return false;
                        }

                        string dbHash = result.ToString();
                        string currentHash = HashPassword(currentPassword);
                        bool isCurrentValid = string.Equals(dbHash, currentHash, StringComparison.OrdinalIgnoreCase)
                                           || string.Equals(dbHash, currentPassword, StringComparison.Ordinal);

                        if (!isCurrentValid)
                        {
                            errorMessage = "Incorrect current password.";
                            return false;
                        }
                    }

                    string updateQuery = @"
                        UPDATE dbo.Users
                        SET PasswordHash = @NewPasswordHash,
                            UpdatedAt = SYSUTCDATETIME()
                        WHERE UserID = @UserID";

                    using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                    {
                        updateCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        updateCmd.Parameters.Add("@NewPasswordHash", SqlDbType.NVarChar, 255).Value = HashPassword(newPassword);

                        int rows = updateCmd.ExecuteNonQuery();
                        return rows > 0;
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
        // 4. UPDATE / EDIT: Change User Login Email
        // =========================================================================
        public static bool UpdateEmail(
            int userId, 
            string newEmail, 
            out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid UserID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(newEmail))
            {
                errorMessage = "New email is required.";
                return false;
            }

            if (!Regex.IsMatch(newEmail.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                errorMessage = "Please enter a valid email address.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string checkQuery = "SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email AND UserID <> @UserID";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = newEmail.Trim();
                        checkCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (count > 0)
                        {
                            errorMessage = "An account with this email already exists.";
                            return false;
                        }
                    }

                    string updateQuery = @"
                        UPDATE dbo.Users
                        SET Email = @Email,
                            UpdatedAt = SYSUTCDATETIME()
                        WHERE UserID = @UserID";

                    using (SqlCommand updateCmd = new SqlCommand(updateQuery, conn))
                    {
                        updateCmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = newEmail.Trim();
                        updateCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        int rows = updateCmd.ExecuteNonQuery();
                        return rows > 0;
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
        // 5. HELPER: SHA-256 Password Hashing
        // =========================================================================
        public static string HashPassword(string plainTextPassword)
        {
            if (string.IsNullOrEmpty(plainTextPassword))
                return string.Empty;

            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(plainTextPassword));
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    sb.Append(bytes[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }
    }
}
```

---

## 7. Instructions: How to Use Each Function in Code-Behind

### Instruction 1: Sign Up (`UserRepository.Create`)
```csharp
protected void btnSignUp_Click(object sender, EventArgs e)
{
    UserLogin newUser = new UserLogin
    {
        FirstName = txtFirstName.Text.Trim(),
        LastName = txtLastName.Text.Trim(),
        Email = txtEmail.Text.Trim(),
        Password = txtPassword.Text
    };

    string confirmPassword = txtConfirmPassword.Text;

    if (UserRepository.Create(newUser, confirmPassword, out string error))
    {
        Response.Redirect("Login.aspx");
    }
    else
    {
        lblErrorMessage.Text = error;
    }
}
```

### Instruction 2: Sign In (`UserRepository.Login`)
```csharp
protected void btnLogin_Click(object sender, EventArgs e)
{
    string email = txtEmail.Text.Trim();
    string password = txtPassword.Text;

    if (UserRepository.Login(email, password, out UserLogin user, out string error))
    {
        Session["UserID"] = user.UserID;
        Session["UserEmail"] = user.Email;
        Session["UserName"] = $"{user.FirstName} {user.LastName}";

        Response.Redirect("~/PortfolioTemplate.aspx");
    }
    else
    {
        lblErrorMessage.Text = error;
    }
}
```

### Instruction 3: Change Password (`UserRepository.ChangePassword`)
```csharp
protected void btnChangePassword_Click(object sender, EventArgs e)
{
    int userId = Convert.ToInt32(Session["UserID"]);
    string currentPass = txtCurrentPassword.Text;
    string newPass = txtNewPassword.Text;
    string confirmPass = txtConfirmNewPassword.Text;

    if (UserRepository.ChangePassword(userId, currentPass, newPass, confirmPass, out string error))
    {
        lblStatus.Text = "Password changed successfully!";
    }
    else
    {
        lblStatus.Text = error;
    }
}
```

### Instruction 4: Update Email (`UserRepository.UpdateEmail`)
```csharp
protected void btnUpdateEmail_Click(object sender, EventArgs e)
{
    int userId = Convert.ToInt32(Session["UserID"]);
    string newEmail = txtNewEmail.Text.Trim();

    if (UserRepository.UpdateEmail(userId, newEmail, out string error))
    {
        Session["UserEmail"] = newEmail;
        lblStatus.Text = "Email updated successfully!";
    }
    else
    {
        lblStatus.Text = error;
    }
}
```

---

## 8. Sequential Documentation Index
- `01_Models_Guide.md`: Model architecture and `UserLogin` model.
- `02_UserRepository_Guide.md`: User repository (`Create`, `Login`, `ChangePassword`, `UpdateEmail`).
- `03_UserProfile_Guide.md`: Personal profile model and SQL schema mapping.
- `04_UserProfileRepository_Guide.md`: User profile repository (`Create`, `Update`, `GetByUserId`, `GetByProfileId`).
- `05_SocialLink_Model_Guide.md`: Social links model and web form walkthrough.
- `06_SocialLinkRepository_Guide.md`: Social links repository (full CRUD operations).
