/*
 CreatedBy: Asiful Hai
 CreatedDate: 28 Mar 2022
 Description: Financial information for any given Fragnet and Subfragnet of SC Projects
 */

SELECT
  FA.ProjShortName,
  F.FragnetID,
  FA.SubFragnetID,
  F.FragnetName,
  F.SubFragnetName,
  FA.CalculatedLawHours,
  FA.CalculatedLabourHours
FROM
  (
    SELECT
      ProjShortName,
      FragnetID AS SubFragnetID,
      COALESCE (
        SUM(
          CASE
            WHEN Status = 'Active'
            AND Resource LIKE '%CSL%'
            AND ActualStartDate <= '30-Apr-22' THEN RemainingHours
            WHEN Status = 'Actualized'
            AND Resource LIKE '%CSL%'
            AND ActualEndDate <= '30-Apr-22' THEN RemainingHours
            WHEN Status = 'Active'
            AND Resource LIKE '%CSL%'
            AND ActualStartDate > '30-Apr-22' THEN BudgetedHours
            WHEN Status = 'Actualized'
            AND Resource LIKE '%CSL%'
            AND ActualEndDate > '30-Apr-22' THEN BudgetedHours
            WHEN Status = 'NotStart'
            AND Resource LIKE '%CSL%' THEN BudgetedHours
          END
        ),
        0
      ) AS CalculatedLawHours,
      COALESCE (
        SUM(
          CASE
            WHEN Status = 'Active'
            AND Resource NOT LIKE '%CSL%'
            AND ActualStartDate <= '30-Apr-22' THEN RemainingHours
            WHEN Status = 'Actualized'
            AND Resource NOT LIKE '%CSL%'
            AND ActualEndDate <= '30-Apr-22' THEN RemainingHours
            WHEN Status = 'Active'
            AND Resource NOT LIKE '%CSL%'
            AND ActualStartDate > '30-Apr-22' THEN BudgetedHours
            WHEN Status = 'Actualized'
            AND Resource NOT LIKE '%CSL%'
            AND ActualEndDate > '30-Apr-22' THEN BudgetedHours
            WHEN Status = 'NotStart'
            AND Resource NOT LIKE '%CSL%' THEN BudgetedHours
          END
        ),
        0
      ) AS CalculatedLabourHours
    FROM
      stng.FragnetActivity
    GROUP BY
      ProjShortName,
      FragnetID
  ) AS FA
  INNER JOIN (
    SELECT
      DISTINCT F1.ParentID AS FragnetID,
      F1.FragnetID AS SubFragnetID,
      F1.FragnetName AS SubFragnetName,
      F2.FragnetName
    FROM
      stng.Fragnet AS F1
      INNER JOIN stng.Fragnet AS F2 ON F1.ParentID = F2.FragnetID
  ) AS F ON F.SubFragnetID = FA.SubFragnetID