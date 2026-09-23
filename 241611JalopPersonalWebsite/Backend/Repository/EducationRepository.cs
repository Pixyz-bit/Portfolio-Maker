using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class EducationRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Education Record
        // =========================================================================
        public static bool Create(Education education, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (education == null)
            {
                errorMessage = "Education details cannot be null.";
                return false;
            }

            if (education.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.CourseName))
            {
                errorMessage = "Course / Degree name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.University))
            {
                errorMessage = "University / School name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.StartYear))
            {
                errorMessage = "Start Year is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_InsertEducation", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = education.UserID;
                        cmd.Parameters.Add("@CourseName", SqlDbType.NVarChar, 150).Value = education.CourseName.Trim();
                        cmd.Parameters.Add("@University", SqlDbType.NVarChar, 150).Value = education.University.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = education.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(education.EndYear) ? (object)DBNull.Value : education.EndYear.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            education.EducationID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated EducationID.";
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
        // 2. READ ALL: Get All Education Records by UserID
        // =========================================================================
        public static List<Education> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Education> list = new List<Education>();

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetEducationsByUserId", conn))
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
        // 3. READ ONE: Get Single Education Record by EducationID
        // =========================================================================
        public static Education GetById(int educationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (educationId <= 0)
            {
                errorMessage = "Invalid EducationID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetEducationById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@EducationID", SqlDbType.Int).Value = educationId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Education record not found.";
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
        // 4. UPDATE: Update Existing Education Record
        // =========================================================================
        public static bool Update(Education education, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (education == null)
            {
                errorMessage = "Education details cannot be null.";
                return false;
            }

            if (education.EducationID <= 0)
            {
                errorMessage = "Invalid EducationID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.CourseName))
            {
                errorMessage = "Course / Degree name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.University))
            {
                errorMessage = "University / School name is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(education.StartYear))
            {
                errorMessage = "Start Year is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_UpdateEducation", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@EducationID", SqlDbType.Int).Value = education.EducationID;
                        cmd.Parameters.Add("@CourseName", SqlDbType.NVarChar, 150).Value = education.CourseName.Trim();
                        cmd.Parameters.Add("@University", SqlDbType.NVarChar, 150).Value = education.University.Trim();
                        cmd.Parameters.Add("@StartYear", SqlDbType.NVarChar, 10).Value = education.StartYear.Trim();
                        cmd.Parameters.Add("@EndYear", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(education.EndYear) ? (object)DBNull.Value : education.EndYear.Trim();

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Education record not found to update.";
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
        // 5. DELETE: Remove Education Record by EducationID
        // =========================================================================
        public static bool Delete(int educationId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (educationId <= 0)
            {
                errorMessage = "Invalid EducationID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_DeleteEducation", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@EducationID", SqlDbType.Int).Value = educationId;

                        int rowsAffected = cmd.ExecuteNonQuery();
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Education record not found to delete.";
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
        // HELPER: Map SqlDataReader to Education Model
        // =========================================================================
        private static Education MapFromReader(SqlDataReader reader)
        {
            return new Education
            {
                EducationID = reader.GetInt32(reader.GetOrdinal("EducationID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                CourseName = reader.GetString(reader.GetOrdinal("CourseName")),
                University = reader.GetString(reader.GetOrdinal("University")),
                StartYear = reader.GetString(reader.GetOrdinal("StartYear")),
                EndYear = reader.IsDBNull(reader.GetOrdinal("EndYear")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("EndYear")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
