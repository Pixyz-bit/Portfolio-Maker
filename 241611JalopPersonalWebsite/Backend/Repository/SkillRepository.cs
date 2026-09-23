using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class SkillRepository
    {
        // =========================================================================
        // 1. CREATE: Insert New Skill
        // =========================================================================
        public static bool Create(Skill skill, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skill == null)
            {
                errorMessage = "Skill details cannot be null.";
                return false;
            }

            if (skill.UserID <= 0)
            {
                errorMessage = "A valid UserID is required.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(skill.SkillName))
            {
                errorMessage = "Skill name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_InsertSkill", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = skill.UserID;
                        cmd.Parameters.Add("@SkillName", SqlDbType.NVarChar, 100).Value = skill.SkillName.Trim();
                        cmd.Parameters.Add("@SkillDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(skill.SkillDescription) ? (object)DBNull.Value : skill.SkillDescription.Trim();

                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int newId))
                        {
                            skill.SkillID = newId;
                            return true;
                        }
                        else
                        {
                            errorMessage = "Failed to retrieve generated SkillID.";
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
        // 2. READ ALL: Get All Skills by UserID
        // =========================================================================
        public static List<Skill> GetByUserId(int userId, out string errorMessage)
        {
            errorMessage = string.Empty;
            List<Skill> list = new List<Skill>();

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

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetSkillsByUserId", conn))
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
        // 3. READ ONE: Get Single Skill by SkillID
        // =========================================================================
        public static Skill GetById(int skillId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skillId <= 0)
            {
                errorMessage = "Invalid SkillID.";
                return null;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_GetSkillById", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@SkillID", SqlDbType.Int).Value = skillId;

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return MapFromReader(reader);
                            }
                            else
                            {
                                errorMessage = "Skill not found.";
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
        // 4. UPDATE: Update Existing Skill
        // =========================================================================
        public static bool Update(Skill skill, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skill == null)
            {
                errorMessage = "Skill details cannot be null.";
                return false;
            }

            if (skill.SkillID <= 0)
            {
                errorMessage = "Invalid SkillID.";
                return false;
            }

            if (string.IsNullOrWhiteSpace(skill.SkillName))
            {
                errorMessage = "Skill name is required.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_UpdateSkill", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@SkillID", SqlDbType.Int).Value = skill.SkillID;
                        cmd.Parameters.Add("@SkillName", SqlDbType.NVarChar, 100).Value = skill.SkillName.Trim();
                        cmd.Parameters.Add("@SkillDescription", SqlDbType.NVarChar, -1).Value = 
                            string.IsNullOrWhiteSpace(skill.SkillDescription) ? (object)DBNull.Value : skill.SkillDescription.Trim();

                        int rowsAffected = DatabaseConnection.ExecuteNonQueryCount(cmd);
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Skill record not found to update.";
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
        // 5. DELETE: Remove Skill by SkillID
        // =========================================================================
        public static bool Delete(int skillId, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (skillId <= 0)
            {
                errorMessage = "Invalid SkillID.";
                return false;
            }

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand("dbo.sp_DeleteSkill", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@SkillID", SqlDbType.Int).Value = skillId;

                        int rowsAffected = DatabaseConnection.ExecuteNonQueryCount(cmd);
                        if (rowsAffected > 0)
                        {
                            return true;
                        }
                        else
                        {
                            errorMessage = "Skill record not found to delete.";
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
        // HELPER: Map SqlDataReader to Skill Model
        // =========================================================================
        private static Skill MapFromReader(SqlDataReader reader)
        {
            return new Skill
            {
                SkillID = reader.GetInt32(reader.GetOrdinal("SkillID")),
                UserID = reader.GetInt32(reader.GetOrdinal("UserID")),
                SkillName = reader.GetString(reader.GetOrdinal("SkillName")),
                SkillDescription = reader.IsDBNull(reader.GetOrdinal("SkillDescription")) 
                    ? null 
                    : reader.GetString(reader.GetOrdinal("SkillDescription")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("CreatedAt"))
            };
        }
    }
}
