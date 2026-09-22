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

    //    // Parameterless constructor
    //     public UserLogin()
    //     {
    //     }

    //     // Overloaded constructor for convenience
    //     public UserLogin(string firstName, string lastName, string email, string password)
    //     {
    //         FirstName = firstName;
    //         LastName = lastName;
    //         Email = email;
    //         Password = password;
    //     }
    }
}
