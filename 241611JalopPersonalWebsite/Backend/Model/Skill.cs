using System;

namespace _241611JalopPersonalWebsite.Model
{
    public class Skill
    {
        public int SkillID { get; set; }
        public int UserID { get; set; }
        public string SkillName { get; set; }
        public string SkillDescription { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
