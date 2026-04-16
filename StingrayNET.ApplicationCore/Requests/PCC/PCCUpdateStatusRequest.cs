namespace StingrayNET.ApplicationCore.Requests.PCC;

public class PCCUpdateStatusRequest
{
    public string? EmployeeID { get; set; }
    public int ID { get; set; } = 0;
    public string RecordType { get; set; }
    public string NextStatus { get; set; }
    public string? Comment { get; set; }

}