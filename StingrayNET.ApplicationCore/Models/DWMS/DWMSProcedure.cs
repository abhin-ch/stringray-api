
using System;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.DWMS;

public class DWMSProcedure : BaseProcedure
{

    public class Cat
    {
        public string? id { get; set; }
        public string? name { get; set; }
        public bool value { get; set; }
    }

    public string? CurrentUser { get; set; } = null;
    public string? UniqueID { get; set; } = null;
    public string? DWMSID { get; set; } = null;
    public string? Project { get; set; } = null;
    public string? Source { get; set; } = null;
    public string? SourceNum { get; set; } = null;
    public string? Type { get; set; } = null;
    public string? Rev { get; set; } = null;
    public string? SubJob { get; set; } = null;
    public string? SubJobNum { get; set; } = null;
    public string? Disciple { get; set; } = null;
    public string? Unit { get; set; } = null;
    public string? Category { get; set; } = null;
    public string? Drafter { get; set; } = null;
    public string? Checker { get; set; } = null;
    public string? Customer { get; set; } = null;
    public DateTime? ReceivedDate { get; set; } = null;
    public DateTime? AssessedDate { get; set; } = null;
    public DateTime? StartedDate { get; set; } = null;
    public DateTime? RequiredDate { get; set; } = null;
    public DateTime? CompletedDate { get; set; } = null;
    public DateTime? TCD { get; set; } = null;
    public string? Estimate { get; set; } = null;
    public string? Actual { get; set; } = null;
    public int? PercentComplete { get; set; } = null;
    public string? Status { get; set; } = null;
    public string? Comments { get; set; } = null;
    public string? Description { get; set; } = null;
    public string? RAD { get; set; } = null;
    public string? RAB { get; set; } = null;
    public string? Owner { get; set; } = null;
}
