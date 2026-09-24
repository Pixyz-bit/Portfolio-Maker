using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    public static class UrlObfuscator
    {
        // 16-character encryption key (keep this secret in Web.config or here)
        private static readonly byte[] Key = Encoding.UTF8.GetBytes("PortfolioApp2026"); 
        private static readonly byte[] Iv = Encoding.UTF8.GetBytes("InitVector123456");

        public static string EncodeUserId(int userId)
        {
            if (userId <= 0) return string.Empty;

            using (Aes aes = Aes.Create())
            {
                aes.Key = Key;
                aes.IV = Iv;

                using (MemoryStream ms = new MemoryStream())
                {
                    using (CryptoStream cs = new CryptoStream(ms, aes.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        byte[] plainBytes = BitConverter.GetBytes(userId);
                        cs.Write(plainBytes, 0, plainBytes.Length);
                        cs.FlushFinalBlock();
                    }

                    // Convert to URL-safe base64 string
                    return Convert.ToBase64String(ms.ToArray())
                        .Replace("+", "-")
                        .Replace("/", "_")
                        .TrimEnd('=');
                }
            }
        }

        public static int DecodeUserId(string token)
        {
            if (string.IsNullOrWhiteSpace(token)) return 0;

            try
            {
                // Restore standard Base64 characters and padding
                string incoming = token.Replace("-", "+").Replace("_", "/");
                switch (incoming.Length % 4)
                {
                    case 2: incoming += "=="; break;
                    case 3: incoming += "="; break;
                }

                byte[] cipherBytes = Convert.FromBase64String(incoming);

                using (Aes aes = Aes.Create())
                {
                    aes.Key = Key;
                    aes.IV = Iv;

                    using (MemoryStream ms = new MemoryStream(cipherBytes))
                    using (CryptoStream cs = new CryptoStream(ms, aes.CreateDecryptor(), CryptoStreamMode.Read))
                    {
                        byte[] buffer = new byte[sizeof(int)];
                        int bytesRead = cs.Read(buffer, 0, buffer.Length);
                        if (bytesRead == sizeof(int))
                        {
                            return BitConverter.ToInt32(buffer, 0);
                        }
                    }
                }
            }
            catch
            {
                // Return 0 if token is forged, corrupted, or tampered with
                return 0;
            }

            return 0;
        }
    }
}
