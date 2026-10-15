using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Reflection;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.Repository
{
    public static class PortfolioReadRepository
    {
        public static PortfolioSaveData Load(int userId)
        {
            using (var conn = DatabaseConnection.GetConnection())
            using (var cmd = new SqlCommand(@"
                SELECT * FROM dbo.UserProfiles WHERE UserID=@ID;
                SELECT * FROM dbo.Educations WHERE UserID=@ID ORDER BY EducationID;
                SELECT * FROM dbo.Skills WHERE UserID=@ID ORDER BY SkillID;
                SELECT * FROM dbo.Affiliations WHERE UserID=@ID ORDER BY AffiliationID;
                SELECT * FROM dbo.Hobbies WHERE UserID=@ID ORDER BY HobbyID;
                SELECT * FROM dbo.SocialLinks WHERE UserID=@ID ORDER BY SocialLinkID;", conn))
            {
                cmd.Parameters.AddWithValue("@ID", userId);
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    var profiles = Read<UserProfile>(reader);
                    var data = new PortfolioSaveData { Profile = profiles.Count == 0 ? null : profiles[0] };
                    reader.NextResult(); data.Educations = Read<Education>(reader);
                    reader.NextResult(); data.Skills = Read<Skill>(reader);
                    reader.NextResult(); data.Affiliations = Read<Affiliation>(reader);
                    reader.NextResult(); data.Hobbies = Read<Hobby>(reader);
                    reader.NextResult(); data.SocialLinks = Read<SocialLink>(reader);
                    return data;
                }
            }
        }

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
