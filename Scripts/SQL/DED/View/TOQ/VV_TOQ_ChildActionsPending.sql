CREATE OR ALTER VIEW [stng].[VV_TOQ_ChildActionsPending] AS 
	SELECT 
		ParentTOQID,
		STRING_AGG(PendingChildActionsIDs, ', ') as PendingChildActionsIDs,
		STRING_AGG(PendingChildActions, ', ') as PendingChildActions
	FROM (
		SELECT DISTINCT
			c.ParentTOQID,
			CASE 
				WHEN t.Value = 'EMERG' THEN
					CASE s.Value 
						WHEN 'INIT' THEN m.RequestFrom
						WHEN 'ADMA' THEN mpl.DMEPID
						WHEN 'AVENA' THEN VSS.Vendor
						WHEN 'CORR' THEN m.RequestFrom
					END
				WHEN t.Value = 'SVN' THEN
					CASE s.Value
						WHEN 'INIT' THEN m.RequestFrom
						WHEN 'ICORR' THEN m.RequestFrom
						WHEN 'AOEA' THEN mpl.OEID
						WHEN 'ADMA' THEN mpl.DMEPID
						WHEN 'SVNEBA' THEN 'EBS SM'
						WHEN 'APPD' THEN 'EBS'
						WHEN 'APPVI' THEN VSS.Vendor
						WHEN 'APPOI' THEN mpl.OEID
						WHEN 'DISPT' THEN 'EBS'
						WHEN 'SVND' THEN 'EBS'
						WHEN 'SVNVI' THEN VSS.Vendor
						WHEN 'SVNOI' THEN mpl.OEID
					END
				WHEN t.Value = 'REWORK' THEN
					CASE s.Value
						WHEN 'INIT' THEN mpl.OEID
						WHEN 'ASMA' THEN mpl.SMID
						WHEN 'AVNR' THEN VSS.Vendor
					END
			END as PendingChildActionsIDs,
			CASE 
				WHEN t.Value = 'EMERG' THEN
					CASE s.Value 
						WHEN 'INIT' THEN U.EmpName
						WHEN 'ADMA' THEN mpl.DMEP
						WHEN 'AVENA' THEN VSS.Vendor
						WHEN 'CORR' THEN U.EmpName
					END
				WHEN t.Value = 'SVN' THEN
					CASE s.Value
						WHEN 'INIT' THEN U.EmpName
						WHEN 'AOEA' THEN mpl.OE
						WHEN 'ADMA' THEN mpl.DMEP
						WHEN 'SVNEBA' THEN 'EBS SM'
						WHEN 'APPD' THEN 'EBS'
						WHEN 'APPVI' THEN VSS.Vendor
						WHEN 'APPOI' THEN mpl.OE
						WHEN 'DISPT' THEN 'EBS'
						WHEN 'SVND' THEN 'EBS'
						WHEN 'SVNVI' THEN VSS.Vendor
						WHEN 'SVNOI' THEN mpl.OE
						WHEN 'ICORR' THEN VSS.Vendor
					END
				WHEN t.Value = 'REWORK' THEN
					CASE s.Value
						WHEN 'INIT' THEN mpl.OE
						WHEN 'ASMA' THEN mpl.SM
						WHEN 'AVNR' THEN VSS.Vendor
					END
			END as PendingChildActions
		FROM stng.TOQ_Child c INNER JOIN stng.TOQ_Main m ON m.UniqueID = c.ChildTOQID
		INNER JOIN stng.Common_ValueLabel t ON m.TypeID = t.UniqueID
		INNER JOIN stng.Common_ValueLabel s ON s.UniqueID = m.StatusID
		LEFT JOIN stng.VV_MPL_RecordPersonnel mpl ON mpl.RecordUniqueID = c.ParentTOQID AND mpl.RecordType = 'TOQ'
		LEFT JOIN stng.VV_TOQ_VendorSubmission VSS ON VSS.TOQMainID = c.ParentTOQID AND VSS.Awarded = 1
		LEFT JOIN stng.VV_Admin_UserView U ON U.EmployeeID = m.RequestFrom
		WHERE c.Deleted = 0 
	) sub
	GROUP BY ParentTOQID;
GO


