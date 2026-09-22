-- ==========================================================
-- Migration Script: 02_Alter_Profile_Affiliations_SocialLinks
-- 1. Adds Description column to dbo.UserProfiles
-- 2. Creates dbo.Affiliations table and foreign key index
-- 3. Creates dbo.SocialLinks table and foreign key index
-- ==========================================================

USE IPTPersonalWebsite;
GO

-- 1. Add Description column to UserProfiles if it does not exist
IF COL_LENGTH(N'dbo.UserProfiles', N'Description') IS NULL
BEGIN
    ALTER TABLE dbo.UserProfiles
    ADD Description NVARCHAR(MAX) NULL;

    PRINT 'Column Description added to dbo.UserProfiles successfully.';
END
ELSE
BEGIN
    PRINT 'Column Description already exists in dbo.UserProfiles. Skipped.';
END
GO

-- 2. Create Affiliations (Organizations) Table if it does not exist
IF OBJECT_ID(N'dbo.Affiliations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Affiliations (
        AffiliationID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        OrganizationName NVARCHAR(150) NOT NULL,
        Position NVARCHAR(100) NOT NULL,
        StartYear NVARCHAR(10) NOT NULL, -- Stored as text (e.g., '2021')
        EndYear NVARCHAR(10) NULL,       -- Stored as text (e.g., '2023' or 'Present')
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Affiliations_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Affiliations PRIMARY KEY CLUSTERED (AffiliationID ASC),
        CONSTRAINT FK_Affiliations_Users FOREIGN KEY (UserID) 
            REFERENCES dbo.Users (UserID) 
            ON DELETE CASCADE
    );

    -- Foreign Key Index for performance
    CREATE NONCLUSTERED INDEX IX_Affiliations_UserID ON dbo.Affiliations (UserID ASC);

    PRINT 'Table dbo.Affiliations and index IX_Affiliations_UserID created successfully.';
END
ELSE
BEGIN
    PRINT 'Table dbo.Affiliations already exists. Migration skipped.';
END
GO

-- 3. Create SocialLinks Table if it does not exist
IF OBJECT_ID(N'dbo.SocialLinks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SocialLinks (
        SocialLinkID INT IDENTITY(1,1) NOT NULL,
        UserID INT NOT NULL,
        SocialLinkName NVARCHAR(50) NOT NULL, -- e.g., 'GitHub', 'LinkedIn', 'Facebook', 'Instagram'
        Link NVARCHAR(500) NOT NULL,          -- e.g., 'https://github.com/username'
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_SocialLinks_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_SocialLinks PRIMARY KEY CLUSTERED (SocialLinkID ASC),
        CONSTRAINT FK_SocialLinks_Users FOREIGN KEY (UserID) 
            REFERENCES dbo.Users (UserID) 
            ON DELETE CASCADE
    );

    -- Foreign Key Index for performance
    CREATE NONCLUSTERED INDEX IX_SocialLinks_UserID ON dbo.SocialLinks (UserID ASC);

    PRINT 'Table dbo.SocialLinks and index IX_SocialLinks_UserID created successfully.';
END
ELSE
BEGIN
    PRINT 'Table dbo.SocialLinks already exists. Migration skipped.';
END
GO
