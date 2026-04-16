CREATE OR ALTER VIEW stng.VV_Budgeting_SDQ_ReportDelegation_Legacy
AS

SELECT 'Project Controls Specialist' SignatureType 
,'PCS' Role
,PCSDelegateC Signatory
,SDID
FROM stng.Budgeting_SDQ_ReportDelegation_Legacy 

UNION

SELECT 'Owner''s Engineer Lead (OE)' SignatureType 
,'OE' Role
,OEDeletegateC Signatory
,SDID
FROM temp.SDQ_ReportDelegation_Legacy 

UNION

SELECT 'Verifier' SignatureType 
,'Verifier' Role
,VerifierDeletegateC Signatory
,SDID
FROM stng.Budgeting_SDQ_ReportDelegation_Legacy 

UNION

SELECT 'Department Manager, Engineering Projects' SignatureType 
,'DMEP' Role
,DMEPDeletegateC Signatory
,SDID
FROM stng.Budgeting_SDQ_ReportDelegation_Legacy 

UNION

SELECT CONCAT('Section Manager',', ',SectionName) SignatureType
,'SM' Role
,CASE WHEN SectionManagerC <> DelegateC THEN CONCAT(DelegateC,' (',SectionManagerC, ')') ELSE SectionManagerC END Signatory
,SDID
FROM stng.Budgeting_SDQ_SMApproval_Legacy