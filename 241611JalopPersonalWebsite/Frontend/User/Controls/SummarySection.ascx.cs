using System;
using System.Web.UI;

namespace _241611JalopPersonalWebsite.Frontend.User.Controls
{
    public partial class SummarySection : UserControl
    {
        public void BindSummary(string description)
        {
            if (!string.IsNullOrWhiteSpace(description))
            {
                pnlSummary.Visible = true;
                litSummary.Text = Server.HtmlEncode(description);
            }
            else
            {
                pnlSummary.Visible = false;
            }
        }
    }
}
