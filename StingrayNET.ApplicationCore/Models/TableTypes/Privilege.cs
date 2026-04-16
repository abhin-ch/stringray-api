using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.TableTypes;

public class AppSecurity : BaseTableType
{
    public override string TableName => "stng.App_AppSecurity";
    public string Module { get; set; }
    public string Name { get; set; }
    public string Type { get; set; }
    public string Description { get; set; }
    public string? Location { get; set; } = null;
    public string Endpoint { get; set; }
}
