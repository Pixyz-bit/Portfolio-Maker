using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Reflection;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class PortfolioReadRepository
    {
        private const string PortfolioQueries = @"
            SELECT * FROM dbo.UserProfiles WHERE UserID=@ID;
            SELECT * FROM dbo.Educations WHERE UserID=@ID ORDER BY EducationID;
            SELECT * FROM dbo.Skills WHERE UserID=@ID ORDER BY SkillID;
            SELECT * FROM dbo.Affiliations WHERE UserID=@ID ORDER BY AffiliationID;
            SELECT * FROM dbo.Hobbies WHERE UserID=@ID ORDER BY HobbyID;
            SELECT * FROM dbo.SocialLinks WHERE UserID=@ID ORDER BY SocialLinkID;";

        public static UserSummaryData LoadSummary(int userId)
        {
            using (var conn = DatabaseConnection.GetConnection())
            using (var cmd = new SqlCommand(@"
                SELECT u.UserID,u.Email,u.Role,u.IsActive,u.CreatedAt,
                    COALESCE(p.FirstName,N'') FirstName,COALESCE(p.LastName,N'') LastName
                FROM dbo.Users u LEFT JOIN dbo.UserProfiles p ON p.UserID=u.UserID WHERE u.UserID=@ID;"
                + PortfolioQueries, conn))
            {
                cmd.Parameters.AddWithValue("@ID", userId);
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    var users = Read<UserLogin>(reader);
                    if (users.Count == 0) return null;
                    if (!reader.NextResult()) throw new InvalidOperationException("Missing profile results.");
                    // Return only after all result sets have been read successfully.
                    return new UserSummaryData { User=users[0], Portfolio=ReadPortfolio(reader) };
                }
            }
        }

        public static PortfolioSaveData Load(int userId)
        {
            using (var conn = DatabaseConnection.GetConnection())
            using (var cmd = new SqlCommand(PortfolioQueries, conn))
            {
                cmd.Parameters.AddWithValue("@ID", userId);
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    return ReadPortfolio(reader);
                }
            }
        }

        private static PortfolioSaveData ReadPortfolio(SqlDataReader reader)
        {
            var profiles = Read<UserProfile>(reader);
            var data = new PortfolioSaveData { Profile=profiles.Count == 0 ? null : profiles[0] };
            Next(reader); data.Educations=Read<Education>(reader);
            Next(reader); data.Skills=Read<Skill>(reader);
            Next(reader); data.Affiliations=Read<Affiliation>(reader);
            Next(reader); data.Hobbies=Read<Hobby>(reader);
            Next(reader); data.SocialLinks=Read<SocialLink>(reader);
            return data;
        }
        private static void Next(SqlDataReader reader)
        { if (!reader.NextResult()) throw new InvalidOperationException("Incomplete portfolio results."); }

        private static List<T> Read<T>(SqlDataReader reader) where T : new()
        {
            var properties = new PropertyInfo[reader.FieldCount];
            for (int i = 0; i < properties.Length; i++) properties[i] = typeof(T).GetProperty(reader.GetName(i));
            var list = new List<T>();
            while (reader.Read())
            {
                var item = new T();
                for (int i = 0; i < properties.Length; i++)
                    if (properties[i]?.CanWrite == true && !reader.IsDBNull(i)) properties[i].SetValue(item, reader.GetValue(i));
                list.Add(item);
            }
            return list;
        }
    }
}
