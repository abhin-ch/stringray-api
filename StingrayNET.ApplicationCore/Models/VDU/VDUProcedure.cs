using System;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.VDU;
public class VDUProcedure : BaseProcedure
{
    public int? VENID { get; set; } = null;
    public int? SOID { get; set; } = null;
    public DateTime? ReportMonth { get; set; } = null;
    public int? ReportId { get; set; } = null;
    public int? TabMapId { get; set; } = null;
    public int? UploadId { get; set; } = null;
    public bool? DisplayName { get; set; } = null;
    public string? tblRules { get; set; } = null;
    public int? ReportPeriod { get; set; } = null;
    public DateTime? ReportBucket { get; set; } = null;
    public DateTime? ReportDate { get; set; } = null;
    public string? FileName { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public string? UUID { get; set; } = null;

    // public string? FullName { get; set; } = null;
}