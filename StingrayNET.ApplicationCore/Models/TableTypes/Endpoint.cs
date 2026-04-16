using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.TableTypes;

public class Endpoint : BaseTableType
{
    public override string TableName => "stng.App_Endpoint";
    public string Module { get; set; }
    public string Route { get; set; }
    public string Method { get; set; }
    public string GetKey() => $"{Module}/{Route}/{Method.ToUpper()}";
}
