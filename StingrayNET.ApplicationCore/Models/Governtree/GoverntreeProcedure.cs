
using System;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Governtree;

public class GoverntreeProcedure : BaseProcedure
{
    public string? DocumentNo { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public string? GTID { get; set; } = null;
    public int? UniqueID { get; set; } = null;
    public string? JobAidTitle { get; set; } = null;
    public string? JobAidID { get; set; } = null;
    public string? JobAidURL { get; set; } = null;
    public string? IndustryStandardSection { get; set; } = null;
    public string? Org { get; set; } = null;
    public string? IndustryStandard { get; set; } = null;
    public string? IndustryStandardSectionID { get; set; } = null;
    public string? PersonnelType { get; set; } = null;
    public string? OrgType { get; set; } = null;
    public string? ProcessOwner { get; set; } = null;
    public string? IndustryStandardTitle { get; set; } = null;
    public string? IndustryStandardSectionTitle { get; set; } = null;
    public string? TCorTSC { get; set; } = null;
    public string? actionname { get; set; } = null;
    public string? status { get; set; } = null;
    public string? description { get; set; } = null;
    public DateTime? tcd { get; set; } = null;
    public string? actiontitle { get; set; } = null;
    public int? JobAidNum { get; set; } = null;
    public int? ReferenceCount { get; set; } = null;
    public int? FormCount { get; set; } = null;
    public int? StandardCount { get; set; } = null;
    public int? DCRCount { get; set; } = null;
    public int? JobAidCount { get; set; } = null;
    public int? IntID { get; set; } = null;
    public bool? DocumentAttached { get; set; } = null;
    public string? Governance { get; set; } = null;
    public string? Excellence { get; set; } = null;
    public string? Compliance { get; set; } = null;
    public string? Comment { get; set; } = null;
    public int? PHID { get; set; } = null;
    public string? HealthSection { get; set; } = null;
    public string? Action { get; set; } = null;
    public string? Responsibility { get; set; } = null;
    public DateTime? DueDate { get; set; } = null;
    public string? StatusID { get; set; } = null;
    public int? ActionID { get; set; } = null;

}
