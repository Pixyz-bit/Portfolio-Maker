using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite.Frontend.User
{
    public partial class Dashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || !int.TryParse(Session["UserID"].ToString(), out int userId))
            {
                Response.Redirect("../Login/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                UserProfile profile = UserProfileRepository.GetByUserId(userId, out _);
                if (profile != null)
                {
                    litFullName.Text = profile.FullName;
                    litEmail.Text = !string.IsNullOrWhiteSpace(profile.ContactEmail) ? profile.ContactEmail : (Session["UserEmail"]?.ToString() ?? string.Empty);
                    
                    if (!string.IsNullOrWhiteSpace(profile.Description))
                    {
                        litBio.Text = Server.HtmlEncode(profile.Description);
                    }

                    if (!string.IsNullOrWhiteSpace(profile.ProfileImagePath))
                    {
                        imgAvatar.ImageUrl = ResolveUrl(profile.ProfileImagePath);
                    }
                }
                else if (Session["FullName"] != null)
                {
                    litFullName.Text = Session["FullName"].ToString();
                    litEmail.Text = Session["UserEmail"]?.ToString() ?? string.Empty;
                }
            }
        }
    }
}
