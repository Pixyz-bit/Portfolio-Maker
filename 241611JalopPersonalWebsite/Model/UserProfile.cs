using System;

namespace _241611JalopPersonalWebsite.Model
{
    public class UserProfile
    {
        public int ProfileID { get; set; }
        public int UserID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public DateTime? Birthday { get; set; }
        public string Address { get; set; }
        public string ContactEmail { get; set; }
        public string ContactNum { get; set; }
        public string ProfileImagePath { get; set; }
        public string Description { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string FullName => $"{FirstName} {LastName}".Trim();

        // public UserProfile()
        // {
        // }

        // public UserProfile(
        //     string firstName, 
        //     string lastName, 
        //     DateTime? birthday = null, 
        //     string address = null, 
        //     string contactEmail = null, 
        //     string contactNum = null, 
        //     string profileImagePath = null, 
        //     string description = null)
        // {
        //     FirstName = firstName;
        //     LastName = lastName;
        //     Birthday = birthday;
        //     Address = address;
        //     ContactEmail = contactEmail;
        //     ContactNum = contactNum;
        //     ProfileImagePath = profileImagePath;
        //     Description = description;
        // }
    }
}
