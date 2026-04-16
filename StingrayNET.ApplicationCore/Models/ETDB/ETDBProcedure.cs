using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.ETDB;
public class ETDBProcedure : BaseProcedure
{
#nullable enable
    public TDS? TDS { get; set; } = null;
    public string? Comment { get; set; }
#nullable disable
}