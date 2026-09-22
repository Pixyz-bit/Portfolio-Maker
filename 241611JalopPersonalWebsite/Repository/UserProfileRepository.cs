using System;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class UserProfileRepository
    {
        
        public static bool Create(UserProfile profile, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (profile == null)
            {
                errorMessage = "Profile details cannot be null.";
                return false;
            }

            if (profile.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(profile.FirstName))
            {
                errorMessage = "First Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(profile.LastName))
            {
                errorMessage = "Last Name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string checkQuery = "SELECT COUNT(1) FROM dbo.UserProfiles WHERE UserID = @UserID";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.Add("@UserID", SqlDbType.Int).Value = profile.UserID;
                        int exists = Convert.ToInt32(checkCmd.ExecuteScalar());

                        if (exists > 0)
                        {
                            errorMessage = "A profile for this user already exists. Use Update instead.";
                            return false;
                        }
                    }

                    string insertQuery = @"
                        INSERT INTO dbo.UserProfiles 
                            (UserID, FirstName, LastName, Birthday, Address, ContactEmail, ContactNum, ProfileImagePath, Description, UpdatedAt)
                        VALUES 
                            (@UserID, @FirstName, @LastName, @Birthday, @Address, @ContactEmail, @ContactNum, @ProfileImagePath, @Description, SYSUTCDATETIME());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = profile.UserID;
                        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = profile.FirstName.Trim();
                        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = profile.LastName.Trim();

                        cmd.Parameters.Add("@Birthday", SqlDbType.Date).Value = 
                            profile.Birthday.HasValue ? (object)profile.Birthday.Value : DBNull.Value;

                        cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 255).Value = 
                            string.IsNullOrWhiteSpace(profile.Address) ? (object)DBNull.Value : profile.Address.Trim();

                        cmd.Parameters.Add("@ContactEmail", SqlDbType.NVarChar, 255).Value = 
                            string.IsNullOrWhiteSpace(profile.ContactEmail) ? (object)DBNull.Value : profile.ContactEmail.Trim();

                        cmd.Parameters.Add("@ContactNum", SqlDbType.NVarChar, 30).Value = 
                            string.IsNullOrWhiteSpace(profile.ContactNum) ? (object)DBNull.Value : profile.ContactNum.Trim();

                        cmd.Parameters.Add("@ProfileImagePath", SqlDbType.NVarChar, 500).Value = 
                            string.IsNullOrWhiteSpace(profile.ProfileImagePath) ? (object)DBNull.Value : profile.ProfileImagePath.Trim();

                        cmd.Parameters.Add("@Description", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(profile.Description) ? (object)DBNull.Value : profile.Description.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newProfileId))
                        {
                            profile.ProfileID = newProfileId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated ProfileID.";
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

        
        public static bool Update(UserProfile profile, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (profile == null)
            {
                errorMessage = "Profile details cannot be null.";
                return false;
            }

            if (profile.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(profile.FirstName))
            {
                errorMessage = "First Name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(profile.LastName))
            {
                errorMessage = "Last Name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string updateQuery = @"
                        UPDATE dbo.UserProfiles
                        SET FirstName = @FirstName,
                            LastName = @LastName,
                            Birthday = @Birthday,
                            Address = @Address,
                            ContactEmail = @ContactEmail,
                            ContactNum = @ContactNum,
                            ProfileImagePath = COALESCE(@ProfileImagePath, ProfileImagePath),
                            Description = @Description,
                            UpdatedAt = SYSUTCDATETIME()
                        WHERE UserID = @UserID;";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = profile.UserID;
                        cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = profile.FirstName.Trim();
                        cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = profile.LastName.Trim();

                        cmd.Parameters.Add("@Birthday", SqlDbType.Date).Value = 
                            profile.Birthday.HasValue ? (object)profile.Birthday.Value : DBNull.Value;

                        cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 255).Value = 
                            string.IsNullOrWhiteSpace(profile.Address) ? (object)DBNull.Value : profile.Address.Trim();

                        cmd.Parameters.Add("@ContactEmail", SqlDbType.NVarChar, 255).Value = 
                            string.IsNullOrWhiteSpace(profile.ContactEmail) ? (object)DBNull.Value : profile.ContactEmail.Trim();

                        cmd.Parameters.Add("@ContactNum", SqlDbType.NVarChar, 30).Value = 
                            string.IsNullOrWhiteSpace(profile.ContactNum) ? (object)DBNull.Value : profile.ContactNum.Trim();

                        cmd.Parameters.Add("@ProfileImagePath", SqlDbType.NVarChar, 500).Value = 
                            string.IsNullOrWhiteSpace(profile.ProfileImagePath) ? (object)DBNull.Value : profile.ProfileImagePath.Trim();

                        cmd.Parameters.Add("@Description", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(profile.Description) ? (object)DBNull.Value : profile.Description.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Profile record not found to update.";
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

       
        public static UserProfile GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (userId <= 0)
            {
                errorMessage = "Invalid UserID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT ProfileID, UserID, FirstName, LastName, Birthday, Address, 
                               ContactEmail, ContactNum, ProfileImagePath, Description, UpdatedAt
                        FROM dbo.UserProfiles
                        WHERE UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapProfileFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Profile not found.";
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
        // 4. READ: Get UserProfile by ProfileID
        // =========================================================================
        public static UserProfile GetByProfileId(int profileId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (profileId <= 0)
            {
                errorMessage = "Invalid ProfileID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT ProfileID, UserID, FirstName, LastName, Birthday, Address, 
                               ContactEmail, ContactNum, ProfileImagePath, Description, UpdatedAt
                        FROM dbo.UserProfiles
                        WHERE ProfileID = @ProfileID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@ProfileID", SqlDbType.Int).Value = profileId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapProfileFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Profile not found.";
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
        // HELPER: Safely Map DataReader to UserProfile Model
        // =========================================================================
        private static UserProfile MapProfileFromReader(SqlDataReader reader)
        {
            return new UserProfile
            {
                ProfileID = reader.GetInt32(reader.GetOrdinal("ProfileID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                LastName = reader.GetString(reader.GetOrdinal("LastName")),
                Birthday = reader.IsDBNull(reader.GetOrdinal("Birthday")) 
                    ? (DateTime?)null 
                    : reader.GetDateTime(reader.GetOrdinal("Birthday")),
                Address = reader.IsDBNull(reader.GetOrdinal("Address")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("Address")),
                ContactEmail = reader.IsDBNull(reader.GetOrdinal("ContactEmail")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("ContactEmail")),
                ContactNum = reader.IsDBNull(reader.GetOrdinal("ContactNum")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("ContactNum")),
                ProfileImagePath = reader.IsDBNull(reader.GetOrdinal("ProfileImagePath")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("ProfileImagePath")),
                Description = reader.IsDBNull(reader.GetOrdinal("Description")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("Description")),
                UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt"))
            };
        }
    }
}
