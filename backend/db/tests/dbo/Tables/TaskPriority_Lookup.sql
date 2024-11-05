CREATE TABLE [dbo].[TaskPriority_Lookup] (
    [PL_ID_PK]       [dbo].[LookupKey_UDT]   NOT NULL,
    [PL_Name]        [dbo].[LookupValue_UDT] NOT NULL,
    [PL_Description] [dbo].[Description_UDT] NULL,
    [PL_IsActive]    BIT                     DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([PL_ID_PK] ASC)
);

