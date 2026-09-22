using System;

namespace _241611JalopPersonalWebsite.Model
{
    /// <summary>
    /// Model representing user authentication and registration details.
    /// </summary>
    public class UserLogin
    {
        public int UserID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string Role { get; set; } = "User";
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public string FullName
        {
            get
            {
                string name = $"{FirstName} {LastName}".Trim();
                return string.IsNullOrWhiteSpace(name) ? Email : name;
            }
        }
    }
}
