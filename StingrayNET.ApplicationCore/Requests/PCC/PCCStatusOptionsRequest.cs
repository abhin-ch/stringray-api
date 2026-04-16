namespace StingrayNET.ApplicationCore.Requests.PCC;

public class PCCStatusOptionsRequest
{
    public string RecordType { get; set; }
    public int RecordUID { get; set; }
    public string EmployeeID => _employeeID;
    public string StatusValue { get; set; }

    public void SetEmployeeID(string employeeID) => _employeeID = employeeID;


    private string _employeeID = string.Empty;
}

public class PBRFStatusRequest
{

}