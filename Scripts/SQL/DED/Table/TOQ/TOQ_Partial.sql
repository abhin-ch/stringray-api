CREATE TABLE [stng].[TOQ_Partial](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[VendorAssignedID] [uniqueidentifier] NOT NULL,
	[PartialRequestAmount] [decimal](12, 2) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[DeleteRecord] [bigint] NOT NULL,
	[DeleteBy] [varchar](50) NULL,
	[DeleteDate] [datetime] NULL,
 CONSTRAINT [PK__TOQ_Part__A2A2BAAA074CBCA6] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_Partial] ADD  CONSTRAINT [DF__TOQ_Parti__Uniqu__61D22120]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_Partial]  WITH CHECK ADD  CONSTRAINT [FK_TOQ_Partials_VendorAssigned] FOREIGN KEY([VendorAssignedID])
REFERENCES [stng].[TOQ_VendorAssigned] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Partial] CHECK CONSTRAINT [FK_TOQ_Partials_VendorAssigned]
GO

