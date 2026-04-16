CREATE TYPE stng.TYPE_Plugin_SessionTaskParameter AS TABLE 
(
	SessionTask varchar(100) not null,
	ParameterName varchar(100) not null,
	ParameterValue varchar(250) not null
);
