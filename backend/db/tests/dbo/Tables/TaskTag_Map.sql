CREATE TABLE [dbo].[TaskTag_Map] (
    [TT_ID_CPKFK]    [dbo].[LargeKey_UDT] NOT NULL,
    [TT_TagID_CPKFK] INT                  NOT NULL,
    [TT_IsActive]    BIT                  DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TT_TagID_CPKFK] ASC, [TT_ID_CPKFK] ASC),
    FOREIGN KEY ([TT_ID_CPKFK]) REFERENCES [dbo].[Task_Master] ([TM_ID_PK]),
    FOREIGN KEY ([TT_TagID_CPKFK]) REFERENCES [dbo].[Tag_Lookup] ([TL_ID_PK])
);

