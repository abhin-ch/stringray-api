
using System;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.CSA;
public class CSAProcedure : BaseProcedure
{
    public string? CurrentUser { get; set; } = null;
    public string? CSAID { get; set; } = null;
    public string? ITEMNUM { get; set; } = null;
    public string? RSE { get; set; } = null;
    public string? RDE { get; set; } = null;
    public string? RCE { get; set; } = null;
    public string? EQTag { get; set; } = null;
    public string? USI { get; set; } = null;
    public string? StrategyOwner { get; set; } = null;
    public string? Manufacturer { get; set; } = null;
    public string? EPT { get; set; } = null;
    public string? INID { get; set; } = null;
    public string? VERID { get; set; } = null;
    public string? APPID { get; set; } = null;
    public string? CSAStatus { get; set; } = null;
    public int? Revision { get; set; } = null;
    public string? ER { get; set; } = null;
    public string? AR { get; set; } = null;
    public string? AMOT { get; set; } = null;
    public string? EC { get; set; } = null;
    public bool? BOMUpdateRequired { get; set; } = null;
    public int? CSABID { get; set; } = null;
    public int? SS { get; set; } = null;
    public int? ROP { get; set; } = null;
    public int? TMAX { get; set; } = null;
    public string? CriticalFlag { get; set; } = null;
    public string? BOMComment { get; set; } = null;
    public string? Comment { get; set; } = null;
    public int? SAID { get; set; } = null;
    public int? SAItemID { get; set; } = null;
    public string? Type { get; set; } = null;
    public float? RiskProb { get; set; } = null;
    public float? RiskImpact { get; set; } = null;
    public DateTime? RiskEndDate { get; set; } = null;
    public bool? Obsolescence { get; set; } = null;
    public bool? EquipmentReliability { get; set; } = null;
    public bool? EndOfLife { get; set; } = null;
    public bool? Rationale4 { get; set; } = null;
    public bool? Other { get; set; } = null;
    public string? OtherText { get; set; } = null;
    public int? CSAMID { get; set; } = null;
    public string? ScopeStatus { get; set; } = null;
    public string? RepItem { get; set; } = null;
    public string? Justification { get; set; } = null;
    public bool? isAdmin { get; set; } = null;
    public string? Reason { get; set; } = null;
}
