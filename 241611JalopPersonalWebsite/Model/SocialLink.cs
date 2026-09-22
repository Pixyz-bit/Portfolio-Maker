using System;

namespace _241611JalopPersonalWebsite.Model
{
    public class SocialLink
    {
        public int SocialLinkID { get; set; }
        public int UserID { get; set; }
        public string SocialLinkName { get; set; }
        public string Link { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
