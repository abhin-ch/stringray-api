using Microsoft.AspNetCore.Http;

using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Microsoft.Data.SqlClient;
//using static DEMSLib.VDSVerification;
using StingrayNET.ApplicationCore.Models.VDU;

using Newtonsoft.Json;



//namespace DEMSLib
namespace StingrayNET.ApplicationCore.HelperFunctions
{
    public class VDSHelper
    {
        #region Column Validation Helpers
        /// <summary>
        /// Builds a dictionary mapping ColMapIds to column names
        /// </summary>
        /// <param name="reportColumns">List of report columns to build dictionary for</param>
        /// <returns>Dictionary mapping ColMapIds (as strings) to Column Names</returns>
        public static Dictionary<string, VDSReportColumn> ColumnDictionary(List<VDSReportColumn> reportColumns)
        {
            //Build a dictionary mapping ColMapIds to Report Column Names
            Dictionary<string, VDSReportColumn> matchDict = new Dictionary<string, VDSReportColumn>();
            
            foreach (VDSReportColumn reportColumn in reportColumns)
            {
                matchDict[reportColumn.ColMapId.ToString()] = reportColumn;
            }

            return matchDict;
        }

         /// <summary>
        /// Checks whether a logic statements required columns exist in the sheetData object
        /// </summary>
        /// <param name="logicStatement">Logic statement using ColMapIds</param>
        /// <param name="columnDictionary">Map of ColMapIds to Column Names</param>
        /// <param name="sheetData">Datatable containing columns to be checked</param>
        /// <returns>Boolean indicating result</returns>
        public static bool DoRequiredColumnsExist(string logicStatement, Dictionary<string, VDSReportColumn> columnDictionary, DataTable sheetData)
        {
            bool allColumnsExist = true;
            MatchCollection matches = Regex.Matches(logicStatement, @"\[([0-9]*)\]");
            foreach (Match match in matches)
            {
                //If a required report column is not in the user excel sheet
                if (!sheetData.Columns.Contains(columnDictionary[match.Groups[1].Value].ReportColumn))
                {
                    allColumnsExist = false;
                }
            }

            return allColumnsExist;
        }

        /// <summary>
        /// Converts a logic statement with colMapIds to one with column names
        /// Includes a wrapping CONVERT per the typesTable column type
        /// </summary>
        /// <param name="toParse">Logic string with colMapIds</param>
        /// <param name="columnDictionary">Dictionary mapping colMapIds to column objects</param>
        /// <param name="typesTable">Table aligning with DbField of column objects</param>
        /// <returns>A new logic statement using column names and types</returns>
        /// <exception cref="ArgumentOutOfRangeException">Thrown when dictionary or types table is missing a column</exception>
        public static string LogicStatementIdsToNamesWithType(string toParse, Dictionary<string, VDSReportColumn> columnDictionary, DataTable typesTable)
        {
            //Build string of form CONVERT([COLUMN NAME], 'COLUMN TYPE')
            string withConvert = Regex.Replace(toParse, @"\[([0-9]*)\]",
                                                  m => string.Format("CONVERT([{0}], '{1}')",
                                                                        columnDictionary[m.Groups[1].Value].ReportColumn,
                                                                        typesTable.Columns[columnDictionary[m.Groups[1].Value].DbField].DataType));

            return withConvert;
        }

        /// <summary>
        /// Converts a logic statement with colMapIds to one with column names
        /// </summary>
        /// <param name="toParse">Logic string with colMapIds</param>
        /// <param name="columnDictionary">Dictionary mapping colMapIds to column objects</param>
        /// <returns>A new logic statement using column names</returns>
        /// <exception cref="ArgumentOutOfRangeException">Thrown when dictionary doesn't contain one of the IDs</exception>
        public static string LogicStatementIdsToNames(string toParse, Dictionary<string, VDSReportColumn> columnDictionary)
        {
            return Regex.Replace(toParse, @"\[([0-9]*)\]",
                             m => "[" + columnDictionary[m.Groups[1].Value].ReportColumn + "]");
        }

        /// <summary>
        /// Converts a logic statement with columnNames to one with ColMapIDs
        /// </summary>
        /// <param name="toParse">Logic string with column names</param>
        /// <param name="reportColumns">List of report columns</param>
        /// <returns>A new logic statement using column names</returns>
        /// <exception cref="ArgumentNullException">Thrown if reportColumns doesn't contain one of the column names</exception>
        public static string LogicStatementNamesToIds(string toParse, List<VDSReportColumn> reportColumns)
        {
            if (toParse == null)
                return null;
            //Ignores values in square brackets immediately preceded by a reserved @*Query*[] keyword
            return Regex.Replace(toParse, @"(?<!@\S*Query[^\s\]]*)\[([^\]]+)\]",
                             m => "[" + reportColumns.Find(c => c.ReportColumn.ToUpper() == m.Groups[1].Value.ToUpper()).ColMapId + "]");
        }

        /// <summary>
        /// Swaps vendor and suborg parameters in a query for the specified vendor and suborg IDs
        /// </summary>
        /// <param name="myString">The rule value being modified</param>
        /// <param name="vendorId">The vendor ID per the database</param>
        /// <param name="suborgId">The suborg ID per the database</param>
        /// <returns>The modified rule value</returns>
        public static string FillKeywordValues(string myString, int vendorId, int suborgId, DateTime reportBucket,
                                               DateTime vendorDate, int? reuploadPreviousId, DataTable queryResult)
        {
            if (myString == null)
                return null;

            myString = myString.Replace("@VendorId", vendorId.ToString());
            myString = myString.Replace("@SuborgId", suborgId.ToString());
            myString = myString.Replace("@ReportBucket", reportBucket.ToString("yyyy-MM-dd"));
            myString = myString.Replace("@VendorDate", vendorDate.ToString("yyyy-MM-dd"));

            //If previous ID is null, comparisons must use IS / IS NOT NULL rather than =, !=, <>
            //if(reuploadPreviousId == null)
            //{
            //    myString = Regex.Replace(myString, @"(!=|<>)\s*@ReuploadPreviousId", "IS NOT NULL");
            //    myString = Regex.Replace(myString, @"=\s*@ReuploadPreviousId", "IS NULL"); 
            //}
            //Still replace after regex for anything NOT in an equal/notequal comparison
            myString = myString.Replace("@ReuploadPreviousId", reuploadPreviousId == null ? "NULL" : reuploadPreviousId.ToString());

            //If query has some value, try using lookup
            if(queryResult != null && queryResult.Rows.Count > 0)
            {
                //If selected column is not present in query, use default value
                try
                {
                    //Match in format @QueryList[COLUMNNAME,DEFAULTVALUE]
                    //Replaces with comma delimited list of values in the specified column
                    myString = Regex.Replace(myString, @"@QueryList\[([^\]]*),([^\]]*)\]",
                                    m => string.Join(", ", queryResult.AsEnumerable()
                                            .Select(x => x[m.Groups[1].Value].ToString()).ToList()));

                    //Match in format @SingleQueryValue[COLUMNNAME,DEFAULTVALUE]
                    //Replaces with first value in the specified column
                    myString = Regex.Replace(myString, @"@SingleQueryValue\[([^\]]*),([^\]]*)\]",
                                    m => queryResult.Rows[0][m.Groups[1].Value].ToString());
                }
                catch (ArgumentException)
                {
                    myString = Regex.Replace(myString, @"@QueryList\[([^\]]*),([^\]]*)\]", m => m.Groups[2].Value);
                    myString = Regex.Replace(myString, @"@SingleQueryValue\[([^\]]*),([^\]]*)\]", m => m.Groups[2].Value);
                }
            }
            //If not, use default value provided
            else
            {
                myString = Regex.Replace(myString, @"@QueryList\[([^\]]*),([^\]]*)\]", m => m.Groups[2].Value);
                myString = Regex.Replace(myString, @"@SingleQueryValue\[([^\]]*),([^\]]*)\]", m => m.Groups[2].Value);
            }
            
            return myString;
        }

        public static string QueryLookupFillKeyword(string myString, DataRow dataRow, DataTable queryResult)
        {
            if (queryResult != null)
            {
                //Match in format @QueryLookup[Conditions,Column,DefaultValue]
                MatchCollection lookupMatches = Regex.Matches(myString, @"@QueryLookup\[([^\]]*),([^\]]*),([^\]]*)\]");

                //Iterate lookup queries
                for(int i = 0; i < lookupMatches.Count; i++)
                {
                    GroupCollection lookupGroups = lookupMatches[i].Groups;

                    //First group is conditions - split to get both sides of each equals and iterate
                    //Filter the query result for each condition
                    MatchCollection conditionMatches = Regex.Matches(lookupGroups[1].Value, @"([^&]+)=([^&]+)");
                    DataTable queryResultCopy = queryResult.Copy();
                    for(int j = 0; j < conditionMatches.Count; j++)
                    {
                        //Filter query rows where query row value at column on right of equals == data row value in column on left of equals
                        var filteredRows = queryResultCopy.AsEnumerable().Where(
                                                qr => qr[conditionMatches[j].Groups[2].Value].ToString() == dataRow[conditionMatches[j].Groups[1].Value].ToString());
                        if (filteredRows.Any())
                        {
                            queryResultCopy = filteredRows.CopyToDataTable();
                        }
                        else
                        {
                            queryResultCopy.Clear();
                        }
                    }
                    //After all conditional filters have been applied, substitute rule value substring with the lookup column or the default
                    if(queryResultCopy.Rows.Count > 0)
                    {
                        myString = Regex.Replace(myString, Regex.Escape(lookupMatches[i].Value),queryResultCopy.Rows[0][lookupGroups[2].Value].ToString());
                    }
                    else
                    {
                        myString = Regex.Replace(myString, Regex.Escape(lookupMatches[i].Value), lookupGroups[3].Value);
                    }
                }
            }

            return myString;
        }

        public static int[] MultiFieldInvalidIndicesOverride(DataTable myDataTable, string myColumnName, string myRuleValue = "", List<string> myRuleList = null, DataTable myQueryResult = null)
        {
            List<int> myRowIndices = new List<int>();

            //Create copy of datatable schema
            //We will use it to hold a single row at a time while testing rule conditions
            //Running .select on a large datatable takes a very long time
            DataTable myDataTableCopy = myDataTable.Clone();

            List<DataRow> myFailedRows = new List<DataRow>();
            DataRow dataRow;
            for (int i = 0; i < myDataTable.Rows.Count; i++)
            {
                dataRow = myDataTable.Rows[i];
                //Import row to perform checks
                myDataTableCopy.ImportRow(dataRow);

                //If the condition is ill-defined, fail the row
                try
                {
                    //Use the datatable select method on the single row to check if it meets the dynamic condition
                    if (myDataTableCopy.Select(string.Format("NOT({0})",
                                   VDSHelper.QueryLookupFillKeyword(myRuleValue, dataRow, myQueryResult))).Count() != 0)
                    {
                        //If row failed (i.e. select returned the row) add the ORIGINAL datatable row
                        //Need this to get correct value when using IndexOf below
                        myFailedRows.Add(dataRow);
                    }
                }
                catch
                {
                    myFailedRows.Add(dataRow);
                }

                //Clear each time - we want to perform checks one by one
                myDataTableCopy.Clear();
            }

            //Add row indices for failed rows
            foreach (DataRow failedRow in myFailedRows)
            {
                myRowIndices.Add(myDataTable.Rows.IndexOf(failedRow));
            }
            return myRowIndices.ToArray();
        }
        #endregion

        #region File Processing

        /// <summary>
        /// Validate Excel data, and if valid load report data
        /// to each VDSReportSheet object's "SheetData" DataTable
        /// </summary>
        /// <param name="report">Report schema object being imported to</param>
        /// <param name="fi">String path of the excel file to import</param>
        /// <param name="connectionString">Connection string</param>
        /// <returns>Boolean indicating success of the parse</returns>
        //public static List<VDSReportError> TryImportExcel(VDSReport report, string fi, string connectionString)
        public static List<VDSReportError> TryImportExcel(VDSReport report, ExcelPackage excelFile, string connectionString)
        {
            List<VDSReportError> errorList = new List<VDSReportError>();
            
            //If the report schema has no sheets associated, error out
            if(report.ReportSheets.Count == 0)
                errorList.Add(new VDSReportError(VDSVerification.RuleType.Error, "Report schema error - please contact administrator"));

            foreach (VDSReportSheet reportSheet in report.ReportSheets)
            {
                //Clear old data
                reportSheet.SheetData.Clear();

                //Tries to parse excel data for each sheet, returning errors if any
                List<VDSReportError> sheetErrors = TryParseExcelData(excelFile, reportSheet.SheetName, connectionString,
                                                            out DataTable sheetData, out Tuple<int, int> startCell);

                //Get table structure (upload ID is null) for use in validation
                //If there is a schema error, report and continue next sheet
                //!!!!!!!IMPORTANT,need changing!!!!!!//
                DataTable tableStructure = new DataTable();
                string mySql;
                mySql = string.Format("EXEC [stng].[SP_VDU_CRUD] @Operation = 6, @TabMapId = {0}", reportSheet.TabMapId);
                tableStructure = GetDataInTable(mySql,connectionString);
                if (tableStructure.Columns.Count == 1 && tableStructure.Columns[0].ColumnName == "Error")
                    tableStructure = null;
                
                if (tableStructure == null)
                    sheetErrors.Add(new VDSReportError(VDSVerification.RuleType.Error, "Report schema error - please contact administrator", reportSheet.SheetName));

                if (sheetErrors.Count > 0)
                {
                    //If sheet had parsing errors or schema errors, we can't validate the data
                    //Add errors to list and move on
                    errorList.AddRange(sheetErrors);
                    continue;
                }

                //Report sheet needs start cell for error message offset
                reportSheet.StartCell = startCell;

                //Cleanse scientific notation and double-format datetimes on the sheet data
                CleanseExcelData(sheetData, tableStructure, reportSheet.ReportColumns);

                //Perform validation rule checks and catch errors
                sheetErrors.AddRange(Validate(sheetData, tableStructure, reportSheet, report, connectionString));

                //Map fields to DB schema and catch errors
                sheetErrors.AddRange(MapSheetDataToDb(sheetData, tableStructure, reportSheet, out DataTable mappedData));

                //If no processing errors, assign sheet data
                VDSVerification.ErrorsFound sheetErrorsFound = VDSVerification.ErrorTypesFound(sheetErrors);
                if (sheetErrorsFound == VDSVerification.ErrorsFound.None
                        || sheetErrorsFound == VDSVerification.ErrorsFound.Warnings)
                {
                    reportSheet.SheetData = mappedData;
                }

                //Merge sheet errors to total errors for report
                errorList.AddRange(sheetErrors);
            }

            excelFile.Dispose();

            return errorList;
        }

        /// <summary>
        /// Loads report data from Excel
        /// Starts the datasheet at the "Item #" column/row
        /// </summary>
        /// <param name="excelFile">Excelpackage to read from</param>
        /// <param name="sheetName">Name of the sheet being imported</param>
        /// <param name="connectionString">Connection string</param>
        /// <param name="sheetData">The datatable the data should be assigned to</param>
        /// <param name="startCell">The starting cell index (row,col) of the Item # column</param>
        /// <returns>List of errors encountered</returns>
        private static List<VDSReportError> TryParseExcelData(ExcelPackage excelFile, string sheetName, string connectionString, out DataTable sheetData, out Tuple<int, int> startCell)
        {
            List<VDSReportError> sheetErrors = new List<VDSReportError>();
            sheetData = new DataTable();
            startCell = new Tuple<int, int>(0, 0);

            //Get the sheet data (check it exists via null return)
            ExcelWorksheet tabSheet = VDUExcelHelper.GetSheet(excelFile, sheetName);
            if (tabSheet != null)
            {
                //Check that the vendor file has "Item #" somewhere - use this as the start row
                List<ExcelCellAddress> itemCellList = (from cell in tabSheet.Cells["1:" + tabSheet.Dimension.End.Row.ToString()]
                                                       where cell.Value != null && cell.Value.ToString().Trim() == "Item #"
                                                       select cell.Start).ToList();

                //Check the cell exists, add error if not
                if (itemCellList.Any())
                {
                    //Get the Item # cell, storing its row and column
                    ExcelCellAddress itemCell = itemCellList.First();
                    int startRow = itemCell.Row;
                    int startCol = itemCell.Column; //Note - one-based per Excel standard
                                                    //When creating errors, datatable is 0-based
                                                    //So _startCol + columnIndexInDatatable will be 1-based

                    startCell = new Tuple<int, int>(startRow, startCol);

                    try
                    {
                        //Import raw data
                        sheetData = VDUExcelHelper.ConvertToDataTable(tabSheet, startRow, startCol);
                    }
                    catch (DuplicateNameException ex)
                    {
                        sheetErrors.Add(new VDSReportError(VDSVerification.RuleType.Error, ex.Message));
                    }
                }
                else
                {
                    sheetErrors.Add(new VDSReportError(VDSVerification.RuleType.Error, "Item # column is missing from sheet ", sheetName));
                }
                tabSheet.Dispose();
            }
            else
            {
                sheetErrors.Add(new VDSReportError(VDSVerification.RuleType.Error, "Sheet was not found", sheetName));
            }
            return sheetErrors;
        }

        /// <summary>
        /// Cleanses datetime and decimal values in sheet data
        /// for any db field with a relevant type
        /// Fixed dateserial (double) format dates, and scientific notation doubles
        /// </summary>
        /// <returns></returns>
        private static void CleanseExcelData(DataTable sheetData, DataTable tableStructure, List<VDSReportColumn> reportColumns)
        {
            foreach (VDSReportColumn reportColumn in reportColumns)
            {
                //Match mapped table column types to DB table column types
                if (tableStructure.Columns.Contains(reportColumn.DbField) && sheetData.Columns.Contains(reportColumn.ReportColumn))
                {
                    //if column type is datatime, convert table
                    if (tableStructure.Columns[reportColumn.DbField].DataType == Type.GetType("System.DateTime"))
                    {
                        VDUExcelHelper.DtDoubleToDateTime(sheetData, reportColumn.ReportColumn);
                    }
                    else if (tableStructure.Columns[reportColumn.DbField].DataType == Type.GetType("System.Decimal"))
                    {
                        VDUExcelHelper.DtScientificToDecimal(sheetData, reportColumn.ReportColumn);
                    }
                }
            }
        }

        /// <summary>
        /// Validate a DataTable against a sheet schema
        /// </summary>
        /// <param name="sheetData">Datatable of values being validated</param>
        /// <param name="tableStructure">Datatable matching the database structure</param>
        /// <param name="reportSheet">Report sheet schema object</param>
        /// <param name="report">Report schema object - properties are used in some validation checks</param>
        /// <param name="connectionString">Connection string</param>
        /// <returns>List of errors encountered</returns>
        private static List<VDSReportError> Validate(DataTable sheetData, DataTable tableStructure, VDSReportSheet reportSheet, VDSReport report, string connectionString)
        {
            List<VDSReportError> errorList = new List<VDSReportError>();

            //Check if data table is populated
            if (sheetData == null)
            {
                return errorList;
            };

            //Build a dictionary mapping ColMapIds to Report Columns
            //Used in each columns rule filter and for multi-column rules
            Dictionary<string, VDSReportColumn> matchDict = ColumnDictionary(reportSheet.ReportColumns);

            foreach (VDSReportColumn reportColumn in reportSheet.ReportColumns)
            {
                //If database table is missing column schema field - report schema error
                //Should never get here if table structure is retrieved from PR_0293
                if (!tableStructure.Columns.Contains(reportColumn.DbField))
                {
                    errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                            "Report schema error - please contact administrator",
                                            reportSheet.SheetName,
                                            reportColumn.ReportColumn
                                        )
                                    );
                }

                //Check if schema column exist in the Excel file
                else if (sheetData.Columns.Contains(reportColumn.ReportColumn))
                {
                    //If column exists, check all validation rules are met
                    foreach (VDSValidationRule validationRule in reportColumn.ValidationRules)
                    {
                        //Get query result for custom rules that use them
                        DataTable queryResult = new DataTable();
                        if (!VDUVerification.IsMyValueEmpty(validationRule.RuleQuery))
                        {
                            //Try getting query result
                            try
                            {
                                //Query string itself can have keywords (like vendor ID, etc)
                                string mySql = FillKeywordValues(validationRule.RuleQuery, (int)report.VendorId, (int)report.SuborgId,
                                                                 (DateTime)report.ReportBucket, (DateTime)report.VendorDate,
                                                                 report.ReuploadPreviousId, queryResult) ?? "";

                                //!!!!!!!!!IMPORTANT Need to be Updated!!!!!!!!// (Updated Now, still need testing)
                                queryResult = GetDataInTable(mySql, connectionString);
                                
                            }
                            catch (Exception ex)
                            {
                                //If query results in error, rule can't be checked
                                errorList.Add(new VDSReportError(VDSVerification.RuleType.Error, ex.ToString()));
                                continue;
                            }
                        }

                        //With rule values and filters, replace keywords with respective values

                        //display version of rule value
                        string myRuleValueDisp = FillKeywordValues(validationRule.RuleValue, (int)report.VendorId, (int)report.SuborgId,
                                                                   (DateTime)report.ReportBucket, (DateTime)report.VendorDate,
                                                                 report.ReuploadPreviousId, queryResult) ?? "";
                        string myRuleValue = myRuleValueDisp; //initial value

                        //display version of rule filter
                        string myRuleFilterDisp = FillKeywordValues(validationRule.RuleFilter, (int)report.VendorId, (int)report.SuborgId,
                                                                   (DateTime)report.ReportBucket, (DateTime)report.VendorDate,
                                                                 report.ReuploadPreviousId, queryResult) ?? "";
                        string myRuleFilter = myRuleFilterDisp; //initial value

                        //Rule message override can have keywords
                        string myRuleMessageOverride = FillKeywordValues(validationRule.RuleMessageOverride, (int)report.VendorId,
                                                                        (int)report.SuborgId, (DateTime)report.ReportBucket, 
                                                                        (DateTime)report.VendorDate, report.ReuploadPreviousId, queryResult);

                        List<DataRow> myFilteredRows = new List<DataRow>(); //Used to keep track of original indices after filtering
                        DataTable myFilteredData; //Filtered datatable for validation

                        int[] invalidIndices = new int[0];

                        //Use rule filter if applicable
                        if (VDUVerification.IsMyValueEmpty(myRuleFilter))
                        {
                            //If the rule isn't a not null rule, don't apply rule to null values
                            //This prevents errors for "doesn't meet rule x" in addition to "cannot be null"
                            if (validationRule.RuleId != VDUVerification.TextAllowedValue.AB_NotNull)
                            {
                                myFilteredRows = sheetData.Select(string.Format("[{0}] is not null", reportColumn.ReportColumn)).ToList();
                                if (myFilteredRows.Any())
                                    myFilteredData = myFilteredRows.CopyToDataTable();
                                else
                                    myFilteredData = sheetData.Clone();
                            }
                            else
                            {
                                myFilteredData = sheetData;
                            }       
                        }
                        else
                        {
                            //Build rule filter string in terms of column names
                            //Retrieve filtered dataset to validate with
                            //Failure of this try indicates invalid column logic definition in database
                            try
                            {
                                //Build the filter definition string using column names for display
                                //(e.g. [ACTP] <= [Invoice])
                                myRuleFilterDisp = LogicStatementIdsToNames(myRuleFilterDisp, matchDict);

                                //Checks whether columns required in the filter exist
                                //Skip to next rule if any are missing
                                if (!DoRequiredColumnsExist(myRuleFilter, matchDict, sheetData))
                                {
                                    errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                                                "Missing columns are preventing the column filter " + myRuleFilterDisp,
                                                                reportSheet.SheetName
                                                            )
                                                        );
                                    continue;
                                }

                                //Build filter with CONVERT statements to cast types per database fields
                                myRuleFilter = LogicStatementIdsToNamesWithType(myRuleFilter, matchDict, tableStructure);

                                //Create copy of datatable schema
                                //We will use it to hold a single row at a time while testing rule conditions
                                //Running .select on a large datatable takes a very long time
                                DataTable myDataTableCopy = sheetData.Clone();

                                DataRow dataRow;
                                for (int i = 0; i < sheetData.Rows.Count; i++)
                                {
                                    dataRow = sheetData.Rows[i];
                                    //Import row to perform checks
                                    myDataTableCopy.ImportRow(dataRow);

                                    //If the condition is ill-defined, include the row
                                    try
                                    {
                                        //Use the datatable select method on the single row to check if it meets the dynamic condition
                                        //If this isn't a "not null" rule and the value is null, don't check
                                        if (!(validationRule.RuleId != VDUVerification.TextAllowedValue.AB_NotNull &&
                                             VDUVerification.IsMyValueEmpty(myDataTableCopy.Rows[0][reportColumn.ReportColumn]))
                                            && myDataTableCopy.Select(myRuleFilter).Count() != 0)
                                        {
                                            //If row met condition (i.e. select returned the row) add the ORIGINAL datatable row
                                            //Need this to get correct value when using IndexOf below
                                            myFilteredRows.Add(dataRow);
                                        }
                                    }
                                    catch
                                    {
                                        myFilteredRows.Add(dataRow);
                                    }

                                    //Clear each time - we want to perform checks one by one
                                    myDataTableCopy.Clear();
                                }

                                //If filter returned rows, use as data, otherwise set filtered set to empty datatable with same struct
                                if (myFilteredRows.Any())
                                    myFilteredData = myFilteredRows.CopyToDataTable();
                                else
                                    myFilteredData = sheetData.Clone();
                            }
                            catch(Exception ex)
                            {
                                errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                                    "Invalid column logic definition - please contact administrator",
                                                    reportSheet.SheetName,
                                                    reportColumn.ReportColumn
                                                )
                                            );
                                continue;
                            }
                        }

                        //Need modification of rulevalue to change ColMapId to current column name
                        //This is per how rulevalues are defined in the database - with IDs rather than names
                        //Generates errors for missing columns or bad rule values
                        if (validationRule.RuleId == VDUVerification.TextAllowedValue.AD_UseCustomMultiField)
                        {
                            //Failure of this try indicates invalid column logic definition in database
                            try
                            {
                                //Build the logic definition string using column names for display
                                //(e.g. [ACTP] <= [Invoice])
                                myRuleValueDisp = LogicStatementIdsToNames(myRuleValueDisp, matchDict);

                                if (!DoRequiredColumnsExist(validationRule.RuleValue, matchDict, sheetData))
                                {
                                    errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                                                "Missing columns are preventing the column logic check " + myRuleValueDisp,
                                                                reportSheet.SheetName
                                                            )
                                                        );
                                    continue;
                                }

                                //Update rule value to use column names and convert types per db field types
                                myRuleValue = LogicStatementIdsToNamesWithType(myRuleValue, matchDict, tableStructure);

                                //Get invalid indices which do not meet rule
                                //Does not use verification class implementation as QueryLookup rule is checked per row
                                invalidIndices = MultiFieldInvalidIndicesOverride(myDataTable: myFilteredData,
                                                                                    myColumnName: reportColumn.ReportColumn,
                                                                                    myRuleValue: myRuleValue,
                                                                                    myQueryResult: queryResult);
                            }
                            catch
                            {
                                errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                                    "Invalid column logic definition - please contact administrator",
                                                    reportSheet.SheetName,
                                                    reportColumn.ReportColumn
                                                )
                                            );
                                continue;
                            }
                        }

                        //If list option, convert database view to list for use
                        //Query was executed above
                        else if (validationRule.RuleId == VDUVerification.TextAllowedValue.AC_InProvidedList)
                        {
                            //Convert query result to list
                            //If no query result, return empty list
                            List<string> myRuleList;
                            if (queryResult.Rows.Count == 0)
                                myRuleList = new List<string>();
                            else
                                myRuleList = queryResult.AsEnumerable().Select(x => x[0].ToString()).ToList();

                            //Set rule value to the list as comma delimited for use in the error message
                            myRuleValueDisp = string.Join(", ", myRuleList);

                            //Get invalid indices which do not meet rule
                            invalidIndices = VDUVerification.DataTableInvalidIndices(myTextAllowed: validationRule.RuleId,
                                                                                        myDataTable: myFilteredData,
                                                                                        myColumnName: reportColumn.ReportColumn,
                                                                                        myRuleList: myRuleList);
                        }

                        //Otherwise, just get indices without modifying rules
                        else
                        {
                            //Get invalid indices which do not meet rule
                            invalidIndices = VDUVerification.DataTableInvalidIndices(myTextAllowed: validationRule.RuleId,
                                                                                        myDataTable: myFilteredData,
                                                                                        myColumnName: reportColumn.ReportColumn,
                                                                                        myRuleValue: myRuleValue);
                        }

                        //If filter was applied, get real invalidIndices by finding corresponding row in SheetData
                        if (myFilteredRows.Any())
                        {
                            for (int i = 0; i < invalidIndices.Length; i++)
                            {
                                invalidIndices[i] = sheetData.Rows.IndexOf(myFilteredRows[invalidIndices[i]]);
                            }
                        }

                        //Add error messages for each of the invalid indices
                        errorList.AddRange(ValidationRuleErrorMessages(sheetData, reportSheet.SheetName, invalidIndices,
                                                                       reportSheet.StartCell, reportColumn, validationRule,
                                                                       myRuleValueDisp, myRuleFilterDisp, myRuleMessageOverride,
                                                                       queryResult, connectionString));
                    }
                }
                //If column is missing from excel worksheet
                else
                {
                    errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                            "Column is missing",
                                            reportSheet.SheetName,
                                            reportColumn.ReportColumn
                                        )
                                    );
                }
            }
            return errorList;
        }


        /// <summary>
        /// Generates validationRule error messages given the invalid values.
        /// </summary>
        /// <param name="sheetData">The datatable containing values</param>
        /// <param name="sheetName">Sheet name for use in error message output</param>
        /// <param name="invalidIndices">The list of row indices in the datatable with errors</param>
        /// <param name="startCell">The (row,col) offset of the data for defining Excel cell locations</param>
        /// <param name="reportColumn">The column schema object for which errors are being generated</param>
        /// <param name="validationRule">Validation rule for error</param>
        /// <param name="myRuleValueDisp">Default rule value to be displayed</param>
        /// <param name="myRuleFilterDisp">Default rule filter to be displayed</param>
        /// <param name="errorValue">Value that is invalid</param>
        /// <param name="connectionString">DB connection string</param>
        /// <returns>Composed error message</returns>
        private static List<VDSReportError> ValidationRuleErrorMessages(DataTable sheetData, string sheetName, int[] invalidIndices, Tuple<int,int> startCell, VDSReportColumn reportColumn, VDSValidationRule validationRule, string myRuleValueDisp, string myRuleFilterDisp, string myRuleMessageOverride, DataTable myQueryResult, string connectionString)
        {
            List<VDSReportError> errorList = new List<VDSReportError>();

            //Generate error message for each invalid row index
            foreach (int i in invalidIndices)
            {
                string cellId = VDUExcelHelper.GetExcelCellId(startCell.Item2 + sheetData.Columns[reportColumn.ReportColumn].Ordinal, i + startCell.Item1 + 1); ;
                string errorValue = sheetData.Rows[i][reportColumn.ReportColumn].ToString();
                string errorMessage;

                //Override defined by user
                if (!VDUVerification.IsMyValueEmpty(myRuleMessageOverride))
                {
                    //Try applying querylookup rule to the rule value display
                    //Allows querylookups to be used in the override messages
                    errorMessage = VDSHelper.QueryLookupFillKeyword(myRuleMessageOverride, sheetData.Rows[i], myQueryResult);
                }
                //Default message provided
                else
                {
                    errorMessage = string.Format("{0}{1}{2}",
                                        validationRule.RuleDesc,
                                        VDUVerification.IsMyValueEmpty(myRuleValueDisp) ? "" : " " + myRuleValueDisp,
                                        VDUVerification.IsMyValueEmpty(myRuleFilterDisp) ? "" : " where " + myRuleFilterDisp);
                }

                errorList.Add(new VDSReportError(validationRule.RuleType,
                                errorMessage,
                                sheetName,
                                reportColumn.ReportColumn,
                                cellId,
                                errorValue
                                )
                            );
            }

            return errorList;
        }


        /// <summary>
        /// Attempts to map the raw data to the fields in the server
        /// Checks types and database table rules for maxlength, nulls, and datatypes
        /// </summary>
        /// <param name="sheetData">The datatable being mapped</param>
        /// <param name="tableStructure">A datatable with the schema of the database table</param>
        /// <param name="reportSheet">The report sheet schema being mapped</param>
        /// <param name="mappedData">Output datatable in the format of the database table.
        ///                          Note that invalid rows are NOT included.</param>
        /// <returns>List of processing errors</returns>
        private static List<VDSReportError> MapSheetDataToDb(DataTable sheetData, DataTable tableStructure, VDSReportSheet reportSheet, out DataTable mappedData)
        {
            mappedData = new DataTable();
            List<VDSReportError> errorList = new List<VDSReportError>();

            //If a table is assigned in the database
            if (tableStructure.IsInitialized && tableStructure != null)
            {
                try
                {
                    DataTable clonedTable = sheetData.Clone();
                    foreach (VDSReportColumn vdsReportColumn in reportSheet.ReportColumns)
                    {
                        //Match mapped table column types to DB table column types
                        if (tableStructure.Columns.Contains(vdsReportColumn.DbField) && sheetData.Columns.Contains(vdsReportColumn.ReportColumn))
                        {
                            //If relevant data type error rule with no filter, don't test
                            Type fieldType = tableStructure.Columns[vdsReportColumn.DbField].DataType;
                            if (!HasTypeRule(fieldType, vdsReportColumn.ValidationRules))
                            {
                                clonedTable.Columns[vdsReportColumn.ReportColumn].DataType = tableStructure.Columns[vdsReportColumn.DbField].DataType;
                            }

                            //If there is already a not-null error rule with no filter, don't test
                            if (!vdsReportColumn.ValidationRules.Any(
                                        r => r.RuleId == VDUVerification.TextAllowedValue.AB_NotNull
                                        && VDUVerification.IsMyValueEmpty(r.RuleFilter)
                                        && r.RuleType == VDSVerification.RuleType.Error))
                            {
                                clonedTable.Columns[vdsReportColumn.ReportColumn].AllowDBNull = tableStructure.Columns[vdsReportColumn.DbField].AllowDBNull;
                            }

                            //If there is a max-length error rule with no filter, don't test
                            if (!vdsReportColumn.ValidationRules.Any(
                                        r => r.RuleId == VDUVerification.TextAllowedValue.AF_MaximumLength
                                        && int.Parse(r.RuleValue) == tableStructure.Columns[vdsReportColumn.DbField].MaxLength
                                        && VDUVerification.IsMyValueEmpty(r.RuleFilter)
                                        && r.RuleType == VDSVerification.RuleType.Error))
                            {
                                clonedTable.Columns[vdsReportColumn.ReportColumn].MaxLength = tableStructure.Columns[vdsReportColumn.DbField].MaxLength;
                            }
                        }
                    }

                    //Iterate each raw data row and try importing into the type-matched datatable
                    //On failures, determine which columns could not be converted and add to error log
                    for (int i = 0; i < sheetData.Rows.Count; i++)
                    {
                        try
                        {
                            clonedTable.ImportRow(sheetData.Rows[i]);
                        }
                        catch (Exception ex)
                        {
                            //Check all possible failures in case more than one type of failure occurred
                            if (ex is NoNullAllowedException || (ex is ArgumentException && (ex.InnerException is FormatException || ex.TargetSite.Name.ToUpper() == "CHECKMAXLENGTH")))
                            {
                                //Null value check
                                VDSVerification.DataTableNullCheck(sheetData, clonedTable, i).ForEach(
                                    f => errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                                                        "Must not be null",
                                                                        reportSheet.SheetName,
                                                                        sheetData.Columns[f.Item2].ColumnName,
                                                                        VDUExcelHelper.GetExcelCellId(f.Item2 + reportSheet.StartCell.Item2, f.Item1 + reportSheet.StartCell.Item1 + 1)
                                                                    )
                                                        ));

                                //Invalid conversion error
                                VDSVerification.DataTableConversionFailures(sheetData, clonedTable, i).ForEach(
                                    f => errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                                                        "Must be of type " + clonedTable.Columns[f.Item2].DataType.Name,
                                                                        reportSheet.SheetName,
                                                                        sheetData.Columns[f.Item2].ColumnName,
                                                                        VDUExcelHelper.GetExcelCellId(f.Item2 + reportSheet.StartCell.Item2, f.Item1 + reportSheet.StartCell.Item1 + 1),
                                                                        sheetData.Rows[f.Item1][f.Item2].ToString()
                                                                    )
                                                        ));

                                //Max length check
                                VDSVerification.DataTableMaxLengthCheck(sheetData, clonedTable, i).ForEach(
                                    f => errorList.Add(new VDSReportError(VDSVerification.RuleType.Error,
                                                                        "Exceeds the maximum length of " + clonedTable.Columns[f.Item2].MaxLength,
                                                                        reportSheet.SheetName,
                                                                        sheetData.Columns[f.Item2].ColumnName,
                                                                        VDUExcelHelper.GetExcelCellId(f.Item2 + reportSheet.StartCell.Item2, f.Item1 + reportSheet.StartCell.Item1 + 1),
                                                                        sheetData.Rows[f.Item1][f.Item2].ToString()
                                                                    )
                                                        ));
                            }
                            else
                            {
                                throw;
                            }
                        }
                    }
                    mappedData = clonedTable;
                }
                catch (Exception ex)
                {
                    errorList.Add(new VDSReportError(VDSVerification.RuleType.Error, ex.ToString()));
                }
            }
            return errorList;
        }

        //Check whether a list of rules contains a rule for requiring the field type
        private static bool HasTypeRule(Type fieldType, List<VDSValidationRule> ruleList)
        {
            //If type int or long and integer rule exists...
            if ((fieldType == typeof(int) || fieldType == typeof(long))
                && ruleList.Any(
                    r => r.RuleId == VDUVerification.TextAllowedValue.F_Integer
                    && VDUVerification.IsMyValueEmpty(r.RuleFilter)
                    && r.RuleType == VDSVerification.RuleType.Error))
                return true;

            //If type decimal and decimal rule exists...
            if ((fieldType == typeof(decimal) || fieldType == typeof(double))
                && ruleList.Any(
                    r => r.RuleId == VDUVerification.TextAllowedValue.G_Decimal
                    && VDUVerification.IsMyValueEmpty(r.RuleFilter)
                    && r.RuleType == VDSVerification.RuleType.Error))
                return true;

            //If type datetime and datetime rule exists...
            if (fieldType == typeof(DateTime)
                && ruleList.Any(
                    r => r.RuleId == VDUVerification.TextAllowedValue.L_DateTime
                    && VDUVerification.IsMyValueEmpty(r.RuleFilter)
                    && r.RuleType == VDSVerification.RuleType.Error))
                return true;

            //If type bool and bool rule exists...
            if (fieldType == typeof(bool)
                && ruleList.Any(
                    r => r.RuleId == VDUVerification.TextAllowedValue.Z_Bool
                    && VDUVerification.IsMyValueEmpty(r.RuleFilter)
                    && r.RuleType == VDSVerification.RuleType.Error))
                return true;

            return false;
        }

        /// <summary>
        /// Returns a datatable for both MS Access and SQL Server
        /// </summary>
        /// <param name="mySQL">The sql string SELECT * FROM Employees</param>
        /// <param name="myConnectionString">String for connection to the database (MS Access or SQL Server)</param>
        /// <returns></returns>
        public static DataTable GetDataInTable(string mySQL, string myConnectionString)
        {
            
            using (SqlDataAdapter mySQLDataAdapter = new SqlDataAdapter(mySQL, myConnectionString))
            {
                DataTable myDataTable = new DataTable();
                mySQLDataAdapter.Fill(myDataTable);
                return myDataTable;
            }
            
        }

        public static string PostExcelDataToServer(VDSReport report,
                                                    string fileName,
                                                    string connectionString,
                                                    string myfOSUserName, string UUID = null)
        {
            int uploadId;

            try
            {
                var myReturnAfterAdd = VDSCRUDActual(myOperation: 22,
                                                      myCurrentUser: myfOSUserName,
                                                      myConnection: connectionString,
                                                      mySOID: report.SuborgId,
                                                      myReportId: report.ReportId,
                                                      myReportPeriod: report.ReportPeriod,
                                                      myReportBucket: report.ReportBucket,
                                                      myReportDate: report.VendorDate,
                                                      myAllowReupload: report.AllowReupload,
                                                      myFileName: fileName,
                                                      myUploadComplete: false, 
                                                      myUUID: UUID);

                if (VDUVerification.IsMyValueEmpty(myReturnAfterAdd["@Error"].ToString()) == false)
                {
                    return "Database connection error. Please try again.";
                }

                uploadId = (int)myReturnAfterAdd["@UploadIdReturn"]; //get upload id
            }
            catch (Exception ex)
            {
                string myError = ex.ToString();
                return myError; //Should never get here
            }

            //No longer uses transaction to avoid table lock with bulk insert
            //Deletes values on failure
            //Bulk copy all tab schema objects to the corresponding server table
            using (var sqlBulk = new SqlBulkCopy(connectionString, SqlBulkCopyOptions.CheckConstraints | SqlBulkCopyOptions.KeepNulls))
            {
                sqlBulk.BatchSize = 5000;
                sqlBulk.BulkCopyTimeout = 120;

                foreach (VDSReportSheet VDSReportSheet in report.ReportSheets)
                {
                    DataTable tempTable = VDSReportSheet.SheetData.Copy();

                    //Extra columns to add to each tab schema data table to insert uploadId (scope_identity above) and username
                    DataColumn idColumn = new DataColumn("UploadId", typeof(int));
                    idColumn.DefaultValue = uploadId;
                    DataColumn fOSUserColumn = new DataColumn("RAB", typeof(string));
                    fOSUserColumn.DefaultValue = myfOSUserName;

                    //Add uploadId and username columns
                    tempTable.Columns.Add(idColumn);
                    tempTable.Columns.Add(fOSUserColumn);

                    sqlBulk.DestinationTableName = VDSReportSheet.TableName;
                    sqlBulk.ColumnMappings.Clear();

                    //Generate all report column to db field mappings
                    sqlBulk.ColumnMappings.Add("UploadId", "UploadId");
                    sqlBulk.ColumnMappings.Add("RAB", "RAB");
                    foreach (VDSReportColumn VDSReportColumn in VDSReportSheet.ReportColumns)
                    {
                        sqlBulk.ColumnMappings.Add(VDSReportColumn.ReportColumn, VDSReportColumn.DbField);
                    }

                    //Write data to server
                    try
                    {
                        sqlBulk.WriteToServer(tempTable);
                    }
                    catch (Exception ex)
                    {
                        //Undo if upload fails
                        string myError = ex.ToString();
                        var myReturnAfterAdd = VDSCRUDActual(myOperation: 24,
                                                                  myCurrentUser: myfOSUserName,
                                                                  myConnection: connectionString,
                                                                  myUploadId: uploadId);
                        return myError;
                    }
                }
            }

            //If everything succeeded, flag upload as complete
            try
            {
                var myReturnAfterAdd = VDSCRUDActual(myOperation: 23,
                                                                  myCurrentUser: myfOSUserName,
                                                                  myConnection: connectionString,
                                                                  myUploadId: uploadId);

                if (VDUVerification.IsMyValueEmpty(myReturnAfterAdd["@Error"].ToString()) == false)
                {
                    //Completion error
                    //Should never happen
                    //If it does tell user to contact admin so they can toggle manually and investigate
                    string myError = myReturnAfterAdd["@ErrorDescription"].ToString();
                    return "Unkown error encountered during upload - please contact the module admin";
                }
            }
            catch (Exception ex)
            {
                string myError = ex.ToString();
                return myError; //Should never get here
            }
            return null;
        }

        public static Dictionary<string, object> RunProcedureAndReturnMultipleValues(string mySQLProcedure, List<ProcItems> myInput, string myConnectionString)
        {
            var myOuputArray = new Dictionary<string, object>();
            SqlParameter myParameter;

            using (SqlConnection myLocalConnection = new SqlConnection(myConnectionString))
            {
                myLocalConnection.Open();
                using (SqlCommand myCommand = new SqlCommand(mySQLProcedure, myLocalConnection))
                {
                    myCommand.CommandType = CommandType.StoredProcedure;
                    // Add parameters
                    foreach (var myItem in myInput)
                    {
                        myParameter = new SqlParameter(myItem.Parameter, myItem.SQLType, (int)myItem.OutputStringChar);
                        myParameter.Value = myItem.Value;
                        myParameter.Direction = myItem.Direction;
                        myCommand.Parameters.Add(myParameter);
                    }

                    // Run Procedure
                    using (SqlDataReader myReader = myCommand.ExecuteReader())
                    {

                        // Find all items that have an output parameter as "OUT"
                        foreach (var myItem in myInput.FindAll(x => x.Direction == ParameterDirection.Output))
                        {
                            object myValue = myCommand.Parameters[myItem.Parameter].Value;
                            myOuputArray.Add(myItem.Parameter, myValue);
                        }
                    }
                }
            }
            return myOuputArray;
        }

        //The real CRUD for VDS
        private static Dictionary<string, object> VDSCRUDActual(int myOperation, object myCurrentUser = null, string myConnection = null,
                                                                object myUploadId = null, object myReportId = null, object myReportName = null,
                                                                object myPeriodsPerMonth = null, object myAllowReupload = null, object myEnabled = null,
                                                                object myDataAsOf = null, object myTabMapId = null, object mySheetName = null,
                                                                object myTableName = null, object myColMapId = null, object myColumnName = null, object myDbField = null,
                                                                object myColRuleId = null, object myRuleId = null, object myRuleValue = null, object myRuleFilter = null,
                                                                object myRuleQuery = null, object myRuleMessageOverride = null, object myRuleType = null,
                                                                object myXML = null, object myAVID = null, object myValueCategory = null, object myValue1 = null,
                                                                object myValue2 = null, object mySortNum = null, object myUploadComplete = null, object mySOID = null,
                                                                object myReportPeriod = null, object myReportBucket = null, object myReportDate = null,
                                                                object myFileName = null, object myUUID = null)
        {
            var myInputArray = new List<ProcItems>();
            myInputArray.Add(new ProcItems("@Operation", SqlDbType.TinyInt, myOperation, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@CurrentUser", SqlDbType.VarChar, myCurrentUser ?? DBNull.Value, ParameterDirection.Input));

            myInputArray.Add(new ProcItems("@UploadId", SqlDbType.Int, myUploadId ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@UploadComplete", SqlDbType.Bit, myUploadComplete ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@SOID", SqlDbType.Int, mySOID ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@UUID", SqlDbType.VarChar, myUUID ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@ReportPeriod", SqlDbType.Int, myReportPeriod ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@ReportBucket", SqlDbType.DateTime, myReportBucket ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@ReportDate", SqlDbType.DateTime, myReportDate ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@FileName", SqlDbType.VarChar, myFileName ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@ReportId", SqlDbType.Int, myReportId ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@AllowReupload", SqlDbType.Bit, myAllowReupload ?? DBNull.Value, ParameterDirection.Input));
            myInputArray.Add(new ProcItems("@UploadIdReturn", SqlDbType.Int, DBNull.Value, ParameterDirection.Output));
            myInputArray.Add(new ProcItems("@Error", SqlDbType.Int, DBNull.Value, ParameterDirection.Output));
            myInputArray.Add(new ProcItems("@ErrorDescription", SqlDbType.VarChar, DBNull.Value, ParameterDirection.Output, 8000));

            var myOutputArray = RunProcedureAndReturnMultipleValues("[stng].[SP_VDU_CRUD]", myInputArray, myConnection);
            return myOutputArray;
        }
        #endregion
    }

    public class ProcItems
    {
        public string Parameter { get; set; }
        public SqlDbType SQLType { get; set; }
        public object Value { get; set; }
        public ParameterDirection Direction { get; set; }
        public int? OutputStringChar { get; set; }

        /// <param name="myParameter">Name of the paramater used in the SQL stored procedure</param>
        /// <param name="mySQLType">The type of SQL data type</param>
        /// <param name="myValue">The actual value that needs to be passed to the procedure. Note that for OUTPUT variables, this value is vbEmpty</param>
        /// <param name="myDirection">Whether this parameters neeeds to go in or out of the procedure</param>
        /// <remarks></remarks>
        public ProcItems(string myParameter, SqlDbType mySQLType, object myValue, ParameterDirection myDirection, int? myOutputStringChar = 0)
        {
            Parameter = myParameter;
            SQLType = mySQLType;
            Value = myValue;
            Direction = myDirection;
            OutputStringChar = myOutputStringChar;
        }
    }
}