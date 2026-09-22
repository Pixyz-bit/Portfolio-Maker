using System;

namespace _241611JalopPersonalWebsite.Model
{
    public class Affiliation
    {
        public int AffiliationID { get; set; }
        public int UserID { get; set; }
        public string OrganizationName { get; set; }
        public string Position { get; set; }
        public string StartYear { get; set; }
        public string EndYear { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
