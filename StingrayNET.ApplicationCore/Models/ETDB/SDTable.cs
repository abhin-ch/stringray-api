using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.ETDB;

public class SDTable : BaseTableType
{
    public override string TableName => "stng.ETDB_ScopeDetail";

    public long SDID { get; set; }
    public string Number { get; set; }
    public string Type { get; set; }
    public string Description { get; set; }
    public int EstimatedHours { get; set; }

}