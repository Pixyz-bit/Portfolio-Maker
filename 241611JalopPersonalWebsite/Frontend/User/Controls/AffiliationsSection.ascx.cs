using System;
using System.Collections.Generic;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Frontend.User.Controls
{
    public partial class AffiliationsSection : UserControl
    {
        public void BindAffiliations(List<Affiliation> affiliations)
        {
            if (affiliations != null && affiliations.Count > 0)
            {
                rptAffiliations.DataSource = affiliations;
                rptAffiliations.DataBind();
                pnlNoAffiliations.Visible = false;
            }
            else
            {
                pnlNoAffiliations.Visible = true;
            }
        }

        public static string FormatPeriod(object startYearObj, object endYearObj)
        {
            string start = (startYearObj as string ?? string.Empty).Trim();
            string end = (endYearObj as string ?? string.Empty).Trim();

            if (string.IsNullOrEmpty(start) && string.IsNullOrEmpty(end))
            {
                return string.Empty;
            }

            if (string.IsNullOrEmpty(end))
            {
                return $"{start} - Present";
            }

            return $"{start} - {end}";
        }
    }
}
