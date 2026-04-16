

namespace StingrayNET.ApplicationCore.Requests.PCC;

public class PCCGetPCCMainRequest
{
    public string? EmployeeID { get; set; }
    public bool MyRecords { get; set; }
    public bool MyDelegations { get; set; }
    public string? Type { get; set; }
}