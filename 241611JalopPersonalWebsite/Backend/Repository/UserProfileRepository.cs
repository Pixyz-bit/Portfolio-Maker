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

            if (!InputSafety.ValidateNames(profile.FirstName, profile.LastName, out errorMessage)) return false;

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
                            SetPortfolioVisibility(profile.UserID, profile.IsPublic, out _);
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
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
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

            if (!InputSafety.ValidateNames(profile.FirstName, profile.LastName, out errorMessage)) return false;

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
                            SetPortfolioVisibility(profile.UserID, profile.IsPublic, out _);
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
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
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
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
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
                System.Diagnostics.Trace.TraceError("Database operation failed: {0}", ex);
                errorMessage = "The database operation could not be completed. Please try again.";
                return null;
            }
        }

        // =========================================================================
        // HELPER: Safely Map DataReader to UserProfile Model
        // =========================================================================
        // 5. GET ALL PUBLIC PORTFOLIOS (Active users for public showcase)
        // =========================================================================
        public static List<PublicPortfolioItem> GetPublicPortfolios(string searchKeyword, out string errorMessage)
            => GetPublicPortfolios(searchKeyword, 1, 12, out _, out errorMessage);

        public static List<PublicPortfolioItem> GetPublicPortfolios(string searchKeyword, int page, int pageSize, out int total, out string errorMessage)
        {
            total = 0; errorMessage = string.Empty;
            var list = new List<PublicPortfolioItem>();
            var byId = new Dictionary<int, PublicPortfolioItem>();
            string keyword = (searchKeyword ?? string.Empty).Trim();
            if (keyword.Length > 255) keyword = keyword.Substring(0, 255);
            string pattern = "%" + keyword.Replace("~", "~~").Replace("%", "~%").Replace("_", "~_").Replace("[", "~[") + "%";
            const string filter = @"u.IsActive=1 AND ISNULL(p.IsPublic,1)=1 AND
                (@Empty=1 OR CONCAT(p.FirstName,N' ',p.LastName) LIKE @Search ESCAPE '~' OR u.Email LIKE @Search ESCAPE '~'
                OR p.Address LIKE @Search ESCAPE '~' OR p.Description LIKE @Search ESCAPE '~'
                OR EXISTS(SELECT 1 FROM dbo.Skills k WHERE k.UserID=u.UserID AND k.SkillName LIKE @Search ESCAPE '~'))";
            string sql = @"DECLARE @Total INT=(SELECT COUNT(*) FROM dbo.Users u LEFT JOIN dbo.UserProfiles p ON p.UserID=u.UserID WHERE " + filter + @");
                DECLARE @LastPage INT=CASE WHEN @Total=0 THEN 1 ELSE (@Total-1)/@Size+1 END;
                IF @Page>@LastPage SET @Page=@LastPage;
                SELECT @Total;
                SELECT u.UserID,u.Email,u.CreatedAt,ISNULL(p.FirstName,N'') FirstName,ISNULL(p.LastName,N'') LastName,
                    ISNULL(p.Address,N'') Address,ISNULL(p.Description,N'') Description,ISNULL(p.ProfileImagePath,N'') ProfileImagePath
                INTO #Page FROM dbo.Users u LEFT JOIN dbo.UserProfiles p ON p.UserID=u.UserID WHERE " + filter + @"
                ORDER BY u.UserID DESC OFFSET (@Page-1)*@Size ROWS FETCH NEXT @Size ROWS ONLY;
                SELECT * FROM #Page ORDER BY UserID DESC;
                SELECT s.UserID,s.SkillName FROM dbo.Skills s INNER JOIN #Page p ON p.UserID=s.UserID ORDER BY s.SkillID;";
            try
            {
                using (var conn = DatabaseConnection.GetConnection())
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 1024).Value = pattern;
                    cmd.Parameters.Add("@Empty", SqlDbType.Bit).Value = keyword.Length == 0;
                    cmd.Parameters.Add("@Page", SqlDbType.Int).Value = Math.Max(1, page);
                    cmd.Parameters.Add("@Size", SqlDbType.Int).Value = Math.Max(1, Math.Min(50, pageSize));
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read()) total = reader.GetInt32(0);
                        reader.NextResult();
                        while (reader.Read())
                        {
                            int id = (int)reader["UserID"];
                            var item = new PublicPortfolioItem { UserID=id, Email=(string)reader["Email"], CreatedAt=(DateTime)reader["CreatedAt"],
                                FirstName=(string)reader["FirstName"], LastName=(string)reader["LastName"], Address=(string)reader["Address"],
                                Description=(string)reader["Description"], ProfileImagePath=(string)reader["ProfileImagePath"], ObfuscatedToken=UrlObfuscator.EncodeUserId(id) };
                            list.Add(item); byId[id]=item;
                        }
                        reader.NextResult();
                        while (reader.Read()) if (byId.TryGetValue((int)reader["UserID"], out var item)) item.Skills.Add((string)reader["SkillName"]);
                    }
                }
            }
            catch (Exception ex) { System.Diagnostics.Trace.TraceError("Directory search failed: {0}", ex); errorMessage="Portfolios could not be loaded. Please try again."; }
            return list;
        }

        public static bool TogglePortfolioVisibility(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            try
            {
                using (var conn = DatabaseConnection.GetConnection())
                using (var cmd = new SqlCommand("UPDATE dbo.UserProfiles SET IsPublic=CASE WHEN IsPublic=1 THEN 0 ELSE 1 END, UpdatedAt=SYSUTCDATETIME() WHERE UserID=@ID", conn))
                {
                    cmd.Parameters.Add("@ID", SqlDbType.Int).Value=userId; conn.Open();
                    if (cmd.ExecuteNonQuery()>0) return true;
                    errorMessage="Portfolio not found.";
                }
            }
            catch (Exception ex) { System.Diagnostics.Trace.TraceError("Visibility update failed: {0}", ex); errorMessage="Visibility could not be changed. Please try again."; }
            return false;
        }

        private static bool _isPublicColumnChecked = false;

        public static void EnsureIsPublicColumnExists()
        {
            if (_isPublicColumnChecked) return;
            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();
                    string checkSql = @"
                        IF COL_LENGTH(N'dbo.UserProfiles', N'IsPublic') IS NULL
                        BEGIN
                            ALTER TABLE dbo.UserProfiles ADD IsPublic BIT NOT NULL CONSTRAINT DF_UserProfiles_IsPublic DEFAULT 1;
                        END";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
                _isPublicColumnChecked = true;
            }
            catch
            {
                // Ignore DDL failure if constrained by permissions
            }
        }

        public static bool SetPortfolioVisibility(int userId, bool isPublic, out string errorMessage)
        {
            errorMessage = string.Empty;
            if (userId <= 0)
            {
                errorMessage = "Invalid UserID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();
                    string sql = @"
                        UPDATE dbo.UserProfiles
                        SET IsPublic = @IsPublic,
                            UpdatedAt = SYSUTCDATETIME()
                        WHERE UserID = @UserID;
                    ";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.Add("@IsPublic", SqlDbType.Bit).Value = isPublic;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        int rows = cmd.ExecuteNonQuery();
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

        private static UserProfile MapProfileFromReader(SqlDataReader reader)
        {
            int isPublicOrd = -1;
            try { isPublicOrd = reader.GetOrdinal("IsPublic"); } catch { }
            bool isPublic = true;
            if (isPublicOrd >= 0 && !reader.IsDBNull(isPublicOrd))
            {
                isPublic = Convert.ToBoolean(reader.GetValue(isPublicOrd));
            }

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
                UpdatedAt = reader.GetDateTime(reader.GetOrdinal("UpdatedAt")),
                IsPublic = isPublic
            };
        }
    }
}
