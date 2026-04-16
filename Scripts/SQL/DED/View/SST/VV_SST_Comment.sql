/****** Object:  View [stng].[VV_SST_Comment]    Script Date: 12/5/2025 11:53:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [stng].[VV_SST_Comment] as
select a.UniqueID, a.SSTID, b.StateType as CommentType, a.Comment, a.RAD as CommentDate,
concat(c.FirstName, ' ', c.LastName) as Commenter
from stng.SST_Comment as a
inner join stng.SST_StateType as b on a.CommentType = b.UniqueID
inner join stng.Admin_User as c on a.RAB = c.EmployeeID
where a.Deleted = 0
GO


