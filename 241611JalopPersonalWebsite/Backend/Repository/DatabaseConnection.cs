using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class DatabaseConnection
    {
        private const string LocalFallbackConnectionString = 
            @"Data Source=.;Initial Catalog=IPTPersonalWebsite;Integrated Security=True;TrustServerCertificate=True;";

        /// <summary>
        /// Retrieves the active connection string supporting both domain (runasp.net) and local environments.
        /// </summary>
        public static string GetActiveConnectionString()
        {
            // 1. Cloud environment variables (if set on hosting platform)
            string envConn = Environment.GetEnvironmentVariable("SQLCONNSTR_DefaultConnection")
                          ?? Environment.GetEnvironmentVariable("DefaultConnection");
            if (!string.IsNullOrWhiteSpace(envConn))
            {
                return envConn;
            }

            // 2. Check DatabaseTarget override in appSettings ("Local", "Remote", or "Auto")
            string target = ConfigurationManager.AppSettings["DatabaseTarget"]?.Trim();

            if (string.Equals(target, "Local", StringComparison.OrdinalIgnoreCase))
            {
                string localFromConfig = ConfigurationManager.ConnectionStrings["LocalConnection"]?.ConnectionString;
                if (!string.IsNullOrWhiteSpace(localFromConfig))
                {
                    return localFromConfig;
                }
            }
            else if (string.Equals(target, "Remote", StringComparison.OrdinalIgnoreCase))
            {
                string remoteFromConfig = ConfigurationManager.ConnectionStrings["RemoteConnection"]?.ConnectionString
                                       ?? ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString;
                if (!string.IsNullOrWhiteSpace(remoteFromConfig))
                {
                    return remoteFromConfig;
                }
            }

            // 3. Default resolution: primary connection string from ConnectionStrings.config
            string defaultConn = ConfigurationManager.ConnectionStrings["DefaultConnection"]?.ConnectionString;
            if (!string.IsNullOrWhiteSpace(defaultConn))
            {
                return defaultConn;
            }

            // 4. Local connection fallback
            string localFallback = ConfigurationManager.ConnectionStrings["LocalConnection"]?.ConnectionString;
            if (!string.IsNullOrWhiteSpace(localFallback))
            {
                return localFallback;
            }

            // 5. Hardcoded offline fallback
            return LocalFallbackConnectionString;
        }

        public static SqlConnection GetConnection()
        {
            return new SqlConnection(GetActiveConnectionString());
        }

        public static bool TestConnection(out string message)
        {
            return TestConnection(GetActiveConnectionString(), out message);
        }

        public static bool TestConnection(string connectionString, out string message)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "SELECT 1";
                        cmd.ExecuteScalar();
                    }
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

        public static bool IsLocalEnvironment()
        {
            try
            {
                if (HttpContext.Current != null && HttpContext.Current.Request != null)
                {
                    return HttpContext.Current.Request.IsLocal;
                }
            }
            catch { }
            return true;
        }

        public static string GetDomainUrl()
        {
            return ConfigurationManager.AppSettings["DomainUrl"] ?? "http://pixyz-bit.runasp.net/";
        }

        public static string GetBaseUrl()
        {
            try
            {
                if (HttpContext.Current != null && HttpContext.Current.Request != null)
                {
                    var req = HttpContext.Current.Request;
                    return $"{req.Url.Scheme}://{req.Url.Authority}";
                }
            }
            catch { }
            return GetDomainUrl().TrimEnd('/');
        }
    }
}
