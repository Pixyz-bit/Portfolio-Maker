using System;
using System.Collections.Generic;

namespace _241611JalopPersonalWebsite.Model
{
    /// <summary>
    /// Model representing a publicly visible user portfolio card.
    /// </summary>
    public class PublicPortfolioItem
    {
        public int UserID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Address { get; set; }
        public string Description { get; set; }
        public string ProfileImagePath { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public List<string> Skills { get; set; } = new List<string>();
        public string ObfuscatedToken { get; set; }

        public string FullName
        {
            get
            {
                string name = $"{FirstName} {LastName}".Trim();
                return string.IsNullOrWhiteSpace(name) ? Email : name;
            }
        }

        public string Initials
        {
            get
            {
                if (!string.IsNullOrWhiteSpace(FirstName))
                {
                    string init = FirstName.Substring(0, 1).ToUpperInvariant();
                    if (!string.IsNullOrWhiteSpace(LastName))
                    {
                        init += LastName.Substring(0, 1).ToUpperInvariant();
                    }
                    return init;
                }

                if (!string.IsNullOrWhiteSpace(Email))
                {
                    return Email.Substring(0, 1).ToUpperInvariant();
                }

                return "U";
            }
        }
    }
}
