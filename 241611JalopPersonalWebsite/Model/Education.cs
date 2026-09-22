using System;

namespace _241611JalopPersonalWebsite.Model
{
    public class Education
    {
        public int EducationID { get; set; }
        public int UserID { get; set; }
        public string CourseName { get; set; }
        public string University { get; set; }
        public string StartYear { get; set; }
        public string EndYear { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
