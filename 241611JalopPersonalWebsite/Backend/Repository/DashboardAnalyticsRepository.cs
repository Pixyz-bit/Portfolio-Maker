using System;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class DashboardAnalyticsRepository
    {
        // =========================================================================
        // 1. GET ALL ANALYTICS: Retrieve TotalUsers, TotalActive, and TotalInactive
        // =========================================================================
        public static DashboardAnalytics GetDashboardAnalytics(out string errorMessage)
        {
            errorMessage = string.Empty;
            DashboardAnalytics analytics = new DashboardAnalytics();

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            COUNT(*) AS TotalUsers,
                            ISNULL(SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END), 0) AS TotalActive,
                            ISNULL(SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END), 0) AS TotalInactive
                        FROM dbo.Users;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                analytics.TotalUsers = reader.GetInt32(reader.GetOrdinal("TotalUsers"));
                                analytics.TotalActive = reader.GetInt32(reader.GetOrdinal("TotalActive"));
                                analytics.TotalInactive = reader.GetInt32(reader.GetOrdinal("TotalInactive"));
                                return analytics;
                            }
                            else
                            {
                                errorMessage = "No data returned from Users table.";
                                return analytics;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return analytics;
            }
        }

        // =========================================================================
        // 2. GET TOTAL USERS: Count of all registered users
        // =========================================================================
        public static int GetTotalUsers(out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "SELECT COUNT(*) FROM dbo.Users;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int total))
                        {
                            return total;
                        }
                        return 0;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return 0;
            }
        }

        // =========================================================================
        // 3. GET TOTAL ACTIVE USERS: Count of active users (IsActive = 1)
        // =========================================================================
        public static int GetTotalActiveUsers(out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 1;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int activeTotal))
                        {
                            return activeTotal;
                        }
                        return 0;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return 0;
            }
        }

        // =========================================================================
        // 4. GET TOTAL INACTIVE USERS: Count of inactive/deactivated users (IsActive = 0)
        // =========================================================================
        public static int GetTotalInactiveUsers(out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                using (SqlConnection conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();

                    string query = "SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 0;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int inactiveTotal))
                        {
                            return inactiveTotal;
                        }
                        return 0;
                    }
                }
            }
            catch (Exception ex)
            {
                errorMessage = $"Database error: {ex.Message}";
                return 0;
            }
        }
    }
}
