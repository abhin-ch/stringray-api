

namespace StingrayNET.ApplicationCore.Requests.PCC;

public class PCCUpdateStatusValidationRequest
{
    public string RecordType { get; set; }
    public int RecordUID { get; set; }
    public string NextStatus { get; set; }
    public string? CurrentStatus { get; set; }
    public string? EmployeeID { get; set; }

}