using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Repository;

namespace _241611JalopPersonalWebsite
{
    public partial class PortfolioTemplate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (DatabaseConnection.TestConnection(out string message))
                {
                    // JavaScript alert popup with success message
                    ClientScript.RegisterStartupScript(this.GetType(), "dbTest", $"alert('{message}');", true);
                }
                else
                {
                    // JavaScript alert popup with error details
                    ClientScript.RegisterStartupScript(this.GetType(), "dbTest", $"alert('{message.Replace("'", "\\'")}');", true);
                }
            }
        }
    }
}
