using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.IO;
using System.Data.OleDb;
using OfficeOpenXml;
using System.Configuration;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using static StingrayNET.ApplicationCore.Models.VDU.VDSVerification;
using StingrayNET.ApplicationCore.HelperFunctions;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.Models.VDU
{
    public class VDSReport
    {

        #region Upload Paramaters
        public int? VendorId { get; set; }
        public int? SuborgId { get; set; }
        public int? ReportPeriod { get; set; }

        //Report bucket is always the first of a month
        private DateTime? _reportBucket;
        public DateTime? ReportBucket
        {
            get { return _reportBucket;  }
            set
            {
                if (value == null)
                    _reportBucket = null;
                else
                {
                    DateTime dt = (DateTime)value;
                    _reportBucket = new DateTime(dt.Year, dt.Month, 1);
                }
                    
            }
        }

        //Vendor date is always midnight of the day
        private DateTime? _vendorDate;
        public DateTime? VendorDate
        {
            get { return _vendorDate; }
            set
            {
                if (value == null)
                    _vendorDate = null;
                else
                {
                    _vendorDate = value.Value.Date;
                }
            }
        }

        //For reuploads, what upload ID is this overwriting?
        public int? ReuploadPreviousId { get; set; }
        #endregion

        #region General Report Settings
        public int ReportId { get; private set; }

        //Report name, limited to 50 chars
        private string _reportName;
        public string ReportName
        {
            get { return _reportName; }
            set
            {
                _reportName = value.Truncate(50);
            }
        }

        //Periods of the report in a given month
        private int _periodsPerMonth;
        public int PeriodsPerMonth {
            get { return _periodsPerMonth; }
            set
            {
                if (value < 1)
                    _periodsPerMonth = 1;
                else
                    _periodsPerMonth = value;
            }
        }

        public bool AllowReupload { get; set; }
        public bool Enabled { get; set; }
        public DataAsOf DataDate{ get; set; }
        #endregion

        //Report data sheets
        public List<VDSReportSheet> ReportSheets { get; private set; }

        /// <summary>
        /// Set up report without upload properties
        /// </summary>
        /// <param name="reportId"></param>
        public VDSReport(int reportId)
        {
            ReportId = reportId;
            ReportSheets = new List<VDSReportSheet>();
        }

        
        /// <summary>
        /// Set up report for upload with upload properties
        /// </summary>
        /// <param name="reportId"></param>
        /// <param name="vendorId"></param>
        /// <param name="suborgId"></param>
        /// <param name="reportPeriod"></param>
        /// <param name="reportBucket"></param>
        /// <param name="vendorDate"></param>
        /// <param name="reuploadPreviousId"></param>
        public VDSReport(int reportId, int? vendorId, int? suborgId, int? reportPeriod,
                         DateTime? reportBucket, DateTime? vendorDate, int? reuploadPreviousId = null)
        {
            ReportId = reportId;
            VendorId = vendorId;
            SuborgId = suborgId;
            ReportPeriod = reportPeriod;
            ReportBucket = reportBucket;
            VendorDate = vendorDate;
            ReuploadPreviousId = reuploadPreviousId;
            ReportSheets = new List<VDSReportSheet>();
        }

        /// <summary>
        /// Generates report schema from database, assigning properties and sheet structures
        /// </summary>
        /// <param name="reportId">Report ID per database</param>
        /// <param name="connectionString">DB connection</param>
        public void GenerateSchema(string connectionString, DataTable reportInfo,DataTable sheetSchema, DataTable columnSchema, DataTable ruleSchema)
        {
            //Assign properties from DB, then generate sheet schema
            AssignReportProperties(connectionString, reportInfo);
            ReportSheets = GetReportSchema(connectionString, sheetSchema,columnSchema,ruleSchema);
        }

        /// <summary>
        /// Assigns report-level properties to a VDS report
        /// </summary>
        /// <param name="connectionString">Connection string</param>
        /// <returns></returns>
        private void AssignReportProperties(string connectionString, DataTable reportInfo)
        {
            try
            {
                //Get report-level properties
                //string mySql = string.Format("SELECT * FROM dems.VV_0207_View0095 WHERE ReportID = {0}", ReportId);
                //---------
                // string mySql = string.Format("EXEC [dems].[PR_0638_VDUMisc] @Operation = 29, @ReportId = {0}", ReportId);
                // DataTable reportInfo = CRUD.GetDataInTable(mySql, connectionString);
                ReportName = reportInfo.Rows[0]["ReportName"].ToString();
                PeriodsPerMonth = (int)reportInfo.Rows[0]["PeriodsPerMonth"];
                AllowReupload = (bool)reportInfo.Rows[0]["AllowReupload"];
                Enabled = (bool)reportInfo.Rows[0]["Enabled"];
                DataDate = (DataAsOf)reportInfo.Rows[0]["DataAsOf"];
            }
            catch (Exception ex)
            {
                string myError = ex.ToString();
            }
        }

        /// <summary>
        /// Returns a list of VDSReportSheet objects representing excel file schemas. Empty list if errors
        /// </summary>
        /// <param name="connectionString">Connection string</param>
        /// <returns>A list of reportsheet objects representing a report schema</returns>
        private List<VDSReportSheet> GetReportSchema(string connectionString,DataTable sheetSchema, DataTable columnSchema, DataTable ruleSchema)
        {
            List<VDSReportSheet> reportSheets = new List<VDSReportSheet>();
            try
            {
                //Get report sheet data
                //string mySql = string.Format(@"SELECT * FROM dems.VV_0208_View0096 WHERE ReportId = {0}", ReportId);
                //--------------
                // string mySql = string.Format(@"EXEC [dems].[PR_0638_VDUMisc] @Operation = 30, @ReportId = {0}", ReportId);
                // DataTable sheetSchema = CRUD.GetDataInTable(mySql, connectionString);

                //Get report column data
                //mySql = string.Format(@"SELECT * FROM dems.VV_0209_View0097 WHERE ReportId = {0}", ReportId);
                //--------------
                // mySql = string.Format(@"EXEC [dems].[PR_0638_VDUMisc] @Operation = 31, @ReportId = {0}", ReportId);
                // DataTable columnSchema = CRUD.GetDataInTable(mySql, connectionString);

                //Get report column rule data
                //mySql = string.Format(@"SELECT * FROM dems.VV_0301_View0098 WHERE ReportId = {0}", ReportId);
                //--------------
                // mySql = string.Format(@"EXEC [dems].[PR_0638_VDUMisc] @Operation = 32, @ReportId = {0}", ReportId);
                // DataTable ruleSchema = CRUD.GetDataInTable(mySql, connectionString);

                foreach(DataRow sheetRow in sheetSchema.Rows)
                {
                    //Create base sheet object
                    int tabMapId = (int)sheetRow["TabMapId"];
                    VDSReportSheet reportSheet = new VDSReportSheet(tabMapId,
                                                                    (sheetRow["SheetName"] ?? "").ToString(),
                                                                    (sheetRow["TableName"] ?? "").ToString());

                    //Fill with columns for this tabMapId
                    foreach(DataRow columnRow in columnSchema.AsEnumerable()
                                                             .Where(r => (int)r["TabMapId"] == tabMapId)
                                                             .Select(r => r))
                    {
                        int colMapId = (int)columnRow["ColMapId"];
                        VDSReportColumn reportColumn = new VDSReportColumn(colMapId,
                                                                           (columnRow["ReportColumn"] ?? "").ToString(),
                                                                           (columnRow["DbField"] ?? "").ToString());

                        //Fill with rules for this colMapId
                        foreach(DataRow ruleRow in ruleSchema.AsEnumerable()
                                                             .Where(r => (int)r["ColMapId"] == colMapId)
                                                             .Select(r => r))
                        {
                            VDSValidationRule columnRule = new VDSValidationRule((int)ruleRow["ColRuleId"],
                                                                                 (VDUVerification.TextAllowedValue)ruleRow["RuleId"],
                                                                                 (ruleRow["RuleValue"] ?? "").ToString(),
                                                                                 (ruleRow["RuleFilter"] ?? "").ToString(),
                                                                                 (ruleRow["RuleQuery"] ?? "").ToString(),
                                                                                 (ruleRow["RuleMessageOverride"] ?? "").ToString(),
                                                                                 (ruleRow["RuleDesc"] ?? "").ToString(),
                                                                                 (RuleType)ruleRow["RuleType"]);

                            reportColumn.ValidationRules.Add(columnRule);
                        }
                        reportSheet.ReportColumns.Add(reportColumn);
                    }
                    reportSheets.Add(reportSheet);
                }
            }
            catch (Exception ex)
            {
                string myError = ex.ToString();
            }
            return reportSheets;
        }
    }
}