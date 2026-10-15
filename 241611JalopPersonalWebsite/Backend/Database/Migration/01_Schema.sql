-- Base schema: run against the selected application database.
-- Create the database separately, then use Tools/InitializeDatabase.ps1.

-- 2. Create missing objects without deleting existing data.
-- Re-running this bootstrap preserves rows, constraints and application data.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

-- 3. Create Users Table (Authentication & Admin Controls)
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
CREATE TABLE dbo.Users (
    UserID INT IDENTITY(1,1) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL CONSTRAINT DF_Users_Role DEFAULT 'User', -- 'User' or 'Admin'
    IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT 1,       -- Admin toggle: 1 = Active, 0 = Deactivated
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_Users_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserID ASC),
    CONSTRAINT UQ_Users_Email UNIQUE NONCLUSTERED (Email ASC)
);

-- 4. Create UserProfiles Table (1-to-1 with Users)
IF OBJECT_ID(N'dbo.UserProfiles', N'U') IS NULL
CREATE TABLE dbo.UserProfiles (
    ProfileID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Birthday DATE NULL,
    Address NVARCHAR(255) NULL,
    ContactEmail NVARCHAR(255) NULL,  -- Optional public display email (defaults to Users.Email if NULL)
    ContactNum NVARCHAR(30) NULL,
    ProfileImagePath NVARCHAR(500) NULL,
    UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_UserProfiles_UpdatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UserProfiles PRIMARY KEY CLUSTERED (ProfileID ASC),
    CONSTRAINT UQ_UserProfiles_UserID UNIQUE NONCLUSTERED (UserID ASC),
    CONSTRAINT FK_UserProfiles_Users FOREIGN KEY (UserID) 
        REFERENCES dbo.Users (UserID) 
        ON DELETE CASCADE
);

-- 5. Create Educations Table (1-to-Many with Users)
IF OBJECT_ID(N'dbo.Educations', N'U') IS NULL
CREATE TABLE dbo.Educations (
    EducationID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    CourseName NVARCHAR(150) NOT NULL,
    University NVARCHAR(150) NOT NULL,
    StartYear NVARCHAR(10) NOT NULL,  -- Stored as text (e.g., '2020')
    EndYear NVARCHAR(10) NULL,        -- Stored as text (e.g., '2024' or 'Present')
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Educations_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Educations PRIMARY KEY CLUSTERED (EducationID ASC),
    CONSTRAINT FK_Educations_Users FOREIGN KEY (UserID) 
        REFERENCES dbo.Users (UserID) 
        ON DELETE CASCADE
);

-- 6. Create Hobbies Table (1-to-Many with Users)
IF OBJECT_ID(N'dbo.Hobbies', N'U') IS NULL
CREATE TABLE dbo.Hobbies (
    HobbyID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    HobbyName NVARCHAR(100) NOT NULL,
    HobbyDescription NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Hobbies_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Hobbies PRIMARY KEY CLUSTERED (HobbyID ASC),
    CONSTRAINT FK_Hobbies_Users FOREIGN KEY (UserID) 
        REFERENCES dbo.Users (UserID) 
        ON DELETE CASCADE
);

-- 7. Create Skills Table (1-to-Many with Users)
IF OBJECT_ID(N'dbo.Skills', N'U') IS NULL
CREATE TABLE dbo.Skills (
    SkillID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    SkillName NVARCHAR(100) NOT NULL,
    SkillDescription NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Skills_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Skills PRIMARY KEY CLUSTERED (SkillID ASC),
    CONSTRAINT FK_Skills_Users FOREIGN KEY (UserID) 
        REFERENCES dbo.Users (UserID) 
        ON DELETE CASCADE
);

-- 8. Create Indexes on Foreign Keys for Performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Educations') AND name=N'IX_Educations_UserID')
CREATE NONCLUSTERED INDEX IX_Educations_UserID ON dbo.Educations (UserID ASC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Hobbies') AND name=N'IX_Hobbies_UserID')
CREATE NONCLUSTERED INDEX IX_Hobbies_UserID ON dbo.Hobbies (UserID ASC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id=OBJECT_ID(N'dbo.Skills') AND name=N'IX_Skills_UserID')
CREATE NONCLUSTERED INDEX IX_Skills_UserID ON dbo.Skills (UserID ASC);

COMMIT TRANSACTION;
GO

-- No administrator or password is seeded. After the remaining migrations,
-- run Tools/InitializeAdministrator.ps1 from a trusted operator terminal.
