CREATE TABLE [dbo].[TaskStatus_Lookup] (
    [SL_ID_PK]       [dbo].[LookupKey_UDT]   NOT NULL,
    [SL_Name]        [dbo].[LookupValue_UDT] NOT NULL,
    [SL_Description] [dbo].[Description_UDT] NULL,
    [SL_IsActive]    BIT                     DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([SL_ID_PK] ASC)
);

