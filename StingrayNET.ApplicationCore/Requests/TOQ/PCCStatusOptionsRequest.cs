using System;
using StingrayNET.ApplicationCore.Models.TOQ;

namespace StingrayNET.ApplicationCore.Requests.TOQ;

public class TOQStatusOptionsRequest
{
    //public string RecordType { get; set; }
    public int TMID { get; set; }
    public string EmployeeID => _employeeID;
    public string Type { private get; set; }
    public TOQType TOQType => Enum.Parse<TOQType>(Type);
    public string StatusValue { get; set; }

    public void SetEmployeeID(string employeeID) => _employeeID = employeeID;


    private string _employeeID = string.Empty;
}