using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class DatabaseConnection
    {
        private static readonly string ConnectionString = 
            ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString 
            ?? @"Server=.;Database=IPTPersonalWebsite;Trusted_Connection=True;TrustServerCertificate=True;";

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(ConnectionString);
        }

        public static bool TestConnection(out string message)
        {
            try
            {
                using (SqlConnection conn = GetConnection())
                {
                    conn.Open();
                    message = "Database connection successful!";
                    return true;
                }
            }
            catch (Exception ex)
            {
                message = $"Database connection failed: {ex.Message}";
                return false;
            }
        }
    }
}
