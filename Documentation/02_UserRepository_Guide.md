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
[ Web Form (Register.aspx / Login.aspx) ]
                   │
                   ▼  (Bundles inputs into UserLogin model)
         [ UserLogin Model ]
                   │
                   ▼  (Passes model to repository)
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
- **Inputs**:
  - `UserLogin user`: Model object containing `FirstName`, `LastName`, `Email`, and `Password`.
  - `string confirmPassword`: Password confirmation string to verify against `user.Password`.
  - `out string errorMessage`: Outputs validation or database errors if the operation fails.
- **Workflow**:
  1. Validates that `user` is not null and none of its properties (`FirstName`, `LastName`, `Email`, `Password`) are empty.
  2. Confirms valid email format using Regex.
  3. Verifies `user.Password == confirmPassword`.
  4. Checks if `user.Email` already exists in `dbo.Users`.
  5. Hashes `user.Password` using SHA-256.
  6. Starts a `SqlTransaction`.
  7. Inserts credentials into `dbo.Users` and retrieves the generated `UserID` via `SCOPE_IDENTITY()`.
  8. Inserts `user.FirstName` and `user.LastName` into `dbo.UserProfiles` linked to the new `UserID`.
  9. Commits the transaction and sets `user.UserID = newUserId`.

---

### Function 2: `Login(...)` (Authenticate & Return `UserLogin` Model)
```csharp
public static bool Login(
    string email, 
    string password, 
    out UserLogin authenticatedUser, 
    out string errorMessage)
```
- **Inputs**:
  - `string email`: Login email.
  - `string password`: Plain-text password entered by the user.
  - `out UserLogin authenticatedUser`: Output parameter populated with `UserID`, `FirstName`, `LastName`, and `Email` if login succeeds; otherwise `null`.
  - `out string errorMessage`: Outputs an error description if credentials do not match or the account is deactivated.
- **Workflow**:
  1. Validates that `email` and `password` are provided.
  2. Queries `dbo.Users` joined with `dbo.UserProfiles` matching the email.
  3. Checks if the account exists and if `IsActive == 1`.
  4. Hashes the entered password and compares it to `dbo.Users.PasswordHash`.
  5. Upon success, creates and returns a populated `UserLogin` model.

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
        // 1. CREATE (Sign Up New User using the UserLogin Model)
        // =========================================================================
        public static bool Create(
            UserLogin user, 
            string confirmPassword, 
            out string errorMessage)
        {
            errorMessage = string.Empty;

            // Step 1: Model & Input Validation
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

            // Check if Password and Confirm Password match
            if (user.Password != confirmPassword)
            {
                errorMessage = "Passwords do not match.";
                return false;
            }

            // Step 2: Database Operations
            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    // Check if Email already exists in dbo.Users
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

                    // Hash password using SHA-256
                    string hashedPassword = HashPassword(user.Password);

                    // Begin Transaction for atomic insert into Users and UserProfiles
                    using (SqlTransaction transaction = conn.BeginTransaction())
                    {
                        int newUserId = 0;

                        try
                        {
                            // 2A. Insert into dbo.Users
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

                            // 2B. Insert into dbo.UserProfiles
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

                            // Assign generated ID back to the model
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
        // 2. LOGIN (Authenticate User Credentials & Return UserLogin Model)
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

                            // Populate and return the UserLogin model
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
        // 3. HELPER: SHA-256 Password Hashing
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

## 7. Step-by-Step Usage in Web Forms

### A. Sign Up Page (`Register.aspx.cs`)
```csharp
using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.User
{
    public partial class Register : Page
    {
        protected void btnSignUp_Click(object sender, EventArgs e)
        {
            // Step 1: Bundle form inputs into the UserLogin model
            UserLogin newUser = new UserLogin
            {
                FirstName = txtFirstName.Text.Trim(),
                LastName = txtLastName.Text.Trim(),
                Email = txtEmail.Text.Trim(),
                Password = txtPassword.Text
            };

            string confirmPassword = txtConfirmPassword.Text;

            // Step 2: Pass model to repository
            if (UserRepository.Create(newUser, confirmPassword, out string error))
            {
                // Successful registration; newUser.UserID is now populated!
                Response.Redirect("Login.aspx");
            }
            else
            {
                // Display validation or database error
                lblErrorMessage.Text = error;
            }
        }
    }
}
```

### B. Sign In Page (`Login.aspx.cs`)
```csharp
using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.User
{
    public partial class Login : Page
    {
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;

            // Step 1: Call repository and receive populated UserLogin model
            if (UserRepository.Login(email, password, out UserLogin user, out string error))
            {
                // Step 2: Store user data in Session from the model
                Session["UserID"] = user.UserID;
                Session["UserEmail"] = user.Email;
                Session["UserName"] = $"{user.FirstName} {user.LastName}";

                // Step 3: Redirect to home or dashboard
                Response.Redirect("~/PortfolioTemplate.aspx");
            }
            else
            {
                // Display login failure
                lblErrorMessage.Text = error;
            }
        }
    }
}
```

---

## 8. Sequential Documentation Index
- `01_Models_Guide.md`: Model definition, properties, and constructors.
- `02_UserRepository_Guide.md`: User repository, model data flow, registration with transactions, and login verification.
