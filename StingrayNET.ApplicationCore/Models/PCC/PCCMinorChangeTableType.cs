using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.PCC;

public class PCCMinorChangeTableType : BaseTableType
{
    public override string TableName => "stng.Budgeting_MinorChange";
    public string? UniqueID { get; set; }
    public string? ChangeType { get; set; }
    public string? Comment { get; set; }
    public string? PCSApply { get; set; }
    public string? PCSComment { get; set; }
    public string? AdminUpdated { get; set; }

}