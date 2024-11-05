CREATE TABLE [dbo].[Tag_Lookup] (
    [TL_ID_PK]       INT                     NOT NULL,
    [TL_Name]        [dbo].[LookupValue_UDT] NOT NULL,
    [TL_Description] [dbo].[Description_UDT] NULL,
    [TL_IsActive]    BIT                     DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([TL_ID_PK] ASC)
);

