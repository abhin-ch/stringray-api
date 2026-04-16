namespace StingrayNET.ApplicationCore.Requests.PCC;

public class PCCTabVisibilityRequest
{
    public string RecordType { get; set; }
    public string RecordUID { get; set; }
    public string EmployeeID => _employeeID;
    public string StatusCode { get; set; }
    public string TabName { get; set; }

    public void SetEmployeeID(string employeeID) => _employeeID = employeeID;


    private string _employeeID = string.Empty;
}

