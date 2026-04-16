using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.Models.VDU
{
    //A class used to store information about an Excel tab for the purpose of file structure validation
    public class VDSReportSheet
    {
        public int TabMapId { get; private set; }

        private string _sheetName;
        public string SheetName
        {
            get { return _sheetName; }
            set
            {
                _sheetName = value.Truncate(31);
            }
        }

        public string TableName { get; set; }
        public List<VDSReportColumn> ReportColumns { get; set; }

        public DataTable SheetData { get; set; }
        public Tuple<int, int> StartCell { get; set; }

        public VDSReportSheet(int tabMapId, string sheetName, string tableName)
        {
            //Assign sheet variables
            TabMapId = tabMapId;
            SheetName = sheetName;
            TableName = tableName;
            ReportColumns = new List<VDSReportColumn>();
            SheetData = new DataTable();
        }
    }
}