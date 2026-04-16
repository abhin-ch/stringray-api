using System;

namespace StingrayNET.ApplicationCore.Models.PCC.PBRF;

public class PBRFModel
{
    public string Type { get; set; }
    public string UniqueID { get; set; }
    public string RecordTypeUniqueID { get; set; }
    public string ParentPBRUID { get; set; }
    public string ProjectNo { get; set; }
    public string RecordID { get; set; }
    public int? Revision { get; set; }
    public string ProjectTitle { get; set; }
    public string StatusID { get; set; }
    public string Status { get; set; }
    public string StatusValue { get; set; }
    public DateTime? CurrentPBRStatusDate { get; set; }
    public string RequestFrom { get; set; }
    public DateTime? RequestDate { get; set; }
    public string RequestFromID { get; set; }
    public string RC { get; set; }
    public string RCID { get; set; }
    public string ProblemStatement { get; set; }
    public string Objective { get; set; }
    public string CustomerNeed { get; set; }
    public DateTime? CustomerNeedDate { get; set; }
    public string CustomerNeedID { get; set; }
    public string FundingSource { get; set; }
    public string FundingSourceID { get; set; }
    public string ProjectTypeID { get; set; }
    public string ProjectType { get; set; }
    public string Section { get; set; }
    public string SMID { get; set; }
    public string SM { get; set; }
    public string DMID { get; set; }
    public string DM { get; set; }
    public string DivMID { get; set; }
    public string DivM { get; set; }
    public string Scope { get; set; }
    public string InformationReferences { get; set; }
    public string Station { get; set; }
    public decimal? Year1 { get; set; }
    public decimal? Internal1 { get; set; }
    public decimal? External1 { get; set; }
    public decimal? Year2 { get; set; }
    public decimal? Internal2 { get; set; }
    public decimal? External2 { get; set; }
    public decimal? Total { get; set; }
    public DateTime? SMApprovalDate { get; set; }
    public DateTime? DMApprovalDate { get; set; }
    public DateTime? DivMApprovalDate { get; set; }


}