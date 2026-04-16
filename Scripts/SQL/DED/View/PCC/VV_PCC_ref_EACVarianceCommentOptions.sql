
CREATE OR ALTER VIEW stng.VV_PCC_ref_EACVarianceCommentOptions
AS
SELECT UniqueID, Label,Value, Sort FROM stng.VV_Budgeting_SDQCommon WHERE Field = 'VarianceComment'