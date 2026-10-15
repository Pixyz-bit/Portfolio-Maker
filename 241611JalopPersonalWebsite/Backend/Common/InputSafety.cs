using System;
using System.Web;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    public static class InputSafety
    {
        public static bool ValidateNames(string firstName, string lastName, out string error)
        {
            error = string.Empty;
            if (string.IsNullOrWhiteSpace(firstName)) error = "First name is required.";
            else if (firstName.Trim().Length > 50) error = "First name must be 50 characters or fewer.";
            else if (string.IsNullOrWhiteSpace(lastName)) error = "Last name is required.";
            else if (lastName.Trim().Length > 50) error = "Last name must be 50 characters or fewer.";
            return error.Length == 0;
        }

        public static bool ValidateAccountFields(string firstName, string lastName, string email, out string error)
        {
            if (!ValidateNames(firstName,lastName,out error)) return false;
            if (string.IsNullOrWhiteSpace(email) || email.Trim().Length > 255 ||
                !System.Text.RegularExpressions.Regex.IsMatch(email.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                error = "Enter a valid email address of 255 characters or fewer.";
            return error.Length == 0;
        }

        public static bool IsWebUrl(string value)
        {
            return !string.IsNullOrWhiteSpace(value) && value.Length <= 500 &&
                Uri.TryCreate(value, UriKind.Absolute, out Uri uri) &&
                (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps) &&
                !string.IsNullOrWhiteSpace(uri.Host) && string.IsNullOrEmpty(uri.UserInfo);
        }

        public static string SafeWebUrl(object value)
        {
            string url = Convert.ToString(value)?.Trim();
            return IsWebUrl(url) ? HttpUtility.HtmlAttributeEncode(url).Replace("'", "&#39;") : "#";
        }

        public static string SafeImageUrl(string value)
        {
            // Stored upload paths never point at an external server or executable resource.
            if (string.IsNullOrEmpty(value)) return string.Empty;
            string prefix = value.StartsWith("~/Uploads/Profiles/", StringComparison.Ordinal) ? "~/Uploads/Profiles/" :
                value.StartsWith("~/App_Data/ProfileImages/", StringComparison.Ordinal) ? "~/App_Data/ProfileImages/" : null;
            if (prefix == null) return string.Empty;
            string file = value.Substring(prefix.Length);
            if (file.IndexOfAny(new[] { '/', '\\', '?', '#', ':', '\'', '"' }) >= 0 || file.Contains("..")) return string.Empty;
            string ext = System.IO.Path.GetExtension(file).ToLowerInvariant();
            return ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp" ? value : string.Empty;
        }
    }
}
