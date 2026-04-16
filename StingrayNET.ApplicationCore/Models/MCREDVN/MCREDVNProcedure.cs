using System;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.MCREDVN;
public class MCREDVNProcedure : BaseProcedure
{
    public int? DVNID { get; set; } = null;
    public int? DVNActivityDetailID { get; set; } = null;
    public int? DVNActivityMRoCWeightID { get; set; } = null;
    public string? Unit { get; set; } = null;
    public string? ProjectID { get; set; } = null;
    public string? ProjectName { get; set; } = null;
    public string? SubProject { get; set; } = null;
    public string? ActivityID { get; set; } = null;
    public string? DVNCause { get; set; } = null;
    public string? PCS { get; set; } = null;
    public string? OE { get; set; } = null;
    public string? PM { get; set; } = null;
    public string? SM { get; set; } = null;
    public string? DM { get; set; } = null;
    public string? IsApprover { get; set; } = null;
    public string? Comments { get; set; } = null;
    public string? Description { get; set; } = null;
    public DateTime? RevisedDate { get; set; } = null;
    public DateTime? CurrentDate { get; set; } = null;
    public string? ActivityName { get; set; } = null;
    public string? CurrentMRoCWeight { get; set; } = null;
    public string? RevisedMRoCWeight { get; set; } = null;
    public string? ScopeTrend { get; set; } = null;
    public string? Reason { get; set; } = null;
    public string? SCRNum { get; set; } = null;
    public string? Status { get; set; } = null;
    public string? DVNUpdate { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public int? Rev { get; set; } = null;
    public int? IsComplete { get; set; } = null;
    public string? Field { get; set; } = null;
    public string? CreatedBy { get; set; } = null;
    public DateTime? CreatedDate { get; set; } = null;
}
