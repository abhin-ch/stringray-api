
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.TWP;
public class TWPProcedure : BaseProcedure
{
    public decimal? PK_ID { get; set; }

    public string? ProjectID { get; set; }

    public bool? Flagged { get; set; }

    public decimal? Parent_ID { get; set; }

    public string? EC { get; set; } = null;
    public string? Description { get; set; } = null;
    public string? Status { get; set; } = null;
    public string? JPNum { get; set; } = null;
    public string? Site { get; set; } = null;
}
