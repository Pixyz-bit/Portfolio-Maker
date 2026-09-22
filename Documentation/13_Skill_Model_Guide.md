# 13 - Skill Model Guide

## 1. What is the `Skill` Model?
The **`Skill`** model represents an individual skill entry associated with a user's account in the personal website system.
Because each user can showcase multiple programming languages, tools, frameworks, and proficiencies (e.g., C#, ASP.NET, SQL, JavaScript, React), `Skill` models a **1-to-Many** relationship with the `Users` table.

---

## 2. SQL Schema Mapping
The model maps directly to the **`dbo.Skills`** table defined in `01_Schema.sql`:

| Column | Data Type | Constraint | C# Model Property | Description |
| :--- | :--- | :--- | :--- | :--- |
| `SkillID` | `INT` | `IDENTITY(1,1)`, PK | `skill.SkillID` | Primary key auto-incremented by SQL Server |
| `UserID` | `INT` | FK to `dbo.Users` | `skill.UserID` | Foreign key linking skill to specific user |
| `SkillName` | `NVARCHAR(100)` | `NOT NULL` | `skill.SkillName` | Name of skill (e.g. 'C#', 'SQL Server', 'UI/UX') |
| `SkillDescription`| `NVARCHAR(MAX)` | `NULL` | `skill.SkillDescription` | Optional description or proficiency level |
| `CreatedAt` | `DATETIME2` | `DEFAULT SYSUTCDATETIME()` | `skill.CreatedAt` | UTC timestamp when record was created |

---

## 3. Directory & Namespace Convention
- **File Location**: `241611JalopPersonalWebsite/Model/Skill.cs`
- **Namespace**: `_241611JalopPersonalWebsite.Model`

To use the model in any Web Forms code-behind (`.aspx.cs`), add:
```csharp
using _241611JalopPersonalWebsite.Model;
```

---

## 4. Entire Code Snippet for `Skill.cs`

File: `241611JalopPersonalWebsite/Model/Skill.cs`

```csharp
using System;

namespace _241611JalopPersonalWebsite.Model
{
    public class Skill
    {
        public int SkillID { get; set; }
        public int UserID { get; set; }
        public string SkillName { get; set; }
        public string SkillDescription { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
```

---

## 5. How to Use the `Skill` Model in ASP.NET Web Forms

### Example 1: Creating and Populating a Model from Form Controls
```csharp
protected void btnAddSkill_Click(object sender, EventArgs e)
{
    int currentUserId = Convert.ToInt32(Session["UserID"]);

    // Instantiate and bundle inputs into Skill model
    Skill newSkill = new Skill
    {
        UserID = currentUserId,
        SkillName = txtSkillName.Text.Trim(),
        SkillDescription = string.IsNullOrWhiteSpace(txtSkillDescription.Text) ? null : txtSkillDescription.Text.Trim()
    };

    // Ready to be passed to SkillRepository.Create(newSkill, out string error)
}
```

### Example 2: Binding a List of Skills to a `Repeater` or `GridView`
```csharp
// In your page load or refresh method:
List<Skill> skills = SkillRepository.GetByUserId(currentUserId, out string error);

rptSkills.DataSource = skills;
rptSkills.DataBind();
```

---

## 6. Sequential Documentation Index
- `01_Models_Guide.md`: Model architecture and `UserLogin` model.
- `02_UserRepository_Guide.md`: User repository (`Create`, `Login`, `ChangePassword`, `UpdateEmail`).
- `03_UserProfile_Guide.md`: Personal profile model and SQL schema mapping.
- `04_UserProfileRepository_Guide.md`: User profile repository (`Create`, `Update`, `GetByUserId`, `GetByProfileId`).
- `05_SocialLink_Model_Guide.md`: Social links model and schema mapping.
- `06_SocialLinkRepository_Guide.md`: Social links repository (full CRUD operations).
- `07_Hobby_Model_Guide.md`: Hobby model and web form walkthrough.
- `08_HobbyRepository_Guide.md`: Hobby repository (full CRUD operations).
- `09_Affiliation_Model_Guide.md`: Affiliation model and schema mapping.
- `10_AffiliationRepository_Guide.md`: Affiliation repository (full CRUD operations).
- `11_Education_Model_Guide.md`: Education model and schema mapping.
- `12_EducationRepository_Guide.md`: Education repository (full CRUD operations).
- `13_Skill_Model_Guide.md`: Skill model and SQL schema mapping.
