using System;


namespace StingrayNET.ApplicationCore.Models.ETDB;

public class TDS
{
    public string? ProjectID { get; set; }
    public string? SheetID { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public DateTime? NeedDate { get; set; }
    public string? Type { get; set; }
    public string? CommitmentID { get; set; }
    public bool? External { get; set; }
    public bool? Emergent { get; set; }
    public string? Group { get; set; }
    public string? Initiator { get; set; }
    public bool? PressureBoundaryReview { get; set; }
    public decimal? Hours { get; set; }



}
