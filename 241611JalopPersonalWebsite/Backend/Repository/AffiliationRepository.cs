using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class AffiliationRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Affiliation
        // =========================================================================
        public static bool Create(Affiliation affiliation, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliation == null)
            {
                errorMessage = "Affiliation details cannot be null.";
                return false;
            }

            if (affiliation.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.OrganizationName))
            {
                errorMessage = "Organization name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.Position))
            {
                errorMessage = "Position / Role is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.StartYear))
            {
                errorMessage = "Start Year is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_InsertAffiliation", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = affiliation.UserID;
                        cmd.Parameters.Add("@OrganizationName", SqlDbType.NVarChar, 150).Value = affiliation.OrganizationName.Trim();
                        cmd.Parameters.Add("@Position", SqlDbType.NVarChar, 100).Value = affiliation.Position.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = affiliation.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(affiliation.EndYear) ? (object)DBNull.Value : affiliation.EndYear.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            affiliation.AffiliationID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated AffiliationID.";
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
        // 2. READ ALL: Get All Affiliations by UserID
        // =========================================================================
        public static List<Affiliation> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Affiliation> list = new List<Affiliation>();

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetAffiliationsByUserId", conn))
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
        // 3. READ ONE: Get Single Affiliation by AffiliationID
        // =========================================================================
        public static Affiliation GetById(int affiliationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliationId <= 0)
            {
                errorMessage = "Invalid AffiliationID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetAffiliationById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@AffiliationID", SqlDbType.Int).Value = affiliationId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Affiliation not found.";
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
        // 4. UPDATE: Update Existing Affiliation
        // =========================================================================
        public static bool Update(Affiliation affiliation, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliation == null)
            {
                errorMessage = "Affiliation details cannot be null.";
                return false;
            }

            if (affiliation.AffiliationID <= 0)
            {
                errorMessage = "Invalid AffiliationID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.OrganizationName))
            {
                errorMessage = "Organization name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.Position))
            {
                errorMessage = "Position / Role is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(affiliation.StartYear))
            {
                errorMessage = "Start Year is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_UpdateAffiliation", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@AffiliationID", SqlDbType.Int).Value = affiliation.AffiliationID;
                        cmd.Parameters.Add("@OrganizationName", SqlDbType.NVarChar, 150).Value = affiliation.OrganizationName.Trim();
                        cmd.Parameters.Add("@Position", SqlDbType.NVarChar, 100).Value = affiliation.Position.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = affiliation.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(affiliation.EndYear) ? (object)DBNull.Value : affiliation.EndYear.Trim();

                        int rowsAffected = DatabaseConnection.ExecuteNonQueryCount(cmd);
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Affiliation record not found to update.";
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
        // 5. DELETE: Remove Affiliation by AffiliationID
        // =========================================================================
        public static bool Delete(int affiliationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (affiliationId <= 0)
            {
                errorMessage = "Invalid AffiliationID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_DeleteAffiliation", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@AffiliationID", SqlDbType.Int).Value = affiliationId;

                        int rowsAffected = DatabaseConnection.ExecuteNonQueryCount(cmd);
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Affiliation record not found to delete.";
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
        // HELPER: Map SqlDataReader to Affiliation Model
        // =========================================================================
        private static Affiliation MapFromReader(SqlDataReader reader)
        {
            return new Affiliation
            {
                AffiliationID = reader.GetInt32(reader.GetOrdinal("AffiliationID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                OrganizationName = reader.GetString(reader.GetOrdinal("OrganizationName")),
                Position = reader.GetString(reader.GetOrdinal("Position")),
                StartYear = reader.GetString(reader.GetOrdinal("StartYear")),
                EndYear = reader.IsDBNull(reader.GetOrdinal("EndYear")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("EndYear")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
