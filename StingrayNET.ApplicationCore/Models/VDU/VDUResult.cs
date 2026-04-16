using StingrayNET.ApplicationCore.Abstractions;
using System.Data;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.VDU;

public class VDUResult : BaseOperation {

    public DataTable reportInfo { get; set; }
    public DataTable sheetSchema { get; set; }
    public DataTable columnSchema { get; set; }
    public DataTable ruleSchema { get; set; }
    public List<VDSReportError> ReportErrors { get; set; }
    
 }