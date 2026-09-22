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
