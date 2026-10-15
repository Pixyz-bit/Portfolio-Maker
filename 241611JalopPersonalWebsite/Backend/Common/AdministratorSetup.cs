using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    // Operator-only bootstrap, with no web route. A trusted database operator
    // explicitly supplies the first administrator's unique credentials.
    public static class AdministratorSetup
    {
        public static bool CreateFirst(string firstName, string lastName, string email, string password, out string error)
        {
            error = string.Empty;
            if (string.IsNullOrWhiteSpace(firstName) || firstName.Trim().Length > 50 ||
                string.IsNullOrWhiteSpace(lastName) || lastName.Trim().Length > 50 ||
                string.IsNullOrWhiteSpace(email) || email.Length > 255 || !Regex.IsMatch(email.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$") ||
                string.IsNullOrWhiteSpace(password) || password.Length < 12)
            { error = "Enter names up to 50 characters, a valid email, and a unique password of at least 12 characters."; return false; }
            string hash = PasswordSecurity.Hash(password);
            try
            {
                using (var conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();
                    using (var transaction = conn.BeginTransaction(IsolationLevel.Serializable))
                    {
                        using (var exists = new SqlCommand("SELECT COUNT(*) FROM dbo.Users WITH (UPDLOCK,HOLDLOCK) WHERE Role=N'Admin'", conn, transaction))
                            if (Convert.ToInt32(exists.ExecuteScalar()) != 0)
                            { error = "An administrator already exists. Use the administrator account-management workflow."; return false; }
                        using (var cmd = new SqlCommand("dbo.sp_AdminCreateUser", conn, transaction))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@FirstName", SqlDbType.NVarChar, 50).Value = firstName.Trim();
                            cmd.Parameters.Add("@LastName", SqlDbType.NVarChar, 50).Value = lastName.Trim();
                            cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email.Trim();
                            cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 255).Value = hash;
                            cmd.Parameters.Add("@Role", SqlDbType.NVarChar, 20).Value = "Admin";
                            cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = true;
                            if (Convert.ToInt32(cmd.ExecuteScalar()) <= 0) throw new InvalidOperationException();
                        }
                        transaction.Commit();
                        return true;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Administrator bootstrap failed: {0}", ex);
                error = "Administrator setup failed. Verify the selected database, migrations and email address.";
                return false;
            }
        }
    }
}
