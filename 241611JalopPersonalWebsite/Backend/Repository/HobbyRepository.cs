using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class HobbyRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Hobby
        // =========================================================================
        public static bool Create(Hobby hobby, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobby == null)
            {
                errorMessage = "Hobby details cannot be null.";
                return false;
            }

            if (hobby.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(hobby.HobbyName))
            {
                errorMessage = "Hobby name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_InsertHobby", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = hobby.UserID;
                        cmd.Parameters.Add("@HobbyName", SqlDbType.NVarChar, 100).Value = hobby.HobbyName.Trim();
                        cmd.Parameters.Add("@HobbyDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(hobby.HobbyDescription) ? (object)DBNull.Value : hobby.HobbyDescription.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            hobby.HobbyID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated HobbyID.";
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
        // 2. READ ALL: Get All Hobbies by UserID
        // =========================================================================
        public static List<Hobby> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Hobby> list = new List<Hobby>();

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetHobbiesByUserId", conn))
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
        // 3. READ ONE: Get Single Hobby by HobbyID
        // =========================================================================
        public static Hobby GetById(int hobbyId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobbyId <= 0)
            {
                errorMessage = "Invalid HobbyID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetHobbyById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@HobbyID", SqlDbType.Int).Value = hobbyId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Hobby not found.";
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
        // 4. UPDATE: Update Existing Hobby
        // =========================================================================
        public static bool Update(Hobby hobby, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobby == null)
            {
                errorMessage = "Hobby details cannot be null.";
                return false;
            }

            if (hobby.HobbyID <= 0)
            {
                errorMessage = "Invalid HobbyID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(hobby.HobbyName))
            {
                errorMessage = "Hobby name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_UpdateHobby", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@HobbyID", SqlDbType.Int).Value = hobby.HobbyID;
                        cmd.Parameters.Add("@HobbyName", SqlDbType.NVarChar, 100).Value = hobby.HobbyName.Trim();
                        cmd.Parameters.Add("@HobbyDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(hobby.HobbyDescription) ? (object)DBNull.Value : hobby.HobbyDescription.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Hobby record not found to update.";
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
        // 5. DELETE: Remove Hobby by HobbyID
        // =========================================================================
        public static bool Delete(int hobbyId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (hobbyId <= 0)
            {
                errorMessage = "Invalid HobbyID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_DeleteHobby", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@HobbyID", SqlDbType.Int).Value = hobbyId;

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Hobby record not found to delete.";
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
        // HELPER: Map SqlDataReader to Hobby Model
        // =========================================================================
        private static Hobby MapFromReader(SqlDataReader reader)
        {
            return new Hobby
            {
                HobbyID = reader.GetInt32(reader.GetOrdinal("HobbyID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                HobbyName = reader.GetString(reader.GetOrdinal("HobbyName")),
                HobbyDescription = reader.IsDBNull(reader.GetOrdinal("HobbyDescription")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("HobbyDescription")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
