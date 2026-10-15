using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.SessionState;
using _241611JalopPersonalWebsite.Backend.Common;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;

internal static class RegressionTests
{
    private static int passed;
    private static string root, connection;
    [STAThread]
    private static int Main(string[] args)
    {
        root = Path.GetFullPath(args.Length > 0 ? args[0] : ".");
        string database = "PortfolioAudit_" + Guid.NewGuid().ToString("N");
        string master = @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=master;Integrated Security=True;";
        bool keepForWebTests = false;
        try
        {
            using (var conn = new SqlConnection(master)) { conn.Open(); new SqlCommand("CREATE DATABASE [" + database + "]", conn).ExecuteNonQuery(); }
            connection = master.Replace("Initial Catalog=master", "Initial Catalog=" + database);
            Environment.SetEnvironmentVariable("SQLCONNSTR_DefaultConnection", connection);
            string schema = File.ReadAllText(Path.Combine(root, "241611JalopPersonalWebsite/Backend/Database/Migration/01_Schema.sql"));
            RunBatches(schema.Substring(schema.IndexOf("-- 3. Create Users Table", StringComparison.Ordinal)));
            foreach (var migration in new[] { "02_Alter_Profile_Affiliations_SocialLinks.sql", "04_Add_IsPublic_To_UserProfiles.sql", "03_StoredProcedures.sql" })
                RunBatches(Regex.Replace(File.ReadAllText(Path.Combine(root, "241611JalopPersonalWebsite/Backend/Database/Migration/" + migration)), @"(?im)^\s*USE\s+[^\r\n]+;\s*$", ""));
            TestPasswords(); TestSaves(); TestSearch(); TestExecuteOnce(); TestSessions(); TestImages();
            var readBack = PortfolioReadRepository.Load(Convert.ToInt32(Sql("SELECT UserID FROM dbo.Users WHERE Email=N'owner@example.test'")));
            Assert(readBack.Profile.FirstName == "Mira" && readBack.Educations.Count == 1 && readBack.SocialLinks.Count == 1, "batched portfolio reader returns profile and sections");
            if (args.Length > 1 && args[1] == "--prepare-web")
            {
                var admin = new UserLogin { FirstName="Local", LastName="Administrator", Email="audit-admin@example.test", Password="Example-password" };
                if (!UserRepository.Create(admin, admin.Password, out string error)) throw new Exception(error);
                Sql("UPDATE dbo.Users SET Role=N'Admin' WHERE UserID=" + admin.UserID);
                var data = Data(admin.UserID); data.Profile.IsPublic = false;
                if (!PortfolioSaveRepository.Save(data, admin.UserID, out _, out error)) throw new Exception(error);
                // Deliberately unsafe stored content is confined to this disposable fixture.
                Sql("UPDATE dbo.Skills SET SkillName=N'<img src=x onerror=alert(1)>' WHERE UserID=" + admin.UserID);
                Directory.CreateDirectory(Path.Combine(root, "Tests/Temp"));
                File.WriteAllText(Path.Combine(root, "Tests/Temp/web-database.txt"), database);
                keepForWebTests = true;
            }
            Console.WriteLine("PASS: " + passed + " regression assertions.");
            return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
        finally
        {
            HttpContext.Current = null;
            SqlConnection.ClearAllPools();
            if (!keepForWebTests) using (var conn = new SqlConnection(master))
            {
                conn.Open();
                // Only the database created above is eligible for cleanup.
                if (!Regex.IsMatch(database, "^PortfolioAudit_[a-f0-9]{32}$")) throw new InvalidOperationException();
                new SqlCommand("ALTER DATABASE [" + database + "] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [" + database + "]", conn).ExecuteNonQuery();
            }
        }
    }
    private static void Assert(bool condition, string name) { if (!condition) throw new Exception("FAIL: " + name); passed++; Console.WriteLine("PASS: " + name); }
    private static void Reject(Action action, string name) { try { action(); } catch (ArgumentException) { Assert(true, name); return; } throw new Exception("FAIL: " + name); }
    private static object Sql(string sql) { using (var conn = new SqlConnection(connection)) { conn.Open(); return new SqlCommand(sql, conn).ExecuteScalar(); } }
    private static void RunBatches(string sql) { foreach (string batch in Regex.Split(sql, @"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase)) if (!string.IsNullOrWhiteSpace(batch)) Sql(batch); }
    private static string Legacy(string password) { using (var sha = SHA256.Create()) return BitConverter.ToString(sha.ComputeHash(Encoding.UTF8.GetBytes(password))).Replace("-", "").ToLowerInvariant(); }
    private static void TestPasswords()
    {
        string first = PasswordSecurity.Hash("Example-password"), second = PasswordSecurity.Hash("Example-password");
        Assert(first != second, "identical passwords receive unique salts");
        Assert(PasswordSecurity.Verify("Example-password", first, out bool upgrade) && !upgrade, "new password verification");
        Assert(!PasswordSecurity.Verify(first, first, out _) && !PasswordSecurity.Verify("wrong", first, out _), "stored hash and wrong password rejected");
        string old = Legacy("Example-password");
        Assert(PasswordSecurity.Verify("Example-password", old, out upgrade) && upgrade, "legacy SHA-256 password accepted for migration");
        Assert(!PasswordSecurity.Verify(old, old, out _) && !PasswordSecurity.Verify("plaintext", "plaintext", out _), "legacy pass-the-hash and plaintext rejected");
        Sql("INSERT dbo.Users(Email,PasswordHash,Role) VALUES(N'legacy@example.test',N'" + old + "',N'User')");
        Assert(UserRepository.Login("legacy@example.test", "Example-password", out var user, out _) && user.AuthenticationStamp.StartsWith("pbkdf2-sha256$"), "successful legacy login upgrades stored hash");
        Assert(Convert.ToString(Sql("SELECT PasswordHash FROM dbo.Users WHERE Email=N'legacy@example.test'")) == user.AuthenticationStamp, "upgraded credential stamp matches database");
    }
    private static PortfolioSaveData Data(int id)
    {
        return new PortfolioSaveData { Profile = new UserProfile { UserID=id, FirstName="Mira", LastName="Reyes", ContactEmail="public@example.test", IsPublic=true },
            Educations=new List<Education> { new Education { CourseName="IT", University="University", StartYear="2024" } },
            Skills=new List<Skill> { new Skill { SkillName="C#" } },
            Affiliations=new List<Affiliation> { new Affiliation { OrganizationName="Builders",Position="Member",StartYear="2024" } },
            Hobbies=new List<Hobby> { new Hobby { HobbyName="Running" } },
            SocialLinks=new List<SocialLink> { new SocialLink { SocialLinkName="Site",Link="https://example.test/profile" } } };
    }
    private static void TestSaves()
    {
        Reject(() => PortfolioSaveData.ParseSection<Skill>("{bad", "Skills"), "malformed section rejected before writes");
        Reject(() => PortfolioSaveData.ParseSection<Skill>("[null]", "Skills"), "null section item rejected");
        Reject(() => PortfolioSaveData.ParseSection<Skill>("", "Skills"), "missing section rejected rather than cleared");
        var parsed=PortfolioSaveData.ParseSection<Skill>("[{\"skillName\":\"C#\",\"skillDescription\":\"text\"}]", "Skills");
        Assert(parsed[0].SkillName=="C#", "existing lowercase JSON maps to model properties");
        int id=Convert.ToInt32(Sql("INSERT dbo.Users(Email,PasswordHash) VALUES(N'owner@example.test',N'" + Legacy("Example-password") + "'); SELECT SCOPE_IDENTITY();"));
        var data=Data(id);
        Assert(PortfolioSaveRepository.Save(data,id,out _,out string error), "complete portfolio save: " + error);
        Assert(Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo.SocialLinks WHERE UserID="+id))==1, "all sections persisted");
        data.SocialLinks[0].Link="javascript:alert(1)";
        Assert(!PortfolioSaveRepository.Save(data,id,out _,out _) && Convert.ToString(Sql("SELECT SkillName FROM dbo.Skills WHERE UserID="+id))=="C#", "unsafe URL rejected and existing rows preserved");
        data=Data(id); data.Educations[0].University="";
        Assert(!PortfolioSaveRepository.Save(data,id,out _,out _), "incomplete education rejects entire save");
        data=Data(id);
        Assert(!PortfolioSaveRepository.Save(data,999999,out _,out _), "unauthorized actor rejected");
        data.Profile.ProfileImagePath = "https://example.test/tracker.jpg";
        Assert(!PortfolioSaveRepository.Save(data,id,out _,out _), "client-provided external image path rejected");
        RunBatches(@"CREATE TRIGGER dbo.AuditRejectSkill ON dbo.Skills AFTER INSERT AS BEGIN IF EXISTS(SELECT 1 FROM inserted WHERE SkillName=N'reject') THROW 51001, 'Forced test failure', 1; END");
        data=Data(id); data.Profile.FirstName="Changed"; data.Skills[0].SkillName="reject";
        Assert(!PortfolioSaveRepository.Save(data,id,out _,out _), "database insert failure returns failure");
        Assert(Convert.ToString(Sql("SELECT FirstName FROM dbo.UserProfiles WHERE UserID="+id))=="Mira" && Convert.ToString(Sql("SELECT SkillName FROM dbo.Skills WHERE UserID="+id))=="C#" && Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo.Educations WHERE UserID="+id))==1, "transaction rolls back profile and deleted section rows");
        Sql("DROP TRIGGER dbo.AuditRejectSkill");
        data=Data(id); data.Skills.Clear();
        Assert(PortfolioSaveRepository.Save(data,id,out _,out _) && Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo.Skills WHERE UserID="+id))==0, "explicit empty array intentionally clears a section");
        Assert(InputSafety.SafeWebUrl("https://example.test/' onclick='bad").IndexOf("'")<0 && InputSafety.SafeWebUrl("javascript:bad")=="#", "URL output is scheme checked and attribute encoded");
        Assert(!InputSafety.IsWebUrl("https://user:password@example.test/") && InputSafety.SafeImageUrl("~/Uploads/Profiles/../Web.config")=="", "credential URLs and traversing image paths rejected");
    }
    private static void TestSearch()
    {
        for(int n=0;n<27;n++)
        {
            int id=Convert.ToInt32(Sql("INSERT dbo.Users(Email,PasswordHash) VALUES(N'p"+n+"@example.test',N'hash'); SELECT SCOPE_IDENTITY();"));
            Sql("INSERT dbo.UserProfiles(UserID,FirstName,LastName,IsPublic) VALUES("+id+",N'Portfolio',N'"+n+"',"+(n==26?0:1)+"); INSERT dbo.Skills(UserID,SkillName) VALUES("+id+",N'UniqueSkill"+n+"')");
        }
        var first=UserProfileRepository.GetPublicPortfolios(null,1,12,out int total,out string error);
        var second=UserProfileRepository.GetPublicPortfolios(null,2,12,out _,out _);
        Assert(error=="" && first.Count==12 && second.Count==12 && total>=26, "SQL pagination limits rows and reports total");
        Assert(!second.Exists(x=>first.Exists(y=>x.UserID==y.UserID)), "adjacent directory pages do not overlap");
        var bySkill=UserProfileRepository.GetPublicPortfolios("UniqueSkill25",1,12,out total,out _);
        Assert(total==1 && bySkill.Count==1 && bySkill[0].Skills.Contains("UniqueSkill25"), "server search includes skills across all pages");
        Assert(UserProfileRepository.GetPublicPortfolios("UniqueSkill26",1,12,out total,out _).Count==0 && total==0, "private portfolio excluded from search");
        Assert(UserProfileRepository.GetPublicPortfolios("%",1,12,out total,out _).Count==0 && total==0, "search wildcard characters treated literally");
        Assert(UserProfileRepository.GetPublicPortfolios(null,int.MaxValue,12,out total,out _).Count>0, "out-of-range page safely clamps to last page");
    }
    private static void TestExecuteOnce()
    {
        Sql("CREATE TABLE dbo.AuditCounter(Value INT); INSERT dbo.AuditCounter VALUES(0)");
        RunBatches("CREATE PROCEDURE dbo.AuditNoScalar AS BEGIN SET NOCOUNT ON; UPDATE dbo.AuditCounter SET Value=Value+1; END");
        using(var conn=new SqlConnection(connection))
        {
            conn.Open(); using(var cmd=new SqlCommand("dbo.AuditNoScalar",conn))
            {
                cmd.CommandType=CommandType.StoredProcedure;
                try { DatabaseConnection.ExecuteNonQueryCount(cmd); } catch(InvalidOperationException) { }
            }
            Assert(Convert.ToInt32(Sql("SELECT Value FROM dbo.AuditCounter"))==1,"missing scalar result does not execute write twice");
            using(var cmd=new SqlCommand("UPDATE dbo.AuditCounter SET Value=Value+1",conn)) Assert(DatabaseConnection.ExecuteNonQueryCount(cmd)==1,"text command uses one native nonquery execution");
        }
        Assert(Convert.ToInt32(Sql("SELECT Value FROM dbo.AuditCounter"))==2,"text mutation executed once");
    }
    private static void Context(int id,string stamp)
    {
        var context=new HttpContext(new HttpRequest("","http://localhost/test",""),new HttpResponse(new StringWriter()));
        var session=new HttpSessionStateContainer("audit",new SessionStateItemCollection(),new HttpStaticObjectsCollection(),20,true,HttpCookieMode.UseCookies,SessionStateMode.InProc,false);
        SessionStateUtility.AddHttpSessionStateToContext(context,session); HttpContext.Current=context;
        context.Session["UserID"]=id; context.Session["CredentialStamp"]=stamp; context.Session["Role"]="Admin";
    }
    private static void TestSessions()
    {
        int id=Convert.ToInt32(Sql("INSERT dbo.Users(Email,PasswordHash,Role) VALUES(N'session@example.test',N'stamp',N'Admin'); SELECT SCOPE_IDENTITY();"));
        Context(id,"stamp"); Assert(SessionSecurity.CanEdit(SessionSecurity.CurrentUser(),999),"active administrator can edit another portfolio");
        Sql("UPDATE dbo.Users SET Role=N'User' WHERE UserID="+id); Context(id,"stamp");
        Assert(!SessionSecurity.CanEdit(SessionSecurity.CurrentUser(),999),"demotion removes administrator access on next request");
        Sql("UPDATE dbo.Users SET IsActive=0 WHERE UserID="+id); Context(id,"stamp"); Assert(SessionSecurity.CurrentUser()==null,"deactivated session rejected");
        Sql("UPDATE dbo.Users SET IsActive=1,PasswordHash=N'newstamp' WHERE UserID="+id); Context(id,"stamp"); Assert(SessionSecurity.CurrentUser()==null,"password reset invalidates old credential stamp");
        Context(0,""); Assert(!SessionSecurity.CanEdit(SessionSecurity.CurrentUser(),id),"anonymous mutation denied");
        HttpContext.Current=null;
    }
    private static void TestImages()
    {
        string directory=Path.Combine(root,"Tests/Temp/Images"); Directory.CreateDirectory(directory);
        using(var fake=new MemoryStream(Encoding.UTF8.GetBytes("not an image"))) Reject(()=>ProfileImages.Save(fake,"fake.jpg",fake.Length,1,directory),"renamed nonimage rejected");
        using(var input=File.OpenRead(Path.Combine(root,"241611JalopPersonalWebsite/Uploads/Profiles/user_1_eed45dea.webp")))
        {
            string saved=ProfileImages.Save(input,"portrait.webp",input.Length,1,directory);
            Assert(saved.EndsWith(".png") && File.Exists(Path.Combine(directory,Path.GetFileName(saved))),"WebP decoded and re-encoded as PNG");
            ProfileImages.Delete(saved,directory);
            Assert(!File.Exists(Path.Combine(directory,Path.GetFileName(saved))),"unused image cleanup stays inside upload directory");
        }
        using(var input=File.OpenRead(Path.Combine(root,"241611JalopPersonalWebsite/Uploads/Profiles/user_2_cb5bb71a.jpg")))
        {
            string saved=ProfileImages.Save(input,"portrait.jpg",input.Length,1,directory);
            Assert(saved.EndsWith(".png"),"JPEG decoded and re-encoded"); ProfileImages.Delete(saved,directory);
        }
    }
}
