using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using System;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.PCC;

public class PCCProcedure : BaseProcedure
{
    public TableType<PCCMinorChangeTableType>? MinorChanges { get; set; }
    public bool? TrackChange { get; set; }
    public string? ProjectID { get; set; }
    public string? DVNID { get; set; }
    public int? DVNNumber { get; set; }
    public string? NextStatus { get; set; }
    public string? ActivityID { get; set; }
    public DateTime? DVNActivityRevisedCommitmentDate { get; set; }
    public string? SCR { get; set; }
    public string? ReasonCodeID { get; set; }
    public string? Comment { get; set; }
    public string? DVNRationale { get; set; }
    public bool? VerifyActivity { get; set; } = false;
    public int? SDQID { get; set; }
    public string? P6RunID { get; set; }
    public int? Phase { get; set; }
    public string? RecordType { get; set; }
    public int? PBRID { get; set; }
    public bool? MyRecords { get; set; }
    public string? ForecastUUID { get; set; }
    public string? PipelineID { get; set; }
    public string? WBSCode { get; set; }
    public int? SDSWPOverride { get; set; }
    public bool? CV { get; set; }

    public int? RecordUID { get; set; }
    public string? ChecklistType { get; set; }
    public string? InstanceQuestionID { get; set; }
    public string? ChecklistSupportingData { get; set; }
    public string? QuestionResponse { get; set; }
    public double? CurrentApproval { get; set; }
    public double? CurrentApprovalScope { get; set; }
    public string? CustomerApprovalID { get; set; }
    public DateTime? RevisedCommitmentDate { get; set; }
    public string? TOQID { get; set; }
    public List<DVNActivity>? DVNActivities { get; set; }
    public bool? Legacy { get; set; }
    public string? ScopeOrTrendID { get; set; }
    public bool? ActivityNoChange { get; set; }

    public string? RespOrg { get; set; }
    public string? MultipleVendor { get; set; }
    public double? FundingAllocation { get; set; }
    public double? FinalBIMSCommit { get; set; }
    public double? OverallFinalBIMSCommit { get; set; }
}