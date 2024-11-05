CREATE TABLE [dbo].[Task_Master] (
    [TM_ID_PK]       [dbo].[LargeKey_UDT]  NOT NULL,
    [TM_UserID_FK]   [dbo].[LargeKey_UDT]  NULL,
    [TM_Title]       NVARCHAR (100)        NOT NULL,
    [TM_Description] NVARCHAR (1000)       NULL,
    [TM_StartTime]   [dbo].[Time_UDT]      NULL,
    [TM_EndTime]     [dbo].[Time_UDT]      NULL,
    [TM_Status_FK]   [dbo].[LookupKey_UDT] NOT NULL,
    [TM_Priority_FK] [dbo].[LookupKey_UDT] NOT NULL,
    [TM_IsArchived]  BIT                   DEFAULT ((0)) NOT NULL,
    [TM_IsActive]    BIT                   DEFAULT ((1)) NOT NULL,
    [TM_CreatedAt]   [dbo].[Time_UDT]      DEFAULT (getutcdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([TM_ID_PK] ASC),
    FOREIGN KEY ([TM_Priority_FK]) REFERENCES [dbo].[TaskPriority_Lookup] ([PL_ID_PK]),
    FOREIGN KEY ([TM_Status_FK]) REFERENCES [dbo].[TaskStatus_Lookup] ([SL_ID_PK]),
    FOREIGN KEY ([TM_UserID_FK]) REFERENCES [dbo].[User_Master] ([UM_ID_PK])
);

