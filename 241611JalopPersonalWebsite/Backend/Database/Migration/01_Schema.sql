-- ==========================================================
-- Master Migration Script: IPTPersonalWebsite
-- Runs all schema creation, constraints, indexes, and seeds
-- ==========================================================

-- 1. Create Database if it does not already exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'IPTPersonalWebsite')
BEGIN
    CREATE DATABASE IPTPersonalWebsite;
END
GO

USE IPTPersonalWebsite;
GO

-- 2. Drop existing tables in reverse dependency order (safe re-run)
IF OBJECT_ID(N'dbo.Skills', N'U') IS NOT NULL DROP TABLE dbo.Skills;
IF OBJECT_ID(N'dbo.Hobbies', N'U') IS NOT NULL DROP TABLE dbo.Hobbies;
IF OBJECT_ID(N'dbo.Educations', N'U') IS NOT NULL DROP TABLE dbo.Educations;
IF OBJECT_ID(N'dbo.UserProfiles', N'U') IS NOT NULL DROP TABLE dbo.UserProfiles;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
GO

-- 3. Create Users Table (Authentication & Admin Controls)
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
GO

-- 4. Create UserProfiles Table (1-to-1 with Users)
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
GO

-- 5. Create Educations Table (1-to-Many with Users)
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
GO

-- 6. Create Hobbies Table (1-to-Many with Users)
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
GO

-- 7. Create Skills Table (1-to-Many with Users)
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
GO

-- 8. Create Indexes on Foreign Keys for Performance
CREATE NONCLUSTERED INDEX IX_Educations_UserID ON dbo.Educations (UserID ASC);
CREATE NONCLUSTERED INDEX IX_Hobbies_UserID ON dbo.Hobbies (UserID ASC);
CREATE NONCLUSTERED INDEX IX_Skills_UserID ON dbo.Skills (UserID ASC);
GO

-- 9. Seed an initial Admin user (PasswordHash represents a pre-hashed string)
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Email = N'admin@iptwebsite.com')
BEGIN
    INSERT INTO dbo.Users (Email, PasswordHash, Role, IsActive)
    VALUES (N'admin@iptwebsite.com', N'$2a$12$e86gLzR67V0J7z7d5yHwU.2Jt18G41m9sZ9wK/72pE9b1GZ9u5BWe', N'Admin', 1);
END
GO
