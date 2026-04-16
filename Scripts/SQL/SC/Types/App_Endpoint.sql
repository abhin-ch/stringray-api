CREATE TYPE [stng].App_Endpoint AS TABLE(
	[Module] [nvarchar](255) NOT NULL,
	[RouteName] [nvarchar](255) NOT NULL,
	[Method] [nvarchar](255) NOT NULL
)