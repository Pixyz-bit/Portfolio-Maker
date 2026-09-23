using System;
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
                errorMessage = ex.Message;
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

                            string enteredPasswordHash = HashPassword(password).Trim();
                            bool passwordMatches = string.Equals(dbPasswordHash, enteredPasswordHash, StringComparison.OrdinalIgnoreCase)
                                                || string.Equals(dbPasswordHash, password.Trim(), StringComparison.Ordinal);

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
                                Email = dbEmail,
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
                errorMessage = $"Database error: {ex.Message}";
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
                        string currentHash = HashPassword(currentPassword);
                        bool isCurrentValid = string.Equals(dbHash, currentHash, StringComparison.OrdinalIgnoreCase)
                                           || string.Equals(dbHash, currentPassword, StringComparison.Ordinal);

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
                errorMessage = ex.Message;
                return false;
            }
        }

        // =========================================================================
        // ADMIN METHODS
        // =========================================================================

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
                errorMessage = $"Error retrieving user directory: {ex.Message}";
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
                errorMessage = $"Error retrieving user details: {ex.Message}";
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

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_ToggleUserStatus", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = isActive;

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
                errorMessage = $"Error changing user status: {ex.Message}";
                return false;
            }
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

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_UpdateUserRole", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = newRole;

                        int rows = DatabaseConnection.ExecuteNonQueryCount(cmd);
                        return rows > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Error updating user role: {ex.Message}";
                return false;
            }
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

            if (string.IsNullOrWhiteSpace(firstName))
            {
                errorMessage = "First Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(lastName))
            {
                errorMessage = "Last Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(email) || !Regex.IsMatch(email.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                errorMessage = "Please enter a valid email address.";
                return false;
            }

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
                errorMessage = ex.Message;
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
            out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(firstName))
            {
                errorMessage = "First Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(lastName))
            {
                errorMessage = "Last Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(email) || !Regex.IsMatch(email.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                errorMessage = "Please enter a valid email address.";
                return false;
            }

            string targetRole = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) ? "Admin" : "User";

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_AdminUpdateUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email.Trim();
                        cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = targetRole;
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = isActive;
                        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = firstName.Trim();
                        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = lastName.Trim();

                        cmd.ExecuteNonQuery();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
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
                errorMessage = $"Error resetting password: {ex.Message}";
                return false;
            }
        }

        public static bool DeleteUser(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid User ID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_DeleteUser", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        int rows = DatabaseConnection.ExecuteNonQueryCount(cmd);
                        if (rows > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "User not found or already deleted.";
                            return false;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Error deleting user: {ex.Message}";
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
