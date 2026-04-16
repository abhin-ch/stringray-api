using System;
namespace StingrayNET.ApplicationCore.Models.MPL;

public class MPL
{
    public string ProjectID { get; set; }
    public string ProjectName { get; set; }
    public string Status { get; set; }
    public string Portfolio { get; set; }
    public string PCS { get; set; }
    public string OE { get; set; }
    public string ProjectManager { get; set; }
    public string ProjectPlanner { get; set; }
    public string ProgramManager { get; set; }
    public string MaterialBuyer { get; set; }
    public string ContractAdmin { get; set; }
    public string ServiceBuyer { get; set; }
    public string BuyerAnalyst { get; set; }
    public string CSFLM { get; set; }
    public string ContractSpecialist { get; set; }
    public string FastTrack { get; set; }
    public string CostAnalyst { get; set; }
    public string Funding { get; set; }
    public DateTime LastUpdated { get; set; }
    public string? Department { get; set; } = null;

}
