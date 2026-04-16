using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.EQDB;

public class EQDBProcedure : BaseProcedure
{

    public string? CurrentUser { get; set; } = null;
    public string? UniqueID { get; set; } = null;
    public string? EQDBID { get; set; } = null;
    public string? Location { get; set; } = null;
    public string? Facility { get; set; } = null;
    public string? DocName { get; set; } = null;
    public string? PMNum { get; set; } = null;
    public string? AMLNum { get; set; } = null;
    public string? EC { get; set; } = null;
    public string? DCR { get; set; } = null;

    public bool? EQEBOM { get; set; } = null;
    public bool? AMLInstalled { get; set; } = null;
    public bool? PredefinedCheck { get; set; } = null;
    public bool? EQDocCheck { get; set; } = null;
    public bool? PredefinedComplete { get; set; } = null;

    public string? EQEBOMReason { get; set; } = null;
    public string? AMLInstalledReason { get; set; } = null;
    public string? PredefinedCheckReason { get; set; } = null;
    public string? EQDocCheckReason { get; set; } = null;
    public string? PredefinedCompleteReason { get; set; } = null;
    public string? OutstandingChanges { get; set; } = null;

}