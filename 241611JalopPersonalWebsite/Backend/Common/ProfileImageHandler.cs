using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.SessionState;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    public sealed class ProfileImageHandler : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable => false;

        public void ProcessRequest(HttpContext context)
        {
            // Even public images must not survive a later privacy change in a shared cache.
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            context.Response.Cache.SetExpires(DateTime.UtcNow.AddYears(-1));
            context.Response.AppendHeader("X-Content-Type-Options", "nosniff");
            context.Response.TrySkipIisCustomErrors = true;
            string name = context.Request.QueryString["file"];
            if (!int.TryParse(context.Request.QueryString["userId"], out int userId) || userId <= 0 ||
                string.IsNullOrEmpty(name) || name.Length > 200 ||
                string.IsNullOrEmpty(InputSafety.SafeImageUrl("~/App_Data/ProfileImages/" + name)))
            { context.Response.StatusCode = 404; return; }
            try
            {
                var actor = SessionSecurity.CurrentUser();
                string storedPath;
                using (var conn = DatabaseConnection.GetConnection())
                using (var cmd = new SqlCommand(@"
                    SELECT TOP (1) p.ProfileImagePath FROM dbo.UserProfiles p
                    JOIN dbo.Users u ON u.UserID=p.UserID
                    WHERE p.UserID=@UserID AND p.ProfileImagePath IN (@PrivatePath,@LegacyPath)
                      AND ((p.IsPublic=1 AND u.IsActive=1) OR p.UserID=@ActorID OR @IsAdmin=1)", conn))
                {
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;
                    cmd.Parameters.Add("@PrivatePath", SqlDbType.NVarChar, 500).Value = "~/App_Data/ProfileImages/" + name;
                    cmd.Parameters.Add("@LegacyPath", SqlDbType.NVarChar, 500).Value = "~/Uploads/Profiles/" + name;
                    cmd.Parameters.Add("@ActorID", SqlDbType.Int).Value = actor?.UserID ?? 0;
                    cmd.Parameters.Add("@IsAdmin", SqlDbType.Bit).Value = string.Equals(actor?.Role, "Admin", StringComparison.OrdinalIgnoreCase);
                    conn.Open();
                    storedPath = cmd.ExecuteScalar() as string;
                }
                if (string.IsNullOrEmpty(InputSafety.SafeImageUrl(storedPath)))
                { context.Response.StatusCode = 404; return; }
                string physicalPath = context.Server.MapPath(storedPath);
                if (!File.Exists(physicalPath)) { context.Response.StatusCode = 404; return; }
                switch (Path.GetExtension(storedPath).ToLowerInvariant())
                {
                    case ".jpg": case ".jpeg": context.Response.ContentType = "image/jpeg"; break;
                    case ".webp": context.Response.ContentType = "image/webp"; break;
                    default: context.Response.ContentType = "image/png"; break;
                }
                context.Response.TransmitFile(physicalPath);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Profile image delivery failed: {0}", ex);
                context.Response.StatusCode = 500;
            }
        }
    }
}
