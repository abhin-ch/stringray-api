using System;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Delegate;
public class DelegateProcedure : BaseProcedure
{
    public string? Delegator { get; set; } = null;
    public string? Delegatee { get; set; } = null;
    public DateTime? ExpiryDate { get; set; } = null;


    // public int? SOID { get; set; } = null;
    // public DateTime? ReportMonth { get; set; } = null;
    // public int? ReportId { get; set; } = null;
    // public int? TabMapId { get; set; } = null;
    // public int? UploadId { get; set; } = null;
    // public bool? DisplayName { get; set; } = null;
    // public string? tblRules { get; set; } = null;

    // public string? FullName { get; set; } = null;
}
