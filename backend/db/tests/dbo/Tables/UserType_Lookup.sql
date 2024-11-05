CREATE TABLE [dbo].[UserType_Lookup] (
    [UTL_ID_PK]       [dbo].[LookupKey_UDT]   NOT NULL,
    [UTL_Name]        [dbo].[LookupValue_UDT] NOT NULL,
    [UTL_Description] [dbo].[Description_UDT] NULL,
    [UTL_IsActive]    BIT                     DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([UTL_ID_PK] ASC)
);

