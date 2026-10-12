-- ==========================================================
-- Migration Script: 04_Add_IsPublic_To_UserProfiles
-- 1. Adds IsPublic column to dbo.UserProfiles if not existing
-- 2. Updates stored procedures to support portfolio visibility
-- ==========================================================

USE IPTPersonalWebsite;
GO

-- 1. Add IsPublic Column (Defaults to 1 = Public)
IF COL_LENGTH(N'dbo.UserProfiles', N'IsPublic') IS NULL
BEGIN
    ALTER TABLE dbo.UserProfiles
    ADD IsPublic BIT NOT NULL CONSTRAINT DF_UserProfiles_IsPublic DEFAULT 1;

    PRINT 'Column IsPublic added to dbo.UserProfiles successfully.';
END
ELSE
BEGIN
    PRINT 'Column IsPublic already exists in dbo.UserProfiles. Skipped.';
END
GO

-- 2. Update sp_CreateUserProfile
CREATE OR ALTER PROCEDURE dbo.sp_CreateUserProfile
    @UserID           INT,
    @FirstName        NVARCHAR(50),
    @LastName         NVARCHAR(50),
    @Birthday         DATE = NULL,
    @Address          NVARCHAR(255) = NULL,
    @ContactEmail     NVARCHAR(255) = NULL,
    @ContactNum       NVARCHAR(30) = NULL,
    @ProfileImagePath NVARCHAR(500) = NULL,
    @Description      NVARCHAR(MAX) = NULL,
    @IsPublic         BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.UserProfiles WHERE UserID = @UserID)
    BEGIN
        RAISERROR('A profile for this user already exists. Use Update instead.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.UserProfiles (
        UserID, 
        FirstName, 
        LastName, 
        Birthday, 
        Address, 
        ContactEmail, 
        ContactNum, 
        ProfileImagePath, 
        Description, 
        IsPublic,
        UpdatedAt
    )
    VALUES (
        @UserID, 
        @FirstName, 
        @LastName, 
        @Birthday, 
        @Address, 
        @ContactEmail, 
        @ContactNum, 
        @ProfileImagePath, 
        @Description, 
        ISNULL(@IsPublic, 1),
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

-- 3. Update sp_UpdateUserProfile
CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserProfile
    @UserID           INT,
    @FirstName        NVARCHAR(50),
    @LastName         NVARCHAR(50),
    @Birthday         DATE = NULL,
    @Address          NVARCHAR(255) = NULL,
    @ContactEmail     NVARCHAR(255) = NULL,
    @ContactNum       NVARCHAR(30) = NULL,
    @ProfileImagePath NVARCHAR(500) = NULL,
    @Description      NVARCHAR(MAX) = NULL,
    @IsPublic         BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.UserProfiles
    SET FirstName = @FirstName,
        LastName = @LastName,
        Birthday = @Birthday,
        Address = @Address,
        ContactEmail = @ContactEmail,
        ContactNum = @ContactNum,
        ProfileImagePath = COALESCE(@ProfileImagePath, ProfileImagePath),
        Description = @Description,
        IsPublic = ISNULL(@IsPublic, IsPublic),
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

-- 4. Update sp_GetUserProfileByUserId
CREATE OR ALTER PROCEDURE dbo.sp_GetUserProfileByUserId
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ProfileID, UserID, FirstName, LastName, Birthday, Address, 
           ContactEmail, ContactNum, ProfileImagePath, Description, UpdatedAt,
           ISNULL(IsPublic, 1) AS IsPublic
    FROM dbo.UserProfiles
    WHERE UserID = @UserID;
END
GO

-- 5. Update sp_GetUserProfileById
CREATE OR ALTER PROCEDURE dbo.sp_GetUserProfileById
    @ProfileID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ProfileID, UserID, FirstName, LastName, Birthday, Address, 
           ContactEmail, ContactNum, ProfileImagePath, Description, UpdatedAt,
           ISNULL(IsPublic, 1) AS IsPublic
    FROM dbo.UserProfiles
    WHERE ProfileID = @ProfileID;
END
GO
