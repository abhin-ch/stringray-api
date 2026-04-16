/*
Author: Habib Shakibanejad
Created Date: 30 Nov 2023
Description: Used for calculating the sum of related TOQ approved amounts
*/
CREATE OR ALTER VIEW stng.VV_Budgeting_SDQRelatedTOQCalc
AS
SELECT A.SDQUID,SUM(ApprovedAmount) ApprovedAmountSum FROM stng.Budgeting_SDQRelatedTOQ A
GROUP BY A.SDQUID