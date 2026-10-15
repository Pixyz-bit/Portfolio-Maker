using System;
using System.Web;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    public static class InputSafety
    {
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
            if (string.IsNullOrEmpty(value) || !value.StartsWith("~/Uploads/Profiles/", StringComparison.Ordinal)) return string.Empty;
            string file = value.Substring("~/Uploads/Profiles/".Length);
            if (file.IndexOfAny(new[] { '/', '\\', '?', '#', ':', '\'', '"' }) >= 0 || file.Contains("..")) return string.Empty;
            string ext = System.IO.Path.GetExtension(file).ToLowerInvariant();
            return ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp" ? value : string.Empty;
        }
    }
}
