# 03 - UserProfile Model Guide & Schema Mapping

## 1. What is the `UserProfile` Model?
The **`UserProfile`** model represents the personal, contact, and biographical details of a user.
While `UserLogin` handles authentication and sign-in credentials in `dbo.Users`, `UserProfile` represents the portfolio profile data stored in `dbo.UserProfiles`.

---

## 2. SQL Schema Mapping
This model maps directly to **`dbo.UserProfiles`** created in `01_Schema.sql` and altered in `02_Alter_Profile_Affiliations_SocialLinks.sql`:

| C# Property | C# Type | SQL Column | SQL Data Type | Notes |
| :--- | :--- | :--- | :--- | :--- |
| `ProfileID` | `int` | `ProfileID` | `INT IDENTITY(1,1)` | Primary Key |
| `UserID` | `int` | `UserID` | `INT` | Foreign Key to `dbo.Users.UserID` |
| `FirstName` | `string` | `FirstName` | `NVARCHAR(50)` | Required in database |
| `LastName` | `string` | `LastName` | `NVARCHAR(50)` | Required in database |
| `Birthday` | `DateTime?` | `Birthday` | `DATE NULL` | Nullable (`DateTime?`) |
| `Address` | `string` | `Address` | `NVARCHAR(255) NULL` | Optional home/office address |
| `ContactEmail` | `string` | `ContactEmail` | `NVARCHAR(255) NULL` | Public contact email |
| `ContactNum` | `string` | `ContactNum` | `NVARCHAR(30) NULL` | Phone/mobile number |
| `ProfileImagePath` | `string` | `ProfileImagePath` | `NVARCHAR(500) NULL` | Relative path to uploaded avatar |
| `Description` | `string` | `Description` | `NVARCHAR(MAX) NULL` | Bio / About Me (from Migration 02) |
| `UpdatedAt` | `DateTime` | `UpdatedAt` | `DATETIME2` | Last update timestamp |

> [!NOTE]
> **Why `DateTime?` for Birthday?**
> In C#, `DateTime` is a value type that cannot be `null`. By adding the `?` (`DateTime?`), it becomes a **nullable** type matching the SQL column `Birthday DATE NULL`.

---

## 3. Entire Code Snippet for `UserProfile.cs`

File: `241611JalopPersonalWebsite/Model/UserProfile.cs`

```csharp
using System;

namespace _241611JalopPersonalWebsite.Model
{
    /// <summary>
    /// Model class representing the personal profile details of a user.
    /// Maps directly to the dbo.UserProfiles table in IPTPersonalWebsite database.
    /// </summary>
    public class UserProfile
    {
        public int ProfileID { get; set; }
        public int UserID { get; set; }

        public string FirstName { get; set; }
        public string LastName { get; set; }
        public DateTime? Birthday { get; set; }

        public string Address { get; set; }
        public string ContactEmail { get; set; }
        public string ContactNum { get; set; }

        public string ProfileImagePath { get; set; }
        public string Description { get; set; }

        public DateTime UpdatedAt { get; set; }

        // Helper property that combines first and last name
        public string FullName => $"{FirstName} {LastName}".Trim();
    }
}
```

---

## 4. Sample Instructions: Step-by-Step Walkthrough

Follow these sequential steps to implement and use the `UserProfile` model in your application:

### Step 1: Create the Model Class in Visual Studio
1. Open Visual Studio.
2. In the **Solution Explorer** panel, expand the `241611JalopPersonalWebsite` project.
3. Right-click the **`Model`** folder &rarr; Select **Add** &rarr; **Class...**.
4. Set the class name to **`UserProfile.cs`** and click **Add**.
5. Paste the entire code snippet from Section 3 above.

---

### Step 2: Sample ASPX Web Form Markup (`EditProfile.aspx`)
Below is a sample form markup demonstrating the controls corresponding to each property of `UserProfile`:

```html
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditProfile.aspx.cs" Inherits="_241611JalopPersonalWebsite.User.EditProfile" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Edit Profile</title>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <div>
            <h2>My Profile</h2>

            <!-- Message Label -->
            <asp:Label ID="lblStatus" runat="server" ForeColor="Red"></asp:Label><br /><br />

            <!-- First Name -->
            <label>First Name:</label><br />
            <asp:TextBox ID="txtFirstName" runat="server"></asp:TextBox><br /><br />

            <!-- Last Name -->
            <label>Last Name:</label><br />
            <asp:TextBox ID="txtLastName" runat="server"></asp:TextBox><br /><br />

            <!-- Birthday -->
            <label>Birthday (YYYY-MM-DD):</label><br />
            <asp:TextBox ID="txtBirthday" runat="server" TextMode="Date"></asp:TextBox><br /><br />

            <!-- Address -->
            <label>Address:</label><br />
            <asp:TextBox ID="txtAddress" runat="server"></asp:TextBox><br /><br />

            <!-- Public Contact Email -->
            <label>Contact Email:</label><br />
            <asp:TextBox ID="txtContactEmail" runat="server" TextMode="Email"></asp:TextBox><br /><br />

            <!-- Contact Number -->
            <label>Contact Number:</label><br />
            <asp:TextBox ID="txtContactNum" runat="server"></asp:TextBox><br /><br />

            <!-- Profile Image Upload -->
            <label>Profile Picture:</label><br />
            <asp:FileUpload ID="fileProfileImage" runat="server" /><br /><br />

            <!-- Bio / Description -->
            <label>About Me (Bio):</label><br />
            <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" Columns="40"></asp:TextBox><br /><br />

            <!-- Submit Button -->
            <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes" OnClick="btnSaveProfile_Click" />
        </div>
    </form>
</body>
</html>
```

---

### Step 3: Sample Code-Behind Implementation (`EditProfile.aspx.cs`)
In the code-behind, bundle the form inputs into the `UserProfile` model:

```csharp
using System;
using System.IO;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite.User
{
    public partial class EditProfile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Ensure user is logged in
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Optional: Pre-populate existing profile data from DB
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            int currentUserId = Convert.ToInt32(Session["UserID"]);

            // 1. Parse Nullable Birthday
            DateTime? userBirthday = null;
            if (DateTime.TryParse(txtBirthday.Text.Trim(), out DateTime parsedDate))
            {
                userBirthday = parsedDate;
            }

            // 2. Handle Profile Image Upload (if any)
            string imagePath = null;
            if (fileProfileImage.HasFile)
            {
                string extension = Path.GetExtension(fileProfileImage.FileName).ToLower();
                if (extension == ".jpg" || extension == ".png" || extension == ".jpeg")
                {
                    string fileName = $"user_{currentUserId}_{DateTime.Now.Ticks}{extension}";
                    string saveDir = Server.MapPath("~/Uploads/Profiles/");

                    if (!Directory.Exists(saveDir))
                    {
                        Directory.CreateDirectory(saveDir);
                    }

                    fileProfileImage.SaveAs(Path.Combine(saveDir, fileName));
                    imagePath = $"~/Uploads/Profiles/{fileName}";
                }
                else
                {
                    lblStatus.Text = "Only JPG and PNG image formats are allowed.";
                    return;
                }
            }

            // 3. Bundle everything into the UserProfile model
            UserProfile profile = new UserProfile
            {
                UserID = currentUserId,
                FirstName = txtFirstName.Text.Trim(),
                LastName = txtLastName.Text.Trim(),
                Birthday = userBirthday,
                Address = txtAddress.Text.Trim(),
                ContactEmail = txtContactEmail.Text.Trim(),
                ContactNum = txtContactNum.Text.Trim(),
                ProfileImagePath = imagePath,
                Description = txtDescription.Text.Trim()
            };

            // 4. Pass the model to your profile repository:
            // bool success = ProfileRepository.SaveProfile(profile, out string error);
            // if (success) { lblStatus.Text = "Profile updated successfully!"; }
        }
    }
}
```

---

### Step 4: Sample Display on Portfolio Page (`PortfolioTemplate.aspx.cs`)
When rendering the public portfolio page, load the model and bind its values to UI elements:

```csharp
using System;
using System.Web.UI;
using _241611JalopPersonalWebsite.Model;

namespace _241611JalopPersonalWebsite
{
    public partial class PortfolioTemplate : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Example: Load user profile from database
                // UserProfile profile = ProfileRepository.GetProfileByUserId(1);

                // Sample usage:
                // lblFullName.Text = profile.FullName;             // Uses computed FullName
                // lblBio.Text = profile.Description;               // Bio from Migration 02
                // lblContact.Text = profile.ContactEmail;          // Public contact email
                // imgProfile.ImageUrl = string.IsNullOrEmpty(profile.ProfileImagePath)
                //                      ? "~/Images/default.png"
                //                      : profile.ProfileImagePath;
            }
        }
    }
}
```

---

## 5. Sequential Documentation Index
- `01_Models_Guide.md`: Model architecture and `UserLogin` model.
- `02_UserRepository_Guide.md`: User repository, sign-up with transactions, and authentication.
- `03_UserProfile_Guide.md`: Personal profile model, SQL schema mapping, and step-by-step form walkthrough.
