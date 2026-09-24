-- ==========================================================
-- Migration Script: 03_Add_WorkExperience_Projects_Gallery
-- Creates tables for:
-- 1. dbo.WorkExperiences (Work experience history)
-- 2. dbo.AcademicProjects (Academic projects and roles)
-- 3. dbo.GalleryImages (Image carousel for personal portfolio)
-- Safe to re-run (idempotent checks with OBJECT_ID)
-- ==========================================================

-- Select target database if running locally; if running on remote hosted DB, ensure current connection is selected.
-- USE IPTPersonalWebsite;
-- GO

-- ==========================================================
-- 1. Create WorkExperiences Table
-- ==========================================================
IF OBJECT_ID(N'dbo.WorkExperiences', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.WorkExperiences (
        WorkExperienceID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        Position NVARCHAR(100) NOT NULL,
        Company NVARCHAR(150) NOT NULL,
        JobDescription NVARCHAR(MAX) NULL,
        StartYear NVARCHAR(10) NOT NULL, -- e.g., '2022'
        EndYear NVARCHAR(10) NULL,       -- e.g., '2024' or 'Present'
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_WorkExperiences_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_WorkExperiences PRIMARY KEY CLUSTERED (WorkExperienceID ASC),
        CONSTRAINT FK_WorkExperiences_Users FOREIGN KEY (UserID) 
            REFERENCES dbo.Users (UserID) 
            ON DELETE CASCADE
    );

    -- Foreign Key Index for performance
    CREATE NONCLUSTERED INDEX IX_WorkExperiences_UserID ON dbo.WorkExperiences (UserID ASC);

    PRINT 'Table dbo.WorkExperiences and index IX_WorkExperiences_UserID created successfully.';
END
ELSE
BEGIN
    PRINT 'Table dbo.WorkExperiences already exists. Skipped.';
END
GO

-- ==========================================================
-- 2. Create AcademicProjects Table
-- ==========================================================
IF OBJECT_ID(N'dbo.AcademicProjects', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AcademicProjects (
        ProjectID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        ProjectTitle NVARCHAR(150) NOT NULL,
        Role NVARCHAR(100) NOT NULL,     -- e.g., 'Lead Developer', 'UI/UX Designer', 'Team Leader'
        ProjectDescription NVARCHAR(MAX) NULL,
        StartYear NVARCHAR(10) NOT NULL, -- e.g., '2023'
        EndYear NVARCHAR(10) NULL,       -- e.g., '2024' or 'Present'
        ProjectUrl NVARCHAR(500) NULL,   -- Optional demo or GitHub repository link
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_AcademicProjects_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_AcademicProjects PRIMARY KEY CLUSTERED (ProjectID ASC),
        CONSTRAINT FK_AcademicProjects_Users FOREIGN KEY (UserID) 
            REFERENCES dbo.Users (UserID) 
            ON DELETE CASCADE
    );

    -- Foreign Key Index for performance
    CREATE NONCLUSTERED INDEX IX_AcademicProjects_UserID ON dbo.AcademicProjects (UserID ASC);

    PRINT 'Table dbo.AcademicProjects and index IX_AcademicProjects_UserID created successfully.';
END
ELSE
BEGIN
    PRINT 'Table dbo.AcademicProjects already exists. Skipped.';
END
GO

-- ==========================================================
-- 3. Create GalleryImages Table (Carousel Images)
-- ==========================================================
IF OBJECT_ID(N'dbo.GalleryImages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.GalleryImages (
        GalleryImageID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        ImagePath NVARCHAR(500) NOT NULL, -- Image file URL/path (e.g., '~/Uploads/Gallery/img1.jpg')
        Caption NVARCHAR(255) NULL,       -- Caption or title displayed over or below carousel slide
        DisplayOrder INT NOT NULL CONSTRAINT DF_GalleryImages_DisplayOrder DEFAULT 0, -- Ordering sequence in carousel
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_GalleryImages_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_GalleryImages PRIMARY KEY CLUSTERED (GalleryImageID ASC),
        CONSTRAINT FK_GalleryImages_Users FOREIGN KEY (UserID) 
            REFERENCES dbo.Users (UserID) 
            ON DELETE CASCADE
    );

    -- Foreign Key Index for performance
    CREATE NONCLUSTERED INDEX IX_GalleryImages_UserID ON dbo.GalleryImages (UserID ASC);

    PRINT 'Table dbo.GalleryImages and index IX_GalleryImages_UserID created successfully.';
END
ELSE
BEGIN
    PRINT 'Table dbo.GalleryImages already exists. Skipped.';
END
GO
