using System;

namespace StingrayNET.ApplicationCore.Models.PCC.SDQ;

public class SDQModel
{
    public string? DEDPlanner { get; set; } = string.Empty;
    public string? PCS { get; set; } = string.Empty;
    public string? OE { get; set; } = string.Empty;
    public string? SM { get; set; }
    public string? DM { get; set; }
    public string? ProjectM { get; set; }
    public string? ProgramM { get; set; }
    public int? PreviouslyApproved { get; set; }
    public int? RequestedScope { get; set; }
    public string? FundingSource { get; set; }
    public string? Verifier { get; set; }
    public string? Complexity { get; set; }
    public string? BusinessDriver { get; set; }
    public string? PrimaryDiscipline { get; set; }
    public DateTime? DMApprovalDate { get; set; } = null!;

    public string LeadPlanner { get; set; }
    public string PM { get; set; }
    public string ProgM { get; set; }
    public string DPTEPDM { get; set; }
    public string DIVMDED { get; set; }
    public string Initiator { get; set; }
    public string CurrentStatus { get; set; }


}