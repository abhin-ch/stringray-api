
CREATE OR ALTER view [stng].[VV_TOQ_Main_Parent] as

SELECT * 
FROM stng.VV_TOQ_Main a
WHERE NOT EXISTS (
    SELECT 1 
    FROM stng.TOQ_Child b 
    WHERE b.ChildTOQID = a.UniqueID 
    AND b.Deleted = 0
);

GO


