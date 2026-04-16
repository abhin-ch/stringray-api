CREATE OR ALTER PROCEDURE [stng].[SP_Budgeting_Options](
	@Operation TINYINT,
	@Value1 NVARCHAR(255)
)
AS
BEGIN
	
	-- Get Verifiers
	IF(@Operation = 1) 
		SELECT EmpName label, V.EmployeeID value FROM stng.VV_Admin_UserRole V
			INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = V.EmployeeID
			WHERE V.[Role] LIKE '%PCS Lead%'
		UNION
			SELECT EmpName label, V.EmployeeID value FROM stng.VV_Admin_UserView V
			INNER JOIN stng.Budgeting_SDQMain S ON S.Verifier = V.EmployeeID 
			AND S.SDQUID = @Value1

	-- GET BusinessDriver, FundingSource, Unit*/
	ELSE IF(@Operation=2)
		BEGIN
			--FundingSource
			SELECT ProjectTypeID as [value], ProjectTypeLong as [label] FROM stng.VV_Budgeting_ProjectType ORDER BY ProjectTypeLong ASC;
			
			--BusinessDriver
			SELECT C.UniqueID value, C.Label label FROM stng.VV_Budgeting_SDQCommon C WHERE C.Field = 'BusinessDriver' ORDER BY Sort
			
			--Unit
			SELECT * FROM stng.VV_Common_Unit C ORDER BY Sort
		END

	-- GET PrimaryDiscipline, Complexity*/
	ELSE IF(@Operation=3)
	BEGIN
		--Complexity
		SELECT C.UniqueID value, C.Label label FROM stng.VV_Budgeting_SDQCommon C WHERE C.Field = 'Complexity' ORDER BY Sort

		--PrimaryDiscipline
		SELECT Discipline FROM stng.VV_MPL_ENG GROUP BY Discipline ORDER BY Discipline
	END
	--Status Options for a given Type (Used for Admin Status tool)
	ELSE IF(@Operation=4)
	BEGIN
		IF(@Value1='DVN')
		BEGIN
			SELECT [DVNStatus] as Status
				,[DVNStatusShort] as StatusValue
			FROM [stng].[Budgeting_DVN_Status]
			WHERE Deleted = 0
			ORDER BY [DVNStatus]
		END
		ELSE IF(@Value1='SDQ')
		BEGIN
			SELECT [SDQStatusLong] as Status
				,[SDQStatus] as StatusValue
			FROM [stng].[Budgeting_SDQ_Status]
			WHERE Legacy IS NULL
			ORDER BY [SDQStatusLong]
		END
		ELSE IF(@Value1='PBRF')
		BEGIN
			SELECT [PBRFStatusLong] as Status
				,[PBRFStatus] as StatusValue
			FROM [stng].[Budgeting_PBRF_Status]
			ORDER BY [PBRFStatusLong]
		END
	END

	-- Get EAC Comment Options
	ELSE IF(@Operation = 5) SELECT * FROM stng.VV_PCC_ref_EACVarianceCommentOptions ORDER BY Sort

	-- Get SDS code Version
	ELSE IF(@Operation = 6) SELECT DISTINCT [Version] value, CONCAT('Version ', [Version]) label FROM stng.Budgeting_SDQ_DeliverableTypeVersion 
END

GO