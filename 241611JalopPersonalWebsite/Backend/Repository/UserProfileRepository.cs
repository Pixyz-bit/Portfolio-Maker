using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Backend.Common;
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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_CreateUserProfile", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_UpdateUserProfile", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

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

                        int rowsAffected = DatabaseConnection.ExecuteNonQueryCount(cmd);
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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetUserProfileByUserId", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetUserProfileById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
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
        // 5. GET ALL PUBLIC PORTFOLIOS (Active users for public showcase)
        // =========================================================================
        public static List<PublicPortfolioItem> GetPublicPortfolios(string searchKeyword, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<PublicPortfolioItem> list = new List<PublicPortfolioItem>();

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string sql = @"
                        SELECT u.UserID, u.Email, u.CreatedAt,
                               ISNULL(p.FirstName, '') AS FirstName,
                               ISNULL(p.LastName, '') AS LastName,
                               ISNULL(p.Address, '') AS Address,
                               ISNULL(p.Description, '') AS Description,
                               ISNULL(p.ProfileImagePath, '') AS ProfileImagePath
                        FROM dbo.Users u
                        LEFT JOIN dbo.UserProfiles p ON u.UserID = p.UserID
                        WHERE u.IsActive = 1
                        ORDER BY u.UserID DESC;
                    ";

                    Dictionary<int, PublicPortfolioItem> itemDict = new Dictionary<int, PublicPortfolioItem>();

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int uId = reader.GetInt32(reader.GetOrdinal("UserID"));
                            var item = new PublicPortfolioItem
                            {
                                UserID = uId,
                                Email = reader.GetString(reader.GetOrdinal("Email")),
                                CreatedAt = reader.IsDBNull(reader.GetOrdinal("CreatedAt")) ? DateTime.UtcNow : reader.GetDateTime(reader.GetOrdinal("CreatedAt")),
                                FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                                LastName = reader.GetString(reader.GetOrdinal("LastName")),
                                Address = reader.GetString(reader.GetOrdinal("Address")),
                                Description = reader.GetString(reader.GetOrdinal("Description")),
                                ProfileImagePath = reader.GetString(reader.GetOrdinal("ProfileImagePath")),
                                ObfuscatedToken = UrlObfuscator.EncodeUserId(uId)
                            };

                            itemDict[uId] = item;
                            list.Add(item);
                        }
                    }

                    // Retrieve skills for these users
                    if (itemDict.Count > 0)
                    {
                        string skillsSql = @"
                            SELECT s.UserID, s.SkillName
                            FROM dbo.Skills s
                            INNER JOIN dbo.Users u ON s.UserID = u.UserID
                            WHERE u.IsActive = 1
                            ORDER BY s.SkillID ASC;
                        ";

                        using (SqlCommand skillCmd = new SqlCommand(skillsSql, conn))
                        using (SqlDataReader skillReader = skillCmd.ExecuteReader())
                        {
                            while (skillReader.Read())
                            {
                                int sUserId = skillReader.GetInt32(skillReader.GetOrdinal("UserID"));
                                string sName = skillReader.GetString(skillReader.GetOrdinal("SkillName"));
                                if (itemDict.TryGetValue(sUserId, out var pItem))
                                {
                                    if (!string.IsNullOrWhiteSpace(sName))
                                    {
                                        pItem.Skills.Add(sName);
                                    }
                                }
                            }
                        }
                    }

                    // Filter in memory if searchKeyword provided
                    if (!string.IsNullOrWhiteSpace(searchKeyword))
                    {
                        string kw = searchKeyword.Trim().ToLowerInvariant();
                        list = list.FindAll(i =>
                            i.FullName.ToLowerInvariant().Contains(kw) ||
                            i.Email.ToLowerInvariant().Contains(kw) ||
                            i.Address.ToLowerInvariant().Contains(kw) ||
                            i.Description.ToLowerInvariant().Contains(kw) ||
                            i.Skills.Exists(s => s.ToLowerInvariant().Contains(kw))
                        );
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Error retrieving public portfolios: {ex.Message}";
            }

            return list;
        }

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
