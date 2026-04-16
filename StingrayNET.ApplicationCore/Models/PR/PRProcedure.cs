using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.PR;
public class PRProcedure : BaseProcedure
{

    public class Strategy
    {
        public string? id { get; set; }
        public string? name { get; set; }
        public bool value { get; set; }
    }

    public string? Other { get; set; } = null;
    public int? APNum { get; set; } = null;
    public string? ITEMNUM { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public string? Title { get; set; } = null;
    public string? Manufacturer { get; set; } = null;
    public string? Model { get; set; } = null;
    public string? Station { get; set; } = null;
    public string? Description { get; set; } = null;
    public string? Justification { get; set; } = null;
    public string? PartDescription { get; set; } = null;
    public string? BPStatus { get; set; } = null;
    public bool? LegacyAP { get; set; } = null;
    public bool? HideCanceled { get; set; } = null;
    public string? SolutionID { get; set; } = null;
    public string? APID { get; set; } = null;
    public List<Strategy>? Solutions { get; set; } = null;
    public int? AttributeID { get; set; } = null;
    public int? CommentID { get; set; } = null;
    public string? Comment { get; set; } = null;
    public string? SearchVal { get; set; } = null;
    public string? Attribute { get; set; } = null;
    public string? Type { get; set; } = null;
}
