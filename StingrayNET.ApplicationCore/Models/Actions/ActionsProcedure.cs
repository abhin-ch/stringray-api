using System;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Actions;
public class ActionsProcedure : BaseProcedure
{
    public int? ActID { get; set; } = null;
    public int? Unit { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public int? ProjectID { get; set; } = null;
    public string? ProjectName { get; set; } = null;
    public string? Owner { get; set; } = null;
    public string? OwnerSearch { get; set; } = null;
    public string? Description { get; set; } = null;
    public DateTime? TCD { get; set; } = null;
    public string? Status { get; set; } = null;
    public int? Rev { get; set; } = null;
    public string? CreatedBy { get; set; } = null;
    public DateTime? CreatedDate { get; set; } = null;
    public string? ActionUpdate { get; set; } = null;
}
