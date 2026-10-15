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
using System.Threading.Tasks;
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
            foreach (var migration in File.ReadAllLines(Path.Combine(root,"241611JalopPersonalWebsite/Backend/Database/Migration/manifest.txt")))
            {
                string script=File.ReadAllText(Path.Combine(root,"241611JalopPersonalWebsite/Backend/Database/Migration",migration));
                Assert(!Regex.IsMatch(script,@"(?im)^\s*(USE|CREATE\s+DATABASE)\b"), "migration keeps selected database: " + migration);
                RunBatches(script);
            }
            TestBootstrap(); TestPasswords(); TestSaves(); TestSchemaRerun(schema); TestAdministrators(); TestSearch(); TestExecuteOnce(); TestSessions(); TestImages();
            TestAccountValidation(); TestAdminPagingAndSummary(); TestImageDeletion();
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
    private static void TestBootstrap()
    {
        Assert(Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo.Users")) == 0, "fresh schema seeds no accounts or predictable credentials");
        Assert(!UserRepository.Login("admin@iptwebsite.com", "admin123", out _, out _), "old default administrator credential cannot log in");
        Assert(!AdministratorSetup.CreateFirst("Local", "Operator", "bootstrap@example.test", "short", out _), "bootstrap rejects short password");
        Assert(AdministratorSetup.CreateFirst("Local", "Operator", "bootstrap@example.test", "Unique-test-password", out _), "operator can create first administrator with supplied credentials");
        Assert(UserRepository.Login("bootstrap@example.test", "Unique-test-password", out var admin, out _) && admin.Role == "Admin" && admin.AuthenticationStamp.StartsWith("pbkdf2-sha256$"), "bootstrap administrator authenticates with a salted password hash");
        Assert(!AdministratorSetup.CreateFirst("Other", "Operator", "second-bootstrap@example.test", "Unique-test-password", out _) && Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo.Users WHERE Role=N'Admin'")) == 1, "bootstrap cannot be reused after an administrator exists");
    }
    private static void TestSchemaRerun(string schema)
    {
        int owner = Convert.ToInt32(Sql("SELECT UserID FROM dbo.Users WHERE Email=N'owner@example.test'"));
        Sql("INSERT dbo.Skills(UserID,SkillName) VALUES(" + owner + ",N'Preserved skill')");
        string[] tables = { "Users", "UserProfiles", "Skills", "Educations", "Hobbies", "Affiliations", "SocialLinks" };
        var counts = new Dictionary<string,int>();
        foreach (var table in tables) counts[table] = Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo." + table));
        RunBatches(schema);
        foreach (var table in tables) Assert(Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo." + table)) == counts[table], "schema rerun preserves " + table + " rows");
        Assert(Convert.ToString(Sql("SELECT SkillName FROM dbo.Skills WHERE UserID=" + owner)) == "Preserved skill", "schema rerun preserves existing content values");
    }
    private static void TestAdministrators()
    {
        int actor = Convert.ToInt32(Sql("SELECT UserID FROM dbo.Users WHERE Email=N'bootstrap@example.test'"));
        string stamp = Convert.ToString(Sql("SELECT PasswordHash FROM dbo.Users WHERE UserID=" + actor));
        Assert(UserRepository.AdminCreateUser("Backup", "Admin", "backup-admin@example.test", "Example-password", "Admin", true, out _), "backup administrator created for guard tests");
        int backup = Convert.ToInt32(Sql("SELECT UserID FROM dbo.Users WHERE Email=N'backup-admin@example.test'"));
        Context(actor, stamp);
        Assert(!UserRepository.AdminUpdateUser(actor,"Changed","Operator","bootstrap@example.test","Admin",false,out var error) && error.Contains("own active session"), "account-settings repository path rejects self-deactivation even with another admin");
        Assert(Convert.ToString(Sql("SELECT FirstName FROM dbo.UserProfiles WHERE UserID=" + actor)) == "Local", "rejected self-deactivation makes no partial account/profile change");
        Assert(!UserRepository.ToggleUserStatus(actor,false,out _) && !UserRepository.DeleteUser(actor,out _), "other status/delete paths reject own active session");
        Sql("UPDATE dbo.Users SET IsActive=0 WHERE UserID=" + backup);
        Assert(!UserRepository.UpdateUserRole(actor,"User",out _) && !UserRepository.AdminUpdateUser(actor,"Local","Operator","bootstrap@example.test","User",true,out _), "all role-edit paths preserve last active administrator");
        HttpContext.Current = null;
        Assert(!UserRepository.ToggleUserStatus(actor,false,out _) && !UserRepository.DeleteUser(actor,out _), "last-admin guard also protects status and deletion without a web session");
        Sql("UPDATE dbo.Users SET IsActive=1 WHERE UserID=" + backup);
        bool first=false, second=false;
        Task.WaitAll(Task.Run(() => { HttpContext.Current=null; first=UserRepository.UpdateUserRole(actor,"User",out _); }),
            Task.Run(() => { HttpContext.Current=null; second=UserRepository.UpdateUserRole(backup,"User",out _); }));
        Assert(first != second && Convert.ToInt32(Sql("SELECT COUNT(*) FROM dbo.Users WHERE Role=N'Admin' AND IsActive=1")) == 1, "concurrent admin demotions cannot remove both active administrators");
        Sql("UPDATE dbo.Users SET Role=N'Admin' WHERE UserID=" + actor);
        Sql("UPDATE dbo.Users SET Role=N'User' WHERE UserID=" + backup);
        Assert(UserRepository.ToggleUserStatus(backup,false,out _) && UserRepository.ToggleUserStatus(backup,true,out _), "ordinary account activation/deactivation still works");
    }
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
        foreach (var json in new[] { "{}", "{\"skills\":[]}", "null", "1", "\"text\"", "true", "[null]", "[1]", "[[]]" })
            Reject(() => PortfolioSaveData.ParseSection<Skill>(json,"Skills"), "non-array or non-object section payload rejected: " + json);
        Assert(PortfolioSaveData.ParseSection<Skill>(" \r\n [] ", "Skills").Count == 0, "explicit empty array remains valid");
        Assert(PortfolioSaveData.ParseSection<Skill>("[{\"skillName\":\"C#\"}]", "Skills")[0].SkillName == "C#", "valid object array remains valid");
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

    private static void TestAccountValidation()
    {
        string tooLong=new string('L',51);
        var account=new UserLogin {FirstName=tooLong,LastName="Boundary",Email="long-name@example.test",Password="Example-password"};
        Assert(!UserRepository.Create(account,account.Password,out var error) && error.Contains("50 characters"), "signup rejects overlong first name rather than truncating");
        account.FirstName="Valid"; account.LastName=tooLong;
        Assert(!UserRepository.Create(account,account.Password,out _), "signup rejects overlong last name");
        Assert(!UserRepository.AdminCreateUser(tooLong,"Boundary","long-admin@example.test","Example-password","User",true,out _), "admin create rejects overlong name");
        int owner=Convert.ToInt32(Sql("SELECT UserID FROM dbo.Users WHERE Email=N'owner@example.test'"));
        Assert(!UserRepository.AdminUpdateUser(owner,tooLong,"Boundary","owner@example.test","User",true,out _), "admin/account edit rejects overlong name");
        var profile=new UserProfile {UserID=owner,FirstName=tooLong,LastName="Boundary"};
        Assert(!UserProfileRepository.Create(profile,out _) && !UserProfileRepository.Update(profile,out _), "legacy profile write helpers also reject overlong names");
        Assert(Convert.ToString(Sql("SELECT FirstName FROM dbo.UserProfiles WHERE UserID="+owner))=="Mira", "rejected overlong update preserves name");
        Assert(!UserRepository.AdminUpdateUser(owner,"Changed","Boundary","owner@example.test","User",true,out _,"short"), "password validation precedes all account writes");
        Assert(Convert.ToString(Sql("SELECT FirstName FROM dbo.UserProfiles WHERE UserID="+owner))=="Mira", "invalid password does not partially save account changes");
        Assert(InputSafety.ValidateAccountFields(new string('L',50),new string('R',50),"boundary@example.test",out _), "exact 50-character names remain valid");
        account.FirstName="Mira"; account.LastName="Reyes"; account.Email="owner@example.test";
        Assert(!UserRepository.Create(account,account.Password,out error) && error.Contains("already exists"), "duplicate signup produces actionable account message");
    }

    private static void TestAdminPagingAndSummary()
    {
        var first=UserRepository.GetUsersPage(null,"","",1,12,out int total,out string error);
        var second=UserRepository.GetUsersPage(null,"","",2,12,out _,out _);
        Assert(error=="" && total>24 && first.Count==12 && second.Count==12, "admin SQL limits each directory page");
        Assert(!first.Exists(x=>second.Exists(y=>y.UserID==x.UserID)), "admin pages do not overlap with deterministic ordering");
        var search=UserRepository.GetUsersPage("p25@example.test","active","user",1,12,out total,out _);
        Assert(search.Count==1 && total==1, "admin search/status/role filters apply across the whole database");
        Assert(UserRepository.GetUsersPage("%","","",1,12,out total,out _).Count==0 && total==0, "admin search wildcard is literal");
        Assert(UserRepository.GetUsersPage(null,"","",int.MaxValue,12,out total,out _).Count>0, "admin out-of-range page clamps safely");
        int owner=Convert.ToInt32(Sql("SELECT UserID FROM dbo.Users WHERE Email=N'owner@example.test'"));
        var summary=PortfolioReadRepository.LoadSummary(owner);
        Assert(summary.User.Email=="owner@example.test" && summary.Portfolio.Profile.FirstName=="Mira" && summary.Portfolio.Educations.Count==1, "one summary batch returns account and all portfolio sections");
        Assert(PortfolioReadRepository.LoadSummary(int.MaxValue)==null, "missing summary account returns no result");
        Sql("EXEC sp_rename N'dbo.Affiliations', N'AuditMissingAffiliations'");
        try {
            bool failed=false; try {PortfolioReadRepository.LoadSummary(owner);} catch(SqlException) {failed=true;}
            Assert(failed,"summary read failure is raised instead of converted to an empty section");
        } finally {Sql("EXEC sp_rename N'dbo.AuditMissingAffiliations',N'Affiliations'");}
    }

    private static void TestImageDeletion()
    {
        string app=Path.Combine(root,"Tests/Temp/DeleteImages");
        foreach (var folder in new[]{"App_Data/ProfileImages","Uploads/Profiles"}) {
            Directory.CreateDirectory(Path.Combine(app,folder));
            string name="delete-"+Guid.NewGuid().ToString("N")+".jpg",stored="~/"+folder+"/"+name,file=Path.Combine(app,folder,name);
            File.WriteAllText(file,"synthetic image file");
            int id=Convert.ToInt32(Sql("INSERT dbo.Users(Email,PasswordHash) VALUES(N'"+name+"@example.test',N'hash'); SELECT SCOPE_IDENTITY();"));
            Sql("INSERT dbo.UserProfiles(UserID,FirstName,LastName,ProfileImagePath) VALUES("+id+",N'Deletion',N'Fixture',N'"+stored+"')");
            Assert(UserRepository.DeleteUser(id,out string error,app) && error=="" && !File.Exists(file), "account deletion removes image from "+folder);
        }
        string shared="~/App_Data/ProfileImages/shared.jpg", sharedFile=Path.Combine(app,"App_Data/ProfileImages/shared.jpg"); File.WriteAllText(sharedFile,"shared");
        int first=Convert.ToInt32(Sql("INSERT dbo.Users(Email,PasswordHash) VALUES(N'shared-one@example.test',N'hash'); SELECT SCOPE_IDENTITY();"));
        int second=Convert.ToInt32(Sql("INSERT dbo.Users(Email,PasswordHash) VALUES(N'shared-two@example.test',N'hash'); SELECT SCOPE_IDENTITY();"));
        Sql("INSERT dbo.UserProfiles(UserID,FirstName,LastName,ProfileImagePath) VALUES("+first+",N'Shared',N'One',N'"+shared+"'),("+second+",N'Shared',N'Two',N'"+shared+"')");
        Assert(UserRepository.DeleteUser(first,out _,app) && File.Exists(sharedFile),"deletion preserves photo still used by another profile");
        Assert(UserRepository.DeleteUser(second,out _,app) && !File.Exists(sharedFile),"final referencing account deletion removes shared photo");
        string outside=Path.Combine(root,"Tests/Temp/outside-photo.jpg");File.WriteAllText(outside,"preserve");
        Assert(!ProfileImages.TryDeleteStored("~/Uploads/Profiles/../../../outside-photo.jpg",app) && File.Exists(outside),"image cleanup rejects paths outside image storage");
    }
}
