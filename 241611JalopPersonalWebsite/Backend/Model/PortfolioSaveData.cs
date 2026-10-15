using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using _241611JalopPersonalWebsite.Backend.Common;

namespace _241611JalopPersonalWebsite.Model
{
    public sealed class PortfolioSaveData
    {
        public UserProfile Profile { get; set; }
        public List<Education> Educations { get; set; }
        public List<Skill> Skills { get; set; }
        public List<Affiliation> Affiliations { get; set; }
        public List<Hobby> Hobbies { get; set; }
        public List<SocialLink> SocialLinks { get; set; }

        public static List<T> ParseSection<T>(string json, string name) where T : class
        {
            if (string.IsNullOrWhiteSpace(json) || json.Length > 262144) throw new ArgumentException(name + " data is missing or too large. Reload the editor and try again.");
            try
            {
                var serializer = new JavaScriptSerializer { MaxJsonLength = 262144 };
                // Deserialize<List<T>> also accepts {} as an empty list. Check the actual
                // JSON shape first so only an explicit [] can clear a section.
                if (!(serializer.DeserializeObject(json) is object[] rawItems) ||
                    rawItems.Length > 100 || Array.Exists(rawItems, x => !(x is Dictionary<string, object>)))
                    throw new ArgumentException();
                var items = serializer.Deserialize<List<T>>(json);
                if (items == null || items.Count > 100 || items.Exists(x => x == null)) throw new ArgumentException();
                return items;
            }
            catch (Exception ex) when (ex is ArgumentException || ex is InvalidOperationException)
            { throw new ArgumentException(name + " data is invalid. Nothing has been saved."); }
        }

        public void Validate()
        {
            if (Profile == null || Profile.UserID <= 0) throw new ArgumentException("Invalid portfolio.");
            Text(Profile.FirstName, "First name", 50, true); Text(Profile.LastName, "Last name", 50, true);
            Text(Profile.Address, "Address", 255); Text(Profile.ContactEmail, "Contact email", 255);
            Text(Profile.ContactNum, "Contact number", 30); Text(Profile.Description, "Biography", 20000);
            if (Profile.ProfileImagePath != null && string.IsNullOrEmpty(InputSafety.SafeImageUrl(Profile.ProfileImagePath)))
                throw new ArgumentException("Invalid profile image path.");
            if (Profile.Birthday > DateTime.Today || Profile.Birthday < new DateTime(1900, 1, 1)) throw new ArgumentException("Enter a birthday between 1900 and today.");
            if (!string.IsNullOrWhiteSpace(Profile.ContactEmail) && !System.Text.RegularExpressions.Regex.IsMatch(Profile.ContactEmail, @"^[^@\s]+@[^@\s]+\.[^@\s]+$")) throw new ArgumentException("Enter a valid contact email.");
            if (!string.IsNullOrWhiteSpace(Profile.ContactNum) && !System.Text.RegularExpressions.Regex.IsMatch(Profile.ContactNum, @"^\d{11}$")) throw new ArgumentException("Contact number must contain 11 digits.");
            Check(Educations); Check(Skills); Check(Affiliations); Check(Hobbies); Check(SocialLinks);
            Educations.RemoveAll(x => Blank(x.CourseName, x.University, x.StartYear, x.EndYear));
            Skills.RemoveAll(x => Blank(x.SkillName, x.SkillDescription));
            Affiliations.RemoveAll(x => Blank(x.OrganizationName, x.Position, x.StartYear, x.EndYear));
            Hobbies.RemoveAll(x => Blank(x.HobbyName, x.HobbyDescription));
            SocialLinks.RemoveAll(x => string.IsNullOrWhiteSpace(x.Link));
            foreach (var x in Educations) { Text(x.CourseName, "Degree", 150, true); Text(x.University, "University", 150, true); Text(x.StartYear, "Education start year", 10, true); Text(x.EndYear, "Education end year", 10); }
            foreach (var x in Skills) { Text(x.SkillName, "Skill", 100, true); Text(x.SkillDescription, "Skill description", 20000); }
            foreach (var x in Affiliations) { Text(x.OrganizationName, "Organization", 150, true); Text(x.Position, "Position", 100, true); Text(x.StartYear, "Affiliation start year", 10, true); Text(x.EndYear, "Affiliation end year", 10); }
            foreach (var x in Hobbies) { Text(x.HobbyName, "Hobby", 100, true); Text(x.HobbyDescription, "Hobby description", 20000); }
            foreach (var x in SocialLinks) { Text(x.SocialLinkName, "Social platform", 50, true); if (!InputSafety.IsWebUrl(x.Link?.Trim())) throw new ArgumentException("Social links must be complete http:// or https:// URLs."); }
        }

        private static void Check<T>(List<T> items) where T : class
        { if (items == null || items.Count > 100 || items.Exists(x => x == null)) throw new ArgumentException("Invalid section data."); }
        private static bool Blank(params string[] values) => Array.TrueForAll(values, string.IsNullOrWhiteSpace);
        private static void Text(string value, string name, int length, bool required = false)
        { if ((required && string.IsNullOrWhiteSpace(value)) || (value?.Length ?? 0) > length) throw new ArgumentException(name + (required && string.IsNullOrWhiteSpace(value) ? " is required." : " is too long.")); }
    }
}
