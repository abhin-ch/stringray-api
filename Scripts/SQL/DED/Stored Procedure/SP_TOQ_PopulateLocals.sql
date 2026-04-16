CREATE OR ALTER PROCEDURE [stng].[SP_TOQ_PopulateLocals] (
    @UniqueID uniqueidentifier,
    @CurrentUser VARCHAR(255) = NULL,
    @ErrorDescription VARCHAR(255) = NULL OUTPUT
)
AS
	BEGIN
		SET NOCOUNT ON;

		--Declare internal variables
		DECLARE @VendorAssignedID uniqueidentifier,
				@Prefix VARCHAR(2),
				@VendorID VARCHAR(50),
				@ProjectID VARCHAR(5),
				@InternalID INT,
				@RevisionNum SMALLINT,
				@Status VARCHAR(50),
				@MaxLocal INT,
				@LegacyFound uniqueidentifier;

		--Get information assigned to TOQ
		SELECT 
			@ProjectID = M.Project,
			@InternalID = M.InternalID,
			@VendorAssignedID = VA.UniqueID,
			@RevisionNum = M.Rev,
			@Status = S.Value,
		FROM stng.TOQ_Main M
		INNER JOIN stng.VV_TOQ_Status S ON S.StatusID = M.StatusID
		LEFT JOIN stng.TOQ_VendorAssigned VA ON M.UniqueID = VA.TOQMainID
		WHERE M.UniqueID = @UniqueID and VA.Awarded = 1

		-- If InternalID does not exist, then set it to the MPL InternalID based off the current project
		UPDATE t
		SET t.InternalID = e.InternalID
		FROM [stng].[TOQ_Main] t
		INNER JOIN [stng].[VV_MPL_ENG] e ON t.Project = e.SharedProjectID
		WHERE t.UniqueID = @UniqueID
		AND (t.InternalID IS NULL OR t.InternalID = '')

		-- If InternalID does not exist and it's a legacy project, then set it to grab the InternalID from the mapping table
		UPDATE t
		SET t.InternalID = g.IntId
		FROM [stng].[TOQ_Main] t
		LEFT JOIN (
			SELECT [IntId],
				   SUBSTRING([ProjectId], CHARINDEX('-', [ProjectId]) + 1, LEN([ProjectId])) as Project
			FROM [stng].[General_P6ProjectMapping]
			WHERE ProjectID like '%ENG-%'
		) g ON t.Project = g.Project
		WHERE t.InternalID IS NULL and t.Project = @ProjectID

		--update internalID in case of change
		SET @InternalID = (SELECT InternalID from stng.TOQ_Main where UniqueID  = @UniqueID);

		-- Cleanup blank rows from Cost Summary and then assign deliverable locals ( Deliverable locals should not be assigned to blank rows )
		DELETE c FROM stng.TOQ_CostSummary c 
		JOIN stng.TOQ_VendorAssigned v ON v.UniqueID = c.VendorAssignedID
		WHERE v.TOQMainID = @UniqueID AND c.DeliverableCode = 999;		

		--Determine if it is legacy data
		SELECT @LegacyFound = M.UniqueID 
		FROM stng.TOQ_Main M
		INNER JOIN stng.Common_ValueLabel C ON M.StatusID = C.UniqueID
		WHERE C.Value = 'ACC' 
			AND M.DeleteRecord = 0 
			AND M.Comment = 'Legacy Upload' 
			AND M.UniqueID = @UniqueID;

		--Get vendor id and prefix for this VendorAssignedID
		SELECT 
			@VendorID = VA.VendorID,
			@Prefix = CV.Value1    
		FROM stng.TOQ_VendorAssigned VA 
		INNER JOIN stng.Common_ValueLabel CV ON VA.VendorID = CV.UniqueID
		WHERE VA.UniqueID = @VendorAssignedID and VA.Awarded = 1;

		IF @VendorAssignedID IS NULL OR @VendorID IS NULL --OR @Status <> 'ACC' TOQ is in process of being awarded.
		BEGIN
			SET @ErrorDescription = 'TOQ has not been awarded';
			RETURN;
		END

		--If various, assign local directly
		--If project = 99999 OR 'Legacy Upload'
		IF @ProjectID = '99999' OR @LegacyFound IS NOT NULL
		BEGIN
			UPDATE stng.TOQ_CostSummary
			SET DeliverableAccount = @Prefix + '000'
			WHERE VendorAssignedID = @VendorAssignedID 

		END
		ELSE 
		BEGIN
		    --Check whether project exists in P6 MPL (email if not)
			IF NOT EXISTS (SELECT 1 FROM stng.MPL WHERE INTERNALID = @InternalID) AND NOT EXISTS (SELECT 1 FROM stng.[VV_MPL_ENG] WHERE INTERNALID = @InternalID)
			BEGIN
				SET @ErrorDescription = 'Project ' + ISNULL(@ProjectID, 'NULL') + ' missing in MPL, deliverable accounts not assigned.';
				RETURN;
			END

			--Get MAX local number used for this vendor + projectInternalID
			SELECT @MaxLocal = ISNULL(MAX(CAST(RIGHT(CS.DeliverableAccount, 3) AS INT)), 0)
			FROM stng.TOQ_CostSummary CS
			LEFT JOIN stng.TOQ_VendorAssigned VA ON CS.VendorAssignedID = VA.UniqueID
			INNER JOIN stng.TOQ_Main M ON M.UniqueID = VA.TOQMainID
			WHERE M.InternalID = @InternalID AND VA.VendorID = @VendorID AND CS.DeliverableAccount IS NOT NULL AND VA.Awarded = 1;

			--Use MaxLocal+1 as starting # and increment
			WITH CTE AS (
				SELECT 
					DeliverableAccount,
					ROW_NUMBER() OVER (ORDER BY CreatedDate) AS rn
				FROM stng.TOQ_CostSummary
				WHERE VendorAssignedID = @VendorAssignedID 
					AND DeliverableAccount IS NULL
			)
			UPDATE CTE
			SET DeliverableAccount = @Prefix + RIGHT('000' + CAST((rn + @MaxLocal) AS VARCHAR(3)), 3);
		END
	END

	--To Test
	--PLUG IN A VALID UniqueID WHICH HAS BEEN AWARDED
	--THEN RUN THIS CODE BLOCK MANUALLY TO ASSIGN LOCALS
	--DISPLAYS AN ERROR DESCRIPTION IF THE PROJECT IS MISSING IN MPL OR OTHER VALIDATION FAILS
	/*
	DECLARE @ErrorDescription VARCHAR(255);
	DECLARE @UniqueID uniqueidentifier;

	--Do the following if Nima creates a project in P6 after a record is already Approved and Complete

	--Try populating locals for a given awarded UniqueID
	--Displays an error description if the process fails
	SELECT @UniqueID = '72E2A4F7-1234-4ABC-8DEF-56789ABCDE01'; -- Replace with a valid TOQ_Main UniqueID
	EXEC stng.SP_TOQ_PopulateLocals @UniqueID = @UniqueID, @ErrorDescription = @ErrorDescription OUTPUT;
	SELECT @ErrorDescription AS ErrorDescription;
	*/

	/*
	
	TO SEE ALL RECORDS WITHOUT POPULATED LOCALS:

	select tm.TMID from stng.VV_TOQ_CostSummary cs
	left join stng.VV_TOQ_Main tm on tm.UniqueID = cs.TOQMainID
	left join stng.VV_TOQ_Status ts on ts.StatusID = tm.StatusID
	join stng.VV_TOQ_VendorSubmission vs on vs.UniqueID = cs.VendorAssignedID and vs.Awarded = 1
	where DeliverableAccount is null and ts.Label = 'Approved and Complete' and tm.Project <> '99999'
	group by tm.TMID
	order by tm.TMID

	*/


	

