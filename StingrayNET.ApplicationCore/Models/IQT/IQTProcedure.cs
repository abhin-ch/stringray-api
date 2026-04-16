using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.IQT;
public class IQTProcedure : BaseProcedure
{
    public string? ITEMNUM { get; set; } = null;
    public bool? Wildcard { get; set; } = null;
    public bool? AnyWords { get; set; } = null;
    public bool? GetDistinctItems { get; set; } = null;

    public string? TopItem { get; set; } = null;

    public string? Location { get; set; } = null;

    public string? SiteID { get; set; } = null;

    public string? ITEMDESC { get; set; } = null;

    public string? WONUM { get; set; } = null;

    public string? ItemList { get; set; } = null;

    public bool? PassportDocs { get; set; } = null;
    public string? CSType { get; set; } = null;
}
