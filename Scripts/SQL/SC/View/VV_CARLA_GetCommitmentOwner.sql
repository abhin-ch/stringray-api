CREATE OR ALTER VIEW [stng].[VV_CARLA_GetCommitmentOwner]
AS
       SELECT M.[MaterialBuyer] AS [Name],M.MaterialBuyerLANID LANID, M.[ProjectID], 'CPB.MMP' AS [CommitmentOwner] FROM stng.VV_MPL_SC M
    UNION
    SELECT M.[ServiceBuyer], M.ServiceBuyerLANID, M.[ProjectID], 'CPB.SVC' AS [CommitmentOwner] FROM stng.VV_MPL_SC M
    UNION
    SELECT M.[BuyerAnalyst],M.[BuyerAnalystLANID],M.[ProjectID], 'CPB.GEM' AS [CommitmentOwner] FROM stng.VV_MPL_SC M
    UNION
    --SELECT M.[ContractSpecialist],M.[ProjectID], 'CPP.CS' AS [CommitmentOwner] FROM stng.[VV_MPL_SC] M
    --UNION
    SELECT M.[ContractAdmin], M.[ContractAdminLANID],M.[ProjectID], 'CPC' AS [CommitmentOwner] FROM stng.VV_MPL_SC M
    UNION
    SELECT M.[ContractAdmin], M.[ContractAdminLANID],M.[ProjectID], 'CPP.CA' AS [CommitmentOwner] FROM stng.VV_MPL_SC M
    UNION
    SELECT 'Eng Tech',NULL, M.[ProjectID], 'CTS' AS [CommitmentOwner] FROM stng.VV_MPL_SC M
    UNION
    SELECT M.PCS,M.PCSLANID, M.[ProjectID],'CSP' AS [CommitmentOwner] FROM stng.[VV_MPL_SC] M
    UNION
    SELECT M.[ContractAdmin],M.ContractAdminLANID, M.[ProjectID], 'CPP' AS [CommitmentOwner] FROM stng.VV_MPL_SC M
GO


