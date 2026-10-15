using System;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using _241611JalopPersonalWebsite.Backend.Common;
using _241611JalopPersonalWebsite.Model;
using _241611JalopPersonalWebsite.Repository;
internal static class FinalAuditBackend
{
    private static string connection;
    private static object Sql(string sql) { using(var c=new SqlConnection(connection)) {c.Open(); return new SqlCommand(sql,c).ExecuteScalar();} }
    [STAThread]
    private static int Main(string[] args)
    {
        string root=Path.GetFullPath(args.Length>0?args[0]:".");
        string db=File.ReadAllText(Path.Combine(root,"Tests/Temp/web-database.txt")).Trim();
        if(!Regex.IsMatch(db,"^PortfolioAudit_[a-f0-9]{32}$")) throw new Exception("Unsafe test database.");
        connection=@"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog="+db+";Integrated Security=True;";
        Environment.SetEnvironmentVariable("SQLCONNSTR_DefaultConnection",connection);
        using(var output=new StreamWriter(Path.Combine(root,"Tests/Temp/final-audit-backend.txt")))
        {
            Action<string> report=s=>{Console.WriteLine(s);output.WriteLine(s);output.Flush();};
            bool objectRejected=false;
            try { PortfolioSaveData.ParseSection<Skill>("{}","Skills"); } catch(ArgumentException) { objectRejected=true; }
            report("JSON object rejected without clearing skills: "+objectRejected);
            bool seeded=UserRepository.Login("admin@iptwebsite.com","admin123",out var seededUser,out _);
            report("Known default seed password authenticates administrator: "+(seeded&&seededUser.Role=="Admin"));
            bool created=UserRepository.AdminCreateUser(new string('N',70),"Fixture","backend-long@example.test","Example-password","User",true,out string error);
            report("Admin overlong name accepted: "+created+"; stored length: "+Sql("SELECT LEN(FirstName) FROM dbo.UserProfiles p JOIN dbo.Users u ON u.UserID=p.UserID WHERE u.Email=N'backend-long@example.test'"));
            string uploads=Path.Combine(root,"Tests/Temp/Site/Uploads/Profiles");
            byte[] pixels=new byte[1920*1080*3];new Random(42).NextBytes(pixels);
            var bitmap=BitmapSource.Create(1920,1080,96,96,PixelFormats.Rgb24,null,pixels,1920*3);
            var jpeg=new JpegBitmapEncoder {QualityLevel=35};jpeg.Frames.Add(BitmapFrame.Create(bitmap));
            using(var input=new MemoryStream())
            {
                jpeg.Save(input);input.Position=0;
                string stored=ProfileImages.Save(input,"photo.jpg",input.Length,987,uploads);
                long length=new FileInfo(Path.Combine(uploads,Path.GetFileName(stored))).Length;
                report("Image re-encoding bytes: input="+input.Length+"; stored PNG="+length);
                ProfileImages.Delete(stored,uploads);
            }
            // Make a private synthetic avatar available for the anonymous static-file probe.
            byte[] small=new byte[12];var png=new PngBitmapEncoder();
            png.Frames.Add(BitmapFrame.Create(BitmapSource.Create(2,2,96,96,PixelFormats.Rgb24,null,small,6)));
            using(var file=File.Create(Path.Combine(uploads,"audit-private.png"))) png.Save(file);
            Sql("UPDATE dbo.UserProfiles SET ProfileImagePath=N'~/Uploads/Profiles/audit-private.png',IsPublic=0 WHERE UserID=(SELECT UserID FROM dbo.Users WHERE Email=N'audit-admin@example.test')");
            bool deletionUser=UserRepository.AdminCreateUser("Image","Deletion","backend-delete@example.test","Example-password","User",true,out _);
            if(!deletionUser) throw new Exception("Deletion fixture could not be created.");
            int id=Convert.ToInt32(Sql("SELECT UserID FROM dbo.Users WHERE Email=N'backend-delete@example.test'"));
            string orphan=Path.Combine(uploads,"audit-deleted.png");File.Copy(Path.Combine(uploads,"audit-private.png"),orphan,true);
            Sql("UPDATE dbo.UserProfiles SET ProfileImagePath=N'~/Uploads/Profiles/audit-deleted.png' WHERE UserID="+id);
            report("Account deletion returned success: "+UserRepository.DeleteUser(id,out _)+"; avatar file remains: "+File.Exists(orphan));
            int count=0;
            foreach(string image in Directory.GetFiles(Path.Combine(root,"241611JalopPersonalWebsite/Uploads/Profiles")))
            {
                if(!Regex.IsMatch(image,@"\.(jpg|jpeg|png|webp)$",RegexOptions.IgnoreCase))continue;
                using(var stream=File.OpenRead(image)) {var decoder=BitmapDecoder.Create(stream,BitmapCreateOptions.PreservePixelFormat,BitmapCacheOption.OnLoad);if(decoder.Frames.Count<1)throw new Exception("No image frame.");count++;}
            }
            report("Existing image assets decoded successfully: "+count);
        }
        return 0;
    }
}
