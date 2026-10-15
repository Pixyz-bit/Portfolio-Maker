using System;
using System.Data;
using System.Data.SqlClient;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class PortfolioSaveRepository
    {
        public static bool Save(PortfolioSaveData data, int actorId, out string previousImage, out string error)
        {
            previousImage = null; error = string.Empty;
            try
            {
                data.Validate(); // No writes before every section is valid.
                using (var conn = DatabaseConnection.GetConnection())
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction(IsolationLevel.Serializable))
                    {
                        try
                        {
                            using (var guard = new SqlCommand(@"
                                SELECT CASE WHEN actor.IsActive=1 AND (actor.UserID=@Target OR actor.Role=N'Admin') THEN 1 ELSE 0 END
                                FROM dbo.Users actor WITH (UPDLOCK, HOLDLOCK)
                                WHERE actor.UserID=@Actor AND EXISTS (SELECT 1 FROM dbo.Users WITH (UPDLOCK, HOLDLOCK) WHERE UserID=@Target)", conn, tx))
                            {
                                guard.Parameters.AddWithValue("@Actor", actorId); guard.Parameters.AddWithValue("@Target", data.Profile.UserID);
                                if (Convert.ToInt32(guard.ExecuteScalar()) != 1) throw new UnauthorizedAccessException();
                            }
                            using (var image = new SqlCommand("SELECT ProfileImagePath FROM dbo.UserProfiles WITH (UPDLOCK,HOLDLOCK) WHERE UserID=@UserID", conn, tx))
                            {
                                image.Parameters.AddWithValue("@UserID", data.Profile.UserID);
                                previousImage = image.ExecuteScalar() as string;
                            }
                            // A missing new image means retain the current database value, never a posted hidden path.
                            string imagePath = data.Profile.ProfileImagePath ?? previousImage;
                            using (var cmd = new SqlCommand(@"
                                UPDATE dbo.UserProfiles SET FirstName=@FirstName, LastName=@LastName, Birthday=@Birthday,
                                Address=@Address, ContactEmail=@ContactEmail, ContactNum=@ContactNum, Description=@Description,
                                ProfileImagePath=@Image, IsPublic=@IsPublic, UpdatedAt=SYSUTCDATETIME() WHERE UserID=@UserID;
                                IF @@ROWCOUNT=0 INSERT dbo.UserProfiles
                                (UserID,FirstName,LastName,Birthday,Address,ContactEmail,ContactNum,Description,ProfileImagePath,IsPublic)
                                VALUES (@UserID,@FirstName,@LastName,@Birthday,@Address,@ContactEmail,@ContactNum,@Description,@Image,@IsPublic);
                                DELETE dbo.Educations WHERE UserID=@UserID;
                                DELETE dbo.Skills WHERE UserID=@UserID;
                                DELETE dbo.Affiliations WHERE UserID=@UserID;
                                DELETE dbo.Hobbies WHERE UserID=@UserID;
                                DELETE dbo.SocialLinks WHERE UserID=@UserID;", conn, tx))
                            {
                                var p = data.Profile;
                                cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = p.UserID;
                                Add(cmd, "@FirstName", 50, p.FirstName); Add(cmd, "@LastName", 50, p.LastName);
                                Add(cmd, "@Address", 255, p.Address); Add(cmd, "@ContactEmail", 255, p.ContactEmail);
                                Add(cmd, "@ContactNum", 30, p.ContactNum); Add(cmd, "@Description", -1, p.Description); Add(cmd, "@Image", 500, imagePath);
                                cmd.Parameters.Add("@Birthday", SqlDbType.Date).Value = (object)p.Birthday ?? DBNull.Value;
                                cmd.Parameters.Add("@IsPublic", SqlDbType.Bit).Value = p.IsPublic;
                                cmd.ExecuteNonQuery();
                            }
                            Bulk(conn, tx, data.Profile.UserID, "Educations", data.Educations, "CourseName", "University", "StartYear", "EndYear");
                            Bulk(conn, tx, data.Profile.UserID, "Skills", data.Skills, "SkillName", "SkillDescription");
                            Bulk(conn, tx, data.Profile.UserID, "Affiliations", data.Affiliations, "OrganizationName", "Position", "StartYear", "EndYear");
                            Bulk(conn, tx, data.Profile.UserID, "Hobbies", data.Hobbies, "HobbyName", "HobbyDescription");
                            Bulk(conn, tx, data.Profile.UserID, "SocialLinks", data.SocialLinks, "SocialLinkName", "Link");
                            tx.Commit();
                            return true;
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
            }
            catch (ArgumentException ex) { error = ex.Message; }
            catch (UnauthorizedAccessException) { error = "You no longer have permission to edit this portfolio."; }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Portfolio save failed: {0}", ex);
                error = "The portfolio could not be saved. Your existing information was kept. Please try again.";
            }
            return false;
        }

        private static void Add(SqlCommand cmd, string name, int length, string value)
        { cmd.Parameters.Add(name, SqlDbType.NVarChar, length).Value = string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value.Trim(); }

        private static void Bulk<T>(SqlConnection conn, SqlTransaction tx, int userId, string tableName, System.Collections.Generic.List<T> items, params string[] columns)
        {
            if (items.Count == 0) return;
            using (var rows = new DataTable())
            {
                rows.Columns.Add("UserID", typeof(int));
                foreach (var col in columns) rows.Columns.Add(col, typeof(string));
                foreach (var item in items)
                {
                    var row = rows.NewRow(); row["UserID"] = userId;
                    foreach (var col in columns)
                    {
                        string value = typeof(T).GetProperty(col).GetValue(item) as string;
                        row[col] = string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value.Trim();
                    }
                    rows.Rows.Add(row);
                }
                using (var bulk = new SqlBulkCopy(conn, SqlBulkCopyOptions.CheckConstraints | SqlBulkCopyOptions.FireTriggers, tx))
                {
                    bulk.DestinationTableName = "dbo." + tableName;
                    foreach (DataColumn col in rows.Columns) bulk.ColumnMappings.Add(col.ColumnName, col.ColumnName);
                    bulk.WriteToServer(rows);
                }
            }
        }
    }
}
