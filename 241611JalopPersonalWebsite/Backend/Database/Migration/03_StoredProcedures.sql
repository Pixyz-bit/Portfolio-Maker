-- ==========================================================
-- Migration Script: 03_StoredProcedures
-- Database: IPTPersonalWebsite / db69719
-- Description: Master script creating all Stored Procedures 
--              for Users, Profiles, Educations, Skills,
--              Hobbies, Affiliations, SocialLinks & Analytics.
-- Idempotent: Uses CREATE OR ALTER PROCEDURE
-- ==========================================================

USE db69719;
GO

-- =========================================================================
-- 1. AFFILIATIONS STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_InsertAffiliation
    @UserID           INT,
    @OrganizationName NVARCHAR(150),
    @Position         NVARCHAR(100),
    @StartYear        NVARCHAR(10),
    @EndYear          NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Affiliations (
        UserID, 
        OrganizationName, 
        Position, 
        StartYear, 
        EndYear, 
        CreatedAt
    )
    VALUES (
        @UserID, 
        @OrganizationName, 
        @Position, 
        @StartYear, 
        @EndYear, 
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetAffiliationsByUserId
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT AffiliationID, UserID, OrganizationName, Position, StartYear, EndYear, CreatedAt
    FROM dbo.Affiliations
    WHERE UserID = @UserID
    ORDER BY CreatedAt ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetAffiliationById
    @AffiliationID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT AffiliationID, UserID, OrganizationName, Position, StartYear, EndYear, CreatedAt
    FROM dbo.Affiliations
    WHERE AffiliationID = @AffiliationID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateAffiliation
    @AffiliationID    INT,
    @OrganizationName NVARCHAR(150),
    @Position         NVARCHAR(100),
    @StartYear        NVARCHAR(10),
    @EndYear          NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Affiliations
    SET OrganizationName = @OrganizationName,
        Position = @Position,
        StartYear = @StartYear,
        EndYear = @EndYear
    WHERE AffiliationID = @AffiliationID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteAffiliation
    @AffiliationID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Affiliations
    WHERE AffiliationID = @AffiliationID;

    SELECT @@ROWCOUNT;
END
GO

-- =========================================================================
-- 2. EDUCATIONS STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_InsertEducation
    @UserID     INT,
    @CourseName NVARCHAR(150),
    @University NVARCHAR(150),
    @StartYear  NVARCHAR(10),
    @EndYear    NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Educations (
        UserID, 
        CourseName, 
        University, 
        StartYear, 
        EndYear, 
        CreatedAt
    )
    VALUES (
        @UserID, 
        @CourseName, 
        @University, 
        @StartYear, 
        @EndYear, 
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetEducationsByUserId
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT EducationID, UserID, CourseName, University, StartYear, EndYear, CreatedAt
    FROM dbo.Educations
    WHERE UserID = @UserID
    ORDER BY CreatedAt ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetEducationById
    @EducationID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT EducationID, UserID, CourseName, University, StartYear, EndYear, CreatedAt
    FROM dbo.Educations
    WHERE EducationID = @EducationID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateEducation
    @EducationID INT,
    @CourseName  NVARCHAR(150),
    @University  NVARCHAR(150),
    @StartYear   NVARCHAR(10),
    @EndYear     NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Educations
    SET CourseName = @CourseName,
        University = @University,
        StartYear = @StartYear,
        EndYear = @EndYear
    WHERE EducationID = @EducationID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteEducation
    @EducationID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Educations
    WHERE EducationID = @EducationID;

    SELECT @@ROWCOUNT;
END
GO

-- =========================================================================
-- 3. HOBBIES STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_InsertHobby
    @UserID           INT,
    @HobbyName        NVARCHAR(100),
    @HobbyDescription NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Hobbies (
        UserID, 
        HobbyName, 
        HobbyDescription, 
        CreatedAt
    )
    VALUES (
        @UserID, 
        @HobbyName, 
        @HobbyDescription, 
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetHobbiesByUserId
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT HobbyID, UserID, HobbyName, HobbyDescription, CreatedAt
    FROM dbo.Hobbies
    WHERE UserID = @UserID
    ORDER BY CreatedAt ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetHobbyById
    @HobbyID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT HobbyID, UserID, HobbyName, HobbyDescription, CreatedAt
    FROM dbo.Hobbies
    WHERE HobbyID = @HobbyID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateHobby
    @HobbyID          INT,
    @HobbyName        NVARCHAR(100),
    @HobbyDescription NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Hobbies
    SET HobbyName = @HobbyName,
        HobbyDescription = @HobbyDescription
    WHERE HobbyID = @HobbyID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteHobby
    @HobbyID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Hobbies
    WHERE HobbyID = @HobbyID;

    SELECT @@ROWCOUNT;
END
GO

-- =========================================================================
-- 4. SKILLS STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_InsertSkill
    @UserID           INT,
    @SkillName        NVARCHAR(100),
    @SkillDescription NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Skills (
        UserID, 
        SkillName, 
        SkillDescription, 
        CreatedAt
    )
    VALUES (
        @UserID, 
        @SkillName, 
        @SkillDescription, 
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetSkillsByUserId
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SkillID, UserID, SkillName, SkillDescription, CreatedAt
    FROM dbo.Skills
    WHERE UserID = @UserID
    ORDER BY CreatedAt ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetSkillById
    @SkillID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SkillID, UserID, SkillName, SkillDescription, CreatedAt
    FROM dbo.Skills
    WHERE SkillID = @SkillID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateSkill
    @SkillID          INT,
    @SkillName        NVARCHAR(100),
    @SkillDescription NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Skills
    SET SkillName = @SkillName,
        SkillDescription = @SkillDescription
    WHERE SkillID = @SkillID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteSkill
    @SkillID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Skills
    WHERE SkillID = @SkillID;

    SELECT @@ROWCOUNT;
END
GO

-- =========================================================================
-- 5. SOCIAL LINKS STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_InsertSocialLink
    @UserID         INT,
    @SocialLinkName NVARCHAR(50),
    @Link           NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.SocialLinks (
        UserID, 
        SocialLinkName, 
        Link, 
        CreatedAt
    )
    VALUES (
        @UserID, 
        @SocialLinkName, 
        @Link, 
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetSocialLinksByUserId
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SocialLinkID, UserID, SocialLinkName, Link, CreatedAt
    FROM dbo.SocialLinks
    WHERE UserID = @UserID
    ORDER BY CreatedAt ASC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetSocialLinkById
    @SocialLinkID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SocialLinkID, UserID, SocialLinkName, Link, CreatedAt
    FROM dbo.SocialLinks
    WHERE SocialLinkID = @SocialLinkID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateSocialLink
    @SocialLinkID   INT,
    @SocialLinkName NVARCHAR(50),
    @Link           NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.SocialLinks
    SET SocialLinkName = @SocialLinkName,
        Link = @Link
    WHERE SocialLinkID = @SocialLinkID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteSocialLink
    @SocialLinkID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.SocialLinks
    WHERE SocialLinkID = @SocialLinkID;

    SELECT @@ROWCOUNT;
END
GO

-- =========================================================================
-- 6. USER PROFILES STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_CreateUserProfile
    @UserID           INT,
    @FirstName        NVARCHAR(50),
    @LastName         NVARCHAR(50),
    @Birthday         DATE = NULL,
    @Address          NVARCHAR(255) = NULL,
    @ContactEmail     NVARCHAR(255) = NULL,
    @ContactNum       NVARCHAR(30) = NULL,
    @ProfileImagePath NVARCHAR(500) = NULL,
    @Description      NVARCHAR(MAX) = NULL
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
        SYSUTCDATETIME()
    );

    SELECT SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserProfile
    @UserID           INT,
    @FirstName        NVARCHAR(50),
    @LastName         NVARCHAR(50),
    @Birthday         DATE = NULL,
    @Address          NVARCHAR(255) = NULL,
    @ContactEmail     NVARCHAR(255) = NULL,
    @ContactNum       NVARCHAR(30) = NULL,
    @ProfileImagePath NVARCHAR(500) = NULL,
    @Description      NVARCHAR(MAX) = NULL
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
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserProfileByUserId
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ProfileID, UserID, FirstName, LastName, Birthday, Address, 
           ContactEmail, ContactNum, ProfileImagePath, Description, UpdatedAt
    FROM dbo.UserProfiles
    WHERE UserID = @UserID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserProfileById
    @ProfileID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ProfileID, UserID, FirstName, LastName, Birthday, Address, 
           ContactEmail, ContactNum, ProfileImagePath, Description, UpdatedAt
    FROM dbo.UserProfiles
    WHERE ProfileID = @ProfileID;
END
GO

-- =========================================================================
-- 7. DASHBOARD ANALYTICS STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_GetDashboardAnalytics
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        COUNT(*) AS TotalUsers,
        ISNULL(SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END), 0) AS TotalActive,
        ISNULL(SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END), 0) AS TotalInactive
    FROM dbo.Users;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetTotalUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) FROM dbo.Users;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetTotalActiveUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetTotalInactiveUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*) FROM dbo.Users WHERE IsActive = 0;
END
GO

-- =========================================================================
-- 8. USERS & AUTHENTICATION STORED PROCEDURES
-- =========================================================================

CREATE OR ALTER PROCEDURE dbo.sp_RegisterUser
    @Email        NVARCHAR(255),
    @PasswordHash NVARCHAR(255),
    @FirstName    NVARCHAR(50),
    @LastName     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Email = @Email)
    BEGIN
        RAISERROR('An account with this email already exists.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Users (Email, PasswordHash, Role, IsActive, CreatedAt, UpdatedAt)
        VALUES (@Email, @PasswordHash, 'User', 1, SYSUTCDATETIME(), SYSUTCDATETIME());

        DECLARE @NewUserID INT = SCOPE_IDENTITY();

        INSERT INTO dbo.UserProfiles (UserID, FirstName, LastName, UpdatedAt)
        VALUES (@NewUserID, @FirstName, @LastName, SYSUTCDATETIME());

        COMMIT TRANSACTION;

        SELECT @NewUserID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserByEmail
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.UserID, u.Email, u.PasswordHash, u.Role, u.IsActive, u.CreatedAt,
           p.FirstName, p.LastName
    FROM dbo.Users u
    LEFT JOIN dbo.UserProfiles p ON u.UserID = p.UserID
    WHERE u.Email = @Email;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserById
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.UserID, u.Email, u.Role, u.IsActive, u.CreatedAt,
           ISNULL(p.FirstName, '') AS FirstName,
           ISNULL(p.LastName, '') AS LastName
    FROM dbo.Users u
    LEFT JOIN dbo.UserProfiles p ON u.UserID = p.UserID
    WHERE u.UserID = @UserID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetUserPasswordHash
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT PasswordHash FROM dbo.Users WHERE UserID = @UserID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserPassword
    @UserID          INT,
    @NewPasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Users
    SET PasswordHash = @NewPasswordHash,
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserEmail
    @UserID   INT,
    @NewEmail NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Email = @NewEmail AND UserID <> @UserID)
    BEGIN
        RAISERROR('An account with this email already exists.', 16, 1);
        RETURN;
    END

    UPDATE dbo.Users
    SET Email = @NewEmail,
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetAllUsers
    @SearchKeyword NVARCHAR(100) = NULL,
    @StatusFilter  NVARCHAR(20) = NULL,
    @RoleFilter    NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.UserID, u.Email, u.Role, u.IsActive, u.CreatedAt,
           ISNULL(p.FirstName, '') AS FirstName,
           ISNULL(p.LastName, '') AS LastName
    FROM dbo.Users u
    LEFT JOIN dbo.UserProfiles p ON u.UserID = p.UserID
    WHERE (@SearchKeyword IS NULL OR @SearchKeyword = '' OR 
           u.Email LIKE '%' + @SearchKeyword + '%' OR 
           p.FirstName LIKE '%' + @SearchKeyword + '%' OR 
           p.LastName LIKE '%' + @SearchKeyword + '%' OR 
           (p.FirstName + ' ' + p.LastName) LIKE '%' + @SearchKeyword + '%')
      AND (@StatusFilter IS NULL OR @StatusFilter = '' OR
           (@StatusFilter = 'Active' AND u.IsActive = 1) OR
           (@StatusFilter = 'Inactive' AND u.IsActive = 0))
      AND (@RoleFilter IS NULL OR @RoleFilter = '' OR
           u.Role = @RoleFilter)
    ORDER BY u.UserID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ToggleUserStatus
    @UserID   INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Users
    SET IsActive = @IsActive,
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserRole
    @UserID INT,
    @Role   NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Users
    SET Role = @Role,
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_AdminCreateUser
    @Email        NVARCHAR(255),
    @PasswordHash NVARCHAR(255),
    @Role         NVARCHAR(20),
    @IsActive     BIT,
    @FirstName    NVARCHAR(50),
    @LastName     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Email = @Email)
    BEGIN
        RAISERROR('An account with this email address already exists.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Users (Email, PasswordHash, Role, IsActive, CreatedAt, UpdatedAt)
        VALUES (@Email, @PasswordHash, @Role, @IsActive, SYSUTCDATETIME(), SYSUTCDATETIME());

        DECLARE @NewUserID INT = SCOPE_IDENTITY();

        INSERT INTO dbo.UserProfiles (UserID, FirstName, LastName, UpdatedAt)
        VALUES (@NewUserID, @FirstName, @LastName, SYSUTCDATETIME());

        COMMIT TRANSACTION;

        SELECT @NewUserID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_AdminUpdateUser
    @UserID    INT,
    @Email     NVARCHAR(255),
    @Role      NVARCHAR(20),
    @IsActive  BIT,
    @FirstName NVARCHAR(50),
    @LastName  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Email = @Email AND UserID <> @UserID)
    BEGIN
        RAISERROR('The specified email is already in use by another user.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.Users
        SET Email = @Email,
            Role = @Role,
            IsActive = @IsActive,
            UpdatedAt = SYSUTCDATETIME()
        WHERE UserID = @UserID;

        IF EXISTS (SELECT 1 FROM dbo.UserProfiles WHERE UserID = @UserID)
        BEGIN
            UPDATE dbo.UserProfiles
            SET FirstName = @FirstName,
                LastName = @LastName,
                UpdatedAt = SYSUTCDATETIME()
            WHERE UserID = @UserID;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.UserProfiles (UserID, FirstName, LastName, UpdatedAt)
            VALUES (@UserID, @FirstName, @LastName, SYSUTCDATETIME());
        END

        COMMIT TRANSACTION;

        SELECT 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_AdminResetPassword
    @UserID          INT,
    @NewPasswordHash NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Users
    SET PasswordHash = @NewPasswordHash,
        UpdatedAt = SYSUTCDATETIME()
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteUser
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.Users
    WHERE UserID = @UserID;

    SELECT @@ROWCOUNT;
END
GO
