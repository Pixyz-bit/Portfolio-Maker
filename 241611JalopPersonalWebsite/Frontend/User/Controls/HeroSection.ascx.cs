using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Frontend.User.Controls
{
    public partial class HeroSection : UserControl
    {
        public void BindProfile(UserProfile profile)
        {
            if (profile != null)
            {
                litFullName.Text = profile.FullName;

                // Birthday
                if (profile.Birthday.HasValue)
                {
                    rowBirthday.Visible = true;
                    litBirthday.Text = profile.Birthday.Value.ToString("MMMM d, yyyy");
                }
                else
                {
                    rowBirthday.Visible = false;
                }

                // Address
                if (!string.IsNullOrWhiteSpace(profile.Address))
                {
                    rowAddress.Visible = true;
                    litAddress.Text = Server.HtmlEncode(profile.Address);
                }
                else
                {
                    rowAddress.Visible = false;
                }

                // Contact Number
                if (!string.IsNullOrWhiteSpace(profile.ContactNum))
                {
                    rowContact.Visible = true;
                    litContact.Text = Server.HtmlEncode(profile.ContactNum);
                }
                else
                {
                    rowContact.Visible = false;
                }

                // Contact Email
                if (!string.IsNullOrWhiteSpace(profile.ContactEmail))
                {
                    rowEmail.Visible = true;
                    litEmail.Text = $"<a href=\"mailto:{Server.HtmlEncode(profile.ContactEmail)}\">{Server.HtmlEncode(profile.ContactEmail)}</a>";
                }
                else
                {
                    rowEmail.Visible = false;
                }

                // Profile Image
                if (!string.IsNullOrWhiteSpace(profile.ProfileImagePath))
                {
                    imgAvatar.ImageUrl = ResolveUrl(profile.ProfileImagePath);
                }
            }
            else
            {
                litFullName.Text = "Profile Not Found";
                rowBirthday.Visible = false;
                rowAddress.Visible = false;
                rowContact.Visible = false;
                rowEmail.Visible = false;
            }
        }
    }
}
