CREATE TABLE [dbo].[User_Master] (
    [UM_ID_PK]       [dbo].[LargeKey_UDT]    NOT NULL,
    [UM_UserName]    VARCHAR (100)           NULL,
    [UM_UserType_FK] [dbo].[LookupKey_UDT]   NOT NULL,
    [UM_Name]        NVARCHAR (500)          NOT NULL,
    [UM_Email]       [dbo].[Email_UDT]       NULL,
    [UM_Mobile]      [dbo].[Mobile_UDT]      NULL,
    [UM_CountryCode] [dbo].[CountryCode_UDT] NULL,
    [UM_IsVerified]  BIT                     DEFAULT ((0)) NOT NULL,
    [UM_IsActive]    BIT                     DEFAULT ((1)) NOT NULL,
    [UM_CreatedAt]   DATETIME                DEFAULT (sysutcdatetime()) NOT NULL,
    PRIMARY KEY CLUSTERED ([UM_ID_PK] ASC),
    FOREIGN KEY ([UM_UserType_FK]) REFERENCES [dbo].[UserType_Lookup] ([UTL_ID_PK])
);

