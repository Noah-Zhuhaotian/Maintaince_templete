-- Database Initialization Script
-- Simple schema for demo purposes

-- Enable configuration options
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create Users table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Users](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [Username] [nvarchar](100) NOT NULL,
        [Email] [nvarchar](255) NOT NULL,
        [IsActive] [bit] NOT NULL DEFAULT (1),
        [CreatedDate] [datetime2](7) NOT NULL DEFAULT (GETUTCDATE()),
        CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([Id] ASC)
    )
    
    PRINT 'Users table created successfully.'
END
GO

-- Create Items table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Items]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Items](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [Name] [nvarchar](100) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [IsActive] [bit] NOT NULL DEFAULT (1),
        [CreatedDate] [datetime2](7) NOT NULL DEFAULT (GETUTCDATE()),
        CONSTRAINT [PK_Items] PRIMARY KEY CLUSTERED ([Id] ASC)
    )
    
    PRINT 'Items table created successfully.'
END
GO

-- Create UserItems table (relationship between Users and Items)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserItems]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserItems](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [UserId] [int] NOT NULL,
        [ItemId] [int] NOT NULL,
        [AssignedDate] [datetime2](7) NOT NULL DEFAULT (GETUTCDATE()),
        CONSTRAINT [PK_UserItems] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_UserItems_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([Id]),
        CONSTRAINT [FK_UserItems_Items] FOREIGN KEY ([ItemId]) REFERENCES [dbo].[Items] ([Id])
    )
    
    PRINT 'UserItems table created successfully.'
END
GO

-- Insert sample data
-- Add some sample users
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
    AND NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[Users])
BEGIN
    INSERT INTO [dbo].[Users] ([Username], [Email])
    VALUES 
        ('user1', 'user1@example.com'),
        ('user2', 'user2@example.com'),
        ('user3', 'user3@example.com')
    
    PRINT 'Sample users added.'
END
GO

-- Add some sample items
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Items]') AND type in (N'U'))
    AND NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[Items])
BEGIN
    INSERT INTO [dbo].[Items] ([Name], [Description])
    VALUES 
        ('Item 1', 'Description for Item 1'),
        ('Item 2', 'Description for Item 2'),
        ('Item 3', 'Description for Item 3'),
        ('Item 4', 'Description for Item 4'),
        ('Item 5', 'Description for Item 5')
    
    PRINT 'Sample items added.'
END
GO

-- Create relationships between users and items
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserItems]') AND type in (N'U'))
    AND NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[UserItems])
BEGIN
    INSERT INTO [dbo].[UserItems] ([UserId], [ItemId])
    VALUES 
        (1, 1),
        (1, 2),
        (2, 3),
        (3, 4),
        (3, 5)
    
    PRINT 'Sample user-item relationships added.'
END
GO

-- Create a simple view for demonstration
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_UserItems]'))
BEGIN
    EXEC('
    CREATE VIEW [dbo].[vw_UserItems]
    AS
    SELECT 
        u.Id AS UserId,
        u.Username,
        u.Email,
        i.Id AS ItemId,
        i.Name AS ItemName,
        i.Description AS ItemDescription,
        ui.AssignedDate
    FROM 
        [dbo].[Users] u
        INNER JOIN [dbo].[UserItems] ui ON u.Id = ui.UserId
        INNER JOIN [dbo].[Items] i ON ui.ItemId = i.Id
    WHERE 
        u.IsActive = 1 AND i.IsActive = 1
    ')
    
    PRINT 'View vw_UserItems created successfully.'
END
GO

-- Create a simple stored procedure
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetUserItems]') AND type in (N'P'))
BEGIN
    EXEC('
    CREATE PROCEDURE [dbo].[sp_GetUserItems]
        @UserId int = NULL
    AS
    BEGIN
        SET NOCOUNT ON;
        
        IF @UserId IS NULL
            SELECT * FROM [dbo].[vw_UserItems]
        ELSE
            SELECT * FROM [dbo].[vw_UserItems] WHERE UserId = @UserId
    END
    ')
    
    PRINT 'Stored procedure sp_GetUserItems created successfully.'
END
GO

PRINT 'Database initialization completed successfully.'