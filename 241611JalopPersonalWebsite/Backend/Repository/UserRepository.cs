using System;
using _241611JalopPersonalWebsite.Backend.Common;
using System.Collections.Generic;
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

            if (!InputSafety.ValidateAccountFields(user.FirstName, user.LastName, user.Email, out errorMessage)) return false;

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_RegisterUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = user.Email.Trim();
                        cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 255).Value = HashPassword(user.Password);
                        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = user.FirstName.Trim();
                        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = user.LastName.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newUserId))
                        {
                            user.UserID = newUserId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to generate new user ID.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = AccountWriteError(ex);
                return false;
            }
        }

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetUserByEmail", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
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
                            string dbPasswordHash = (reader.GetString(reader.GetOrdinal("PasswordHash")) ?? string.Empty).Trim();
                            string role = reader.IsDBNull(reader.GetOrdinal("Role")) ? "User" : reader.GetString(reader.GetOrdinal("Role"));
                            bool isActive = reader.GetBoolean(reader.GetOrdinal("IsActive"));
                            DateTime createdAt = reader.IsDBNull(reader.GetOrdinal("CreatedAt")) ? DateTime.UtcNow : reader.GetDateTime(reader.GetOrdinal("CreatedAt"));
                            string firstName = reader.IsDBNull(reader.GetOrdinal("FirstName")) ? "" : reader.GetString(reader.GetOrdinal("FirstName"));
                            string lastName = reader.IsDBNull(reader.GetOrdinal("LastName")) ? "" : reader.GetString(reader.GetOrdinal("LastName"));

                            if (!isActive)
                            {
                                errorMessage = "Your account has been deactivated. Please contact an administrator.";
                                return false;
                            }

                            bool passwordMatches = PasswordSecurity.Verify(password, dbPasswordHash, out bool needsUpgrade);

                            if (!passwordMatches)
                            {
                                errorMessage = "Invalid email or password.";
                                return false;
                            }

                            reader.Close();
                            if (needsUpgrade)
                            {
                                string upgraded = HashPassword(password);
                                using (var upgrade = new SqlCommand("UPDATE dbo.Users SET PasswordHash=@New WHERE UserID=@ID AND PasswordHash=@Old AND IsActive=1; SELECT @@ROWCOUNT;", conn))
                                {
                                    upgrade.Parameters.Add("@New", SqlDbType.NVarChar,255).Value = upgraded;
                                    upgrade.Parameters.Add("@Old", SqlDbType.NVarChar,255).Value = dbPasswordHash;
                                    upgrade.Parameters.Add("@ID", SqlDbType.Int).Value = userId;
                                    if (Convert.ToInt32(upgrade.ExecuteScalar()) != 1) { errorMessage = "Account changed. Please sign in again."; return false; }
                                }
                                dbPasswordHash = upgraded;
                            }
                            authenticatedUser = new UserLogin
                            {
                                UserID = userId,
                                FirstName = firstName,
                                LastName = lastName,
                                Email = dbEmail,
                                AuthenticationStamp = dbPasswordHash,
                                Role = role,
                                IsActive = isActive,
                                CreatedAt = createdAt
                            };

                            return true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
                return false;
            }
        }

       
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

                    // Step A: Verify current password
                    using (SqlCommand checkCmd = new SqlCommand("dbo.sp_GetUserPasswordHash", conn))
                    {
                        checkCmd.CommandType = CommandType.StoredProcedure;
                        checkCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        object result = checkCmd.ExecuteScalar();

                        if (result == null)
                        {
                            errorMessage = "User account not found.";
                            return false;
                        }

                        string dbHash = result.ToString();
                        bool isCurrentValid = PasswordSecurity.Verify(currentPassword, dbHash, out _);

                        if (!isCurrentValid)
                        {
                            errorMessage = "Incorrect current password.";
                            return false;
                        }
                    }

                    // Step B: Update to new hashed password
                    using (SqlCommand updateCmd = new SqlCommand("dbo.sp_UpdateUserPassword", conn))
                    {
                        updateCmd.CommandType = CommandType.StoredProcedure;
                        updateCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        updateCmd.Parameters.Add("@NewPasswordHash", SqlDbType.NVarChar, 255).Value = HashPassword(newPassword);

                        int rows = DatabaseConnection.ExecuteNonQueryCount(updateCmd);
                        if (rows > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to update password.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
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

                    using (SqlCommand updateCmd = new SqlCommand("dbo.sp_UpdateUserEmail", conn))
                    {
                        updateCmd.CommandType = CommandType.StoredProcedure;
                        updateCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        updateCmd.Parameters.Add("@NewEmail", SqlDbType.NVarChar, 255).Value = newEmail.Trim();

                        int rows = DatabaseConnection.ExecuteNonQueryCount(updateCmd);
                        return rows > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
                return false;
            }
        }

        // =========================================================================
        // ADMIN METHODS
        // =========================================================================

        public static List<UserLogin> GetUsersPage(string search, string status, string role,
            int page, int pageSize, out int total, out string error)
        {
            total = 0;
            error = string.Empty;
            var users = new List<UserLogin>();
            search = search?.Trim();
            if ((search?.Length ?? 0) > 100) { error = "Search must be 100 characters or fewer."; return users; }
            pageSize = Math.Max(1, Math.Min(pageSize, 100));
            string filter = @" FROM dbo.Users u LEFT JOIN dbo.UserProfiles p ON p.UserID=u.UserID
                WHERE (@Search IS NULL OR u.Email LIKE @Search ESCAPE '~' OR
                    p.FirstName LIKE @Search ESCAPE '~' OR p.LastName LIKE @Search ESCAPE '~' OR
                    (p.FirstName+N' '+p.LastName) LIKE @Search ESCAPE '~')
                  AND (@Status='' OR (@Status='active' AND u.IsActive=1) OR (@Status='inactive' AND u.IsActive=0))
                  AND (@Role='' OR u.Role=@Role)";
            try
            {
                using (var conn = DatabaseConnection.GetConnection())
                using (var cmd = new SqlCommand(@"DECLARE @Total int=(SELECT COUNT(*)" + filter + @");
                    DECLARE @Pages int=CASE WHEN @Total=0 THEN 1 ELSE ((@Total-1)/@Size)+1 END;
                    DECLARE @SafePage int=CASE WHEN @Page<1 THEN 1 WHEN @Page>@Pages THEN @Pages ELSE @Page END;
                    SELECT @Total;
                    SELECT u.UserID,u.Email,u.Role,u.IsActive,u.CreatedAt,
                        COALESCE(p.FirstName,N'') FirstName,COALESCE(p.LastName,N'') LastName" + filter + @"
                    ORDER BY u.CreatedAt DESC,u.UserID DESC
                    OFFSET CONVERT(bigint,@SafePage-1)*@Size ROWS FETCH NEXT @Size ROWS ONLY;", conn))
                {
                    string pattern = string.IsNullOrEmpty(search) ? null : "%" + search.Replace("~", "~~").Replace("%", "~%").Replace("_", "~_").Replace("[", "~[") + "%";
                    cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 210).Value = (object)pattern ?? DBNull.Value;
                    cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = status ?? "";
                    cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = string.IsNullOrEmpty(role) ? "" : string.Equals(role,"admin",StringComparison.OrdinalIgnoreCase) ? "Admin" : "User";
                    cmd.Parameters.Add("@Page", SqlDbType.Int).Value = page;
                    cmd.Parameters.Add("@Size", SqlDbType.Int).Value = pageSize;
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read()) throw new InvalidOperationException("Missing user count.");
                        total = reader.GetInt32(0);
                        if (!reader.NextResult()) throw new InvalidOperationException("Missing user page.");
                        while (reader.Read()) users.Add(new UserLogin {
                            UserID=reader.GetInt32(0), Email=reader.GetString(1), Role=reader.GetString(2),
                            IsActive=reader.GetBoolean(3), CreatedAt=reader.GetDateTime(4),
                            FirstName=reader.GetString(5), LastName=reader.GetString(6) });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("User directory read failed: {0}", ex);
                users.Clear(); total=0;
                error = "User accounts could not be loaded. Try searching again or reset the filters.";
            }
            return users;
        }

        public static List<UserLogin> GetAllUsers(
            string searchKeyword, 
            string statusFilter, 
            string roleFilter, 
            out string errorMessage)
        {
            errorMessage = string.Empty;
            List<UserLogin> userList = new List<UserLogin>();

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetAllUsers", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@SearchKeyword", SqlDbType.NVarChar, 100).Value = 
                            string.IsNullOrWhiteSpace(searchKeyword) ? (object)DBNull.Value : searchKeyword.Trim();
                        cmd.Parameters.Add("@StatusFilter", SqlDbType.NVarChar, 20).Value = 
                            string.IsNullOrWhiteSpace(statusFilter) ? (object)DBNull.Value : statusFilter.Trim();
                        cmd.Parameters.Add("@RoleFilter", SqlDbType.NVarChar, 20).Value = 
                            string.IsNullOrWhiteSpace(roleFilter) ? (object)DBNull.Value : roleFilter.Trim();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                userList.Add(new UserLogin
                                {
                                    UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                    Email = reader.GetString(reader.GetOrdinal("Email")),
                                    Role = reader.IsDBNull(reader.GetOrdinal("Role")) ? "User" : reader.GetString(reader.GetOrdinal("Role")),
                                    IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                                    CreatedAt = reader.IsDBNull(reader.GetOrdinal("CreatedAt")) ? DateTime.UtcNow : reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                                    FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                                    LastName = reader.GetString(reader.GetOrdinal("LastName"))
                                });
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
            }

            return userList;
        }

        public static UserLogin GetUserById(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetUserById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new UserLogin
                                {
                                    UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                                    Email = reader.GetString(reader.GetOrdinal("Email")),
                                    Role = reader.IsDBNull(reader.GetOrdinal("Role")) ? "User" : reader.GetString(reader.GetOrdinal("Role")),
                                    IsActive = reader.GetBoolean(reader.GetOrdinal("IsActive")),
                                    CreatedAt = reader.IsDBNull(reader.GetOrdinal("CreatedAt")) ? DateTime.UtcNow : reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                                    FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                                    LastName = reader.GetString(reader.GetOrdinal("LastName"))
                                };
                            }
                            else
                            {
                                errorMessage = "User account not found.";
                                return null;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
                return null;
            }
        }

        public static bool ToggleUserStatus(int userId, bool isActive, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return false;
            }

            return ChangeAccount(userId, null, isActive, false, (conn, transaction) =>
            {
                using (var cmd = new SqlCommand("dbo.sp_ToggleUserStatus", conn, transaction))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = isActive;
                    return DatabaseConnection.ExecuteNonQueryCount(cmd) > 0;
                }
            }, out errorMessage);
        }

        public static bool UpdateUserRole(int userId, string newRole, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(newRole) || (newRole != "Admin" && newRole != "User"))
            {
                errorMessage = "Role must be either 'Admin' or 'User'.";
                return false;
            }

            return ChangeAccount(userId, newRole, null, false, (conn, transaction) =>
            {
                using (var cmd = new SqlCommand("dbo.sp_UpdateUserRole", conn, transaction))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                    cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = newRole;
                    return DatabaseConnection.ExecuteNonQueryCount(cmd) > 0;
                }
            }, out errorMessage);
        }

        public static bool AdminCreateUser(
            string firstName,
            string lastName,
            string email,
            string password,
            string role,
            bool isActive,
            out string errorMessage)
        {
            errorMessage = string.Empty;

            if (!InputSafety.ValidateAccountFields(firstName, lastName, email, out errorMessage)) return false;

            if (string.IsNullOrWhiteSpace(password) || password.Length < 6)
            {
                errorMessage = "Password must be at least 6 characters long.";
                return false;
            }

            string targetRole = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) ? "Admin" : "User";

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_AdminCreateUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email.Trim();
                        cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 255).Value = HashPassword(password);
                        cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = targetRole;
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = isActive;
                        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = firstName.Trim();
                        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = lastName.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newUserId))
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to create user record.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = AccountWriteError(ex);
                return false;
            }
        }

        public static bool AdminUpdateUser(
            int userId,
            string firstName,
            string lastName,
            string email,
            string role,
            bool isActive,
            out string errorMessage, string newPassword = null)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return false;
            }

            if (!InputSafety.ValidateAccountFields(firstName, lastName, email, out errorMessage)) return false;

            string targetRole = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) ? "Admin" : "User";

            if (!string.IsNullOrEmpty(newPassword) && newPassword.Length < 6)
            { errorMessage = "New password must be at least 6 characters."; return false; }
            string newHash = string.IsNullOrEmpty(newPassword) ? null : HashPassword(newPassword);

            return ChangeAccount(userId, targetRole, isActive, false, (conn, transaction) =>
            {
                using (var cmd = new SqlCommand("dbo.sp_AdminUpdateUser", conn, transaction))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                    cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email.Trim();
                    cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = targetRole;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = isActive;
                    cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = firstName.Trim();
                    cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = lastName.Trim();
                    if (DatabaseConnection.ExecuteNonQueryCount(cmd) <= 0) return false;
                }
                if (newHash != null)
                    using (var password = new SqlCommand("dbo.sp_AdminResetPassword", conn, transaction))
                    {
                        password.CommandType=CommandType.StoredProcedure;
                        password.Parameters.Add("@UserID",SqlDbType.Int).Value=userId;
                        password.Parameters.Add("@NewPasswordHash",SqlDbType.NVarChar,255).Value=newHash;
                        if (DatabaseConnection.ExecuteNonQueryCount(password) <= 0) return false;
                    }
                return true;
            }, out errorMessage);
        }

        public static bool AdminResetPassword(int userId, string newPassword, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(newPassword) || newPassword.Length < 6)
            {
                errorMessage = "New password must be at least 6 characters long.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_AdminResetPassword", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        cmd.Parameters.Add("@NewPasswordHash", SqlDbType.NVarChar, 255).Value = HashPassword(newPassword);

                        int rows = DatabaseConnection.ExecuteNonQueryCount(cmd);
                        if (rows > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "User record not found.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
                return false;
            }
        }

        public static bool DeleteUser(int userId, out string errorMessage, string applicationRoot = null)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return false;
            }

            string imagePath = null;
            bool deleted = ChangeAccount(userId, null, null, true, (conn, transaction) =>
            {
                using (var image = new SqlCommand("SELECT ProfileImagePath FROM dbo.UserProfiles WITH (UPDLOCK,HOLDLOCK) WHERE UserID=@ID", conn, transaction))
                {
                    image.Parameters.Add("@ID", SqlDbType.Int).Value = userId;
                    imagePath = image.ExecuteScalar() as string;
                }
                using (var cmd = new SqlCommand("dbo.sp_DeleteUser", conn, transaction))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                    return DatabaseConnection.ExecuteNonQueryCount(cmd) > 0;
                }
            }, out errorMessage);
            if (deleted && !string.IsNullOrWhiteSpace(imagePath))
            {
                try
                {
                    // Never remove a file still referenced by another profile. Only
                    // clean disk after the database transaction has committed.
                    using (var conn = DatabaseConnection.GetConnection())
                    using (var references = new SqlCommand("SELECT COUNT(*) FROM dbo.UserProfiles WHERE ProfileImagePath=@Path", conn))
                    {
                        references.Parameters.Add("@Path", SqlDbType.NVarChar, 500).Value = imagePath;
                        conn.Open();
                        if (Convert.ToInt32(references.ExecuteScalar()) > 0) return true;
                    }
                    string root = applicationRoot ?? System.Web.Hosting.HostingEnvironment.ApplicationPhysicalPath;
                    if (!ProfileImages.TryDeleteStored(imagePath, root))
                        errorMessage = "Account deleted, but its photo could not be removed from storage. Ask the server administrator to run the orphaned-image cleanup tool.";
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("Deleted image reference check failed: {0}", ex);
                    errorMessage = "Account deleted, but photo cleanup could not be completed. Ask the server administrator to run the orphaned-image cleanup tool.";
                }
            }
            return deleted;
        }

        // All application paths that can remove an active administrator use the
        // same locked transaction, including account settings and separate role/status actions.
        private static bool ChangeAccount(int userId, string nextRole, bool? nextActive, bool deleting,
            Func<SqlConnection, SqlTransaction, bool> change, out string errorMessage)
        {
            errorMessage = string.Empty;
            int actorId = SessionSecurity.CurrentUser()?.UserID ?? 0;
            try
            {
                using (var conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();
                    using (var transaction = conn.BeginTransaction(IsolationLevel.Serializable))
                    {
                        // Lock the admin set before individual rows, in the same order
                        // for every operation. Concurrent demotions cannot both pass.
                        int adminCount = 0;
                        using (var admins = new SqlCommand("SELECT UserID FROM dbo.Users WITH (UPDLOCK,HOLDLOCK) WHERE Role=N'Admin' AND IsActive=1 ORDER BY UserID", conn, transaction))
                        using (var reader = admins.ExecuteReader()) while (reader.Read()) adminCount++;
                        string oldRole;
                        bool oldActive;
                        using (var target = new SqlCommand("SELECT Role,IsActive FROM dbo.Users WITH (UPDLOCK,HOLDLOCK) WHERE UserID=@ID", conn, transaction))
                        {
                            target.Parameters.Add("@ID", SqlDbType.Int).Value = userId;
                            using (var reader = target.ExecuteReader())
                            {
                                if (!reader.Read()) { errorMessage = "User record not found."; return false; }
                                oldRole = Convert.ToString(reader["Role"]);
                                oldActive = Convert.ToBoolean(reader["IsActive"]);
                            }
                        }
                        if (actorId == userId && (deleting || nextActive == false))
                        { errorMessage = "You cannot deactivate or delete your own active session."; return false; }
                        bool removesAdmin = deleting || !(nextActive ?? oldActive) ||
                            !string.Equals(nextRole ?? oldRole, "Admin", StringComparison.OrdinalIgnoreCase);
                        if (oldActive && string.Equals(oldRole, "Admin", StringComparison.OrdinalIgnoreCase) && removesAdmin && adminCount <= 1)
                        { errorMessage = "Keep at least one active administrator. Assign another administrator before making this change."; return false; }
                        if (!change(conn, transaction)) { errorMessage = "User record not found."; return false; }
                        transaction.Commit();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Protected account change failed: {0}", ex);
                errorMessage = AccountWriteError(ex);
                return false;
            }
        }

        private static string AccountWriteError(Exception error)
        {
            var sql = error as SqlException;
            if (sql != null)
                foreach (SqlError item in sql.Errors)
                    if (item.Number == 2601 || item.Number == 2627 ||
                        (item.Number == 50000 && item.Message.IndexOf("email", StringComparison.OrdinalIgnoreCase) >= 0 &&
                         (item.Message.IndexOf("already", StringComparison.OrdinalIgnoreCase) >= 0 || item.Message.IndexOf("exists", StringComparison.OrdinalIgnoreCase) >= 0)))
                        return "An account with this email already exists. Sign in or use another email address.";
            return "Account details could not be saved. Please try again.";
        }

        public static string HashPassword(string plainTextPassword) => PasswordSecurity.Hash(plainTextPassword);
    }
}
