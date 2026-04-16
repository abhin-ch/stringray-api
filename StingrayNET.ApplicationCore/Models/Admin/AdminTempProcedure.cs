

using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Admin;

public class AdminTempProcedure : BaseProcedure
{
    public string? CurrentUser { get; set; } = null;
    public string? Attribute { get; set; } = null;
    public string? AttributeType { get; set; } = null;

}

