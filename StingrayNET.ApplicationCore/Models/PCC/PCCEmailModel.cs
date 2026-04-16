
namespace StingrayNET.ApplicationCore.Models.PCC;
public class PCCEmailModel
{
    public int? Operation { get; set; } = null;

    public byte? SubOp { get; set; } = null;
    public string? EmployeeID { get; set; } = null;
    public string? Value1 { get; set; } = null;
    public string? Value2 { get; set; } = null;
    public string? Value3 { get; set; } = null;
    public string? RecordType { get; set; } = null;

}