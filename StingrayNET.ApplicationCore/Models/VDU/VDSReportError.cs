using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

//namespace DEMSLib
namespace StingrayNET.ApplicationCore.Models.VDU
{
    public class VDSReportError
    {
        public string SheetName { get; set; }
        public string ColumnName { get; set; }
        public string Cell { get; set; }
        public VDSVerification.RuleType RuleType { get; set; }
        public string ErrorValue { get; set; }
        public string ErrorMessage { get; set; }

        public VDSReportError(VDSVerification.RuleType ruleType, string errorMessage, string sheetName = null, string columnName = null, string cell = null, string errorValue = null)
        {
            SheetName = sheetName;
            ColumnName = columnName;
            Cell = cell;
            ErrorValue = errorValue;
            ErrorMessage = errorMessage;
            RuleType = ruleType;
        }

    }
}
