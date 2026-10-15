using System;
using System.Security.Cryptography;
using System.Text;

namespace _241611JalopPersonalWebsite.Backend.Common
{
    public static class PasswordSecurity
    {
        private const int Iterations = 600000;
        public static string Hash(string password)
        {
            if (string.IsNullOrEmpty(password)) throw new ArgumentException("Password is required.");
            byte[] salt = new byte[16];
            using (var random = RandomNumberGenerator.Create()) random.GetBytes(salt);
            using (var derive = new Rfc2898DeriveBytes(password, salt, Iterations, HashAlgorithmName.SHA256))
                return "pbkdf2-sha256$" + Iterations + "$" + Convert.ToBase64String(salt) + "$" + Convert.ToBase64String(derive.GetBytes(32));
        }

        public static bool Verify(string password, string stored, out bool needsUpgrade)
        {
            needsUpgrade = false;
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(stored)) return false;
            if (stored.StartsWith("pbkdf2-sha256$", StringComparison.Ordinal))
            {
                try
                {
                    string[] parts = stored.Split('$');
                    if (parts.Length != 4 || !int.TryParse(parts[1], out int count) || count < 100000 || count > 2000000) return false;
                    byte[] salt = Convert.FromBase64String(parts[2]), expected = Convert.FromBase64String(parts[3]);
                    if (salt.Length != 16 || expected.Length != 32) return false;
                    using (var derive = new Rfc2898DeriveBytes(password, salt, count, HashAlgorithmName.SHA256))
                    {
                        bool valid = Equal(expected, derive.GetBytes(32));
                        needsUpgrade = valid && count < Iterations;
                        return valid;
                    }
                }
                catch (FormatException) { return false; }
            }
            // Accept existing SHA-256 hashes only by hashing the supplied password.
            // Plaintext values and submission of the hash itself are never accepted.
            if (stored.Length != 64 || !System.Text.RegularExpressions.Regex.IsMatch(stored, "\\A[0-9a-fA-F]{64}\\z")) return false;
            using (var sha = SHA256.Create())
            {
                string actual = BitConverter.ToString(sha.ComputeHash(Encoding.UTF8.GetBytes(password))).Replace("-", "").ToLowerInvariant();
                bool valid = Equal(Encoding.ASCII.GetBytes(stored.ToLowerInvariant()), Encoding.ASCII.GetBytes(actual));
                needsUpgrade = valid;
                return valid;
            }
        }

        private static bool Equal(byte[] left, byte[] right)
        {
            if (left.Length != right.Length) return false;
            int difference = 0;
            for (int i = 0; i < left.Length; i++) difference |= left[i] ^ right[i];
            return difference == 0;
        }
    }
}
