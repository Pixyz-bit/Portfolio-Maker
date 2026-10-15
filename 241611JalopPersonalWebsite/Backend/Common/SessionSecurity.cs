using System;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    public static class SessionSecurity
    {
        public static UserLogin CurrentUser()
        {
            HttpContext context = HttpContext.Current;
            if (context?.Session == null) return null;
            if (context.Items.Contains("VerifiedUser")) return context.Items["VerifiedUser"] as UserLogin;
            context.Items["VerifiedUser"] = false;
            if (!int.TryParse(Convert.ToString(context.Session["UserID"]), out int id) || id <= 0) return null;
            try
            {
                using (var conn = DatabaseConnection.GetConnection())
                using (var cmd = new SqlCommand("SELECT Email, Role, IsActive, PasswordHash FROM dbo.Users WHERE UserID=@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", id);
                    conn.Open();
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read() || !Convert.ToBoolean(reader["IsActive"]) ||
                            !string.Equals(Convert.ToString(context.Session["CredentialStamp"]), Convert.ToString(reader["PasswordHash"]), StringComparison.Ordinal))
                        {
                            context.Session.Clear();
                            return null;
                        }
                        var user = new UserLogin { UserID = id, Email = Convert.ToString(reader["Email"]), Role = Convert.ToString(reader["Role"]), IsActive = true };
                        context.Session["Role"] = user.Role;
                        context.Session["UserEmail"] = user.Email;
                        context.Items["VerifiedUser"] = user;
                        return user;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Session verification failed: {0}", ex);
                context.Session.Clear();
                return null;
            }
        }

        public static bool CanEdit(UserLogin user, int targetId)
        {
            return user != null && user.IsActive && targetId > 0 &&
                (user.UserID == targetId || string.Equals(user.Role, "Admin", StringComparison.OrdinalIgnoreCase));
        }
    }

    public class SecurePage : Page
    {
        protected virtual bool RequiresLogin => false;
        protected virtual bool RequiresAdmin => false;
        protected override void OnInit(EventArgs e)
        {
            // Bind signed ViewState to this session, including anonymous forms.
            if (Session["PostbackKey"] == null) Session["PostbackKey"] = Guid.NewGuid().ToString("N");
            ViewStateUserKey = Convert.ToString(Session["PostbackKey"]);
            UserLogin user = SessionSecurity.CurrentUser();
            if ((RequiresLogin && user == null) || (RequiresAdmin && !string.Equals(user?.Role, "Admin", StringComparison.OrdinalIgnoreCase)))
                Response.Redirect("~/Frontend/Login/Login.aspx", true);
            base.OnInit(e);
        }
    }
}
