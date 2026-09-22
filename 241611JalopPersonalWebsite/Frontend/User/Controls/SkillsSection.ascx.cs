using System;
using System.Collections.Generic;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Frontend.User.Controls
{
    public partial class SkillsSection : UserControl
    {
        public void BindSkills(List<Skill> skills)
        {
            if (skills != null && skills.Count > 0)
            {
                rptSkills.DataSource = skills;
                rptSkills.DataBind();
                pnlNoSkills.Visible = false;
            }
            else
            {
                pnlNoSkills.Visible = true;
            }
        }
    }
}
