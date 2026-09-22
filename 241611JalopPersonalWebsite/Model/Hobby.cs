using System;

namespace _241611JalopPersonalWebsite.Model
{
    public class Hobby
    {
        public int HobbyID { get; set; }
        public int UserID { get; set; }
        public string HobbyName { get; set; }
        public string HobbyDescription { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
