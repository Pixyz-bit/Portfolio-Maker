using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class SocialLinkRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New SocialLink
        // =========================================================================
        public static bool Create(SocialLink link, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (link == null)
            {
                errorMessage = "Social link details cannot be null.";
                return false;
            }

            if (link.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(link.SocialLinkName))
            {
                errorMessage = "Social link name is required (e.g., GitHub, LinkedIn).";
                return false;
            }

            if (string.IsNullOrWhiteSpace(link.Link))
            {
                errorMessage = "URL link is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_InsertSocialLink", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = link.UserID;
                        cmd.Parameters.Add("@SocialLinkName", SqlDbType.NVarChar, 50).Value = link.SocialLinkName.Trim();
                        cmd.Parameters.Add("@Link", SqlDbType.NVarChar, 500).Value = link.Link.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            link.SocialLinkID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated SocialLinkID.";
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
        // 2. READ ALL: Get All SocialLinks by UserID
        // =========================================================================
        public static List<SocialLink> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<SocialLink> list = new List<SocialLink>();

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetSocialLinksByUserId", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
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
        // 3. READ ONE: Get Single SocialLink by SocialLinkID
        // =========================================================================
        public static SocialLink GetById(int socialLinkId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (socialLinkId <= 0)
            {
                errorMessage = "Invalid SocialLinkID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetSocialLinkById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@SocialLinkID", SqlDbType.Int).Value = socialLinkId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Social link not found.";
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
        // 4. UPDATE: Update Existing SocialLink
        // =========================================================================
        public static bool Update(SocialLink link, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (link == null)
            {
                errorMessage = "Social link details cannot be null.";
                return false;
            }

            if (link.SocialLinkID <= 0)
            {
                errorMessage = "Invalid SocialLinkID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(link.SocialLinkName))
            {
                errorMessage = "Social link name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(link.Link))
            {
                errorMessage = "URL link is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_UpdateSocialLink", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@SocialLinkID", SqlDbType.Int).Value = link.SocialLinkID;
                        cmd.Parameters.Add("@SocialLinkName", SqlDbType.NVarChar, 50).Value = link.SocialLinkName.Trim();
                        cmd.Parameters.Add("@Link", SqlDbType.NVarChar, 500).Value = link.Link.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Social link not found to update.";
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
        // 5. DELETE: Remove SocialLink by SocialLinkID
        // =========================================================================
        public static bool Delete(int socialLinkId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (socialLinkId <= 0)
            {
                errorMessage = "Invalid SocialLinkID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_DeleteSocialLink", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@SocialLinkID", SqlDbType.Int).Value = socialLinkId;

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Social link not found to delete.";
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
        // HELPER: Map SqlDataReader to SocialLink Model
        // =========================================================================
        private static SocialLink MapFromReader(SqlDataReader reader)
        {
            return new SocialLink
            {
                SocialLinkID = reader.GetInt32(reader.GetOrdinal("SocialLinkID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                SocialLinkName = reader.GetString(reader.GetOrdinal("SocialLinkName")),
                Link = reader.GetString(reader.GetOrdinal("Link")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
