using System;
using System.Collections.Generic;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Frontend.User.Controls
{
    public partial class HobbiesSection : UserControl
    {
        public void BindHobbies(List<Hobby> hobbies)
        {
            if (hobbies != null && hobbies.Count > 0)
            {
                rptHobbies.DataSource = hobbies;
                rptHobbies.DataBind();
                pnlNoHobbies.Visible = false;
            }
            else
            {
                pnlNoHobbies.Visible = true;
            }
        }
    }
}
