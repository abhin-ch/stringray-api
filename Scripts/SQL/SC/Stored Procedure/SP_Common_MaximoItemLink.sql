/*
Author: Habib Shakibanejad & Arvind DHINAKAR
Description: This procedure will grab all CR and Item links from DEMS and insert into stingray used
for accessing links to Maximo.
CreatedDate: 28 July 2021
RevisedDate:
RevisedBy:
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Common_MaximoItemLink]
AS
BEGIN
    DELETE FROM stng.MaximoItemLink

    INSERT INTO stng.MaximoItemLink(MaximoID,PKID,Label)
    SELECT
        CAST(ITEMID AS NVARCHAR(50))
        ,CONCAT('ITEM-',IIF(ISNUMERIC(ITEMNUM)>0,CAST(CAST(ITEMNUM AS INT) AS NVARCHAR(50)),ITEMNUM))
        ,IIF(ISNUMERIC(ITEMNUM)>0,CAST(CAST(ITEMNUM AS INT) AS NVARCHAR(50)),ITEMNUM) FROM dems.TT_0098_ItemMapping
    UNION
    SELECT M.TICKETUID,CONCAT('CR-',M.TICKETID),M.TICKETID FROM dems.TT_0043_CRMapping M
END
GO