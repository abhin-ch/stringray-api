using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.Models.VDU
{
    //A class used to store information about an Excel column for the purpose of file structure and value validation
    public class VDSReportColumn
    {
        public int ColMapId { get; private set; }

        //Columns cannot contain certain characters to avoid interfering with
        //DataColumn Expressions in multi-field rules and filters
        private string _reportColumn;
        public string ReportColumn
        {
            get { return _reportColumn; }
            set
            {
                _reportColumn = Regex.Replace(value, @"[\\\[\]@`=&,]", "");
            }
        }

        public string DbField { get; set; }
        public List<VDSValidationRule> ValidationRules { get; set; }

        public VDSReportColumn(int colMapId, string reportColumn, string dbField)
        {
            ColMapId = colMapId;
            ReportColumn = reportColumn;
            DbField = dbField;
            ValidationRules = new List<VDSValidationRule>();
        }
    }
}