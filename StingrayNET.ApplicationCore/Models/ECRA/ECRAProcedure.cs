using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using System.Collections.Generic;
namespace StingrayNET.ApplicationCore.Models.ECRA;
public class ECRAProcedure : BaseProcedure
{
    public class Option
    {
        public string? id { get; set; }
    }
    public List<Option>? MultiSelectList { get; set; } = null;

    public string? UniqueID { get; set; } = null;
    public string? EC { get; set; } = null;
    public string? AdminOptionText { get; set; } = null;
    public string? SearchText { get; set; } = null;
    public string? Details { get; set; } = null;
    public string? Discipline { get; set; } = null;
    public int? PerceptionImpact { get; set; } = null;
    public int? PerceptionProbability { get; set; } = null;
    public bool? FastTrack { get; set; } = null;
    public bool? FirstInAWhile { get; set; } = null;
    public bool? FirstTime { get; set; } = null;
    public int? Knowledge { get; set; } = null;
    public int? Skill { get; set; } = null;
    public int? Familiarity { get; set; } = null;
    public int? Understanding { get; set; } = null;
    public int? Currency { get; set; } = null;
    public string? PerceptionComment { get; set; } = null;
    public string? ProficiencyComment { get; set; } = null;
    public bool? Digital { get; set; } = null;
    public long? UniqueIDNum { get; set; }

    public string? OverrideCritCat { get; set; } = null;
    public bool? CritCatCheckOverride { get; set; } = null;
    public string? OverrideSPV { get; set; } = null;
    public bool? SPVCheckOverride { get; set; } = null;
    public string? OverrideSeismic { get; set; } = null;
    public bool? SeismicCheckOverride { get; set; } = null;
    public string? OverrideEQImpact { get; set; } = null;
    public bool? EQImpactCheckOverride { get; set; } = null;
    public string? OverrideSafetyRelated { get; set; } = null;
    public bool? SafetyRelatedCheckOverride { get; set; } = null;
    public string? OverrideNuclearSafety { get; set; } = null;
    public bool? NuclearSafetyCheckOverride { get; set; } = null;
    public string? OverrideEmployeeSafety { get; set; } = null;
    public bool? EmployeeSafetyCheckOverride { get; set; } = null;
    public string? OverrideEconomics { get; set; } = null;
    public bool? EconomicsCheckOverride { get; set; } = null;
    public string? OverrideEnvironmental { get; set; } = null;
    public bool? EnvironmentalCheckOverride { get; set; } = null;
    public string? OverrideServiceConditions { get; set; } = null;
    public bool? ServiceConditionsCheckOverride { get; set; } = null;
    public string? OverridePastPerformance { get; set; } = null;
    public bool? PastPerformanceCheckOverride { get; set; } = null;
    public string? OverrideOMUpdates { get; set; } = null;
    public bool? OMUpdatesCheckOverride { get; set; } = null;
    public string? OverrideSSTUpdates { get; set; } = null;
    public bool? SSTUpdatesCheckOverride { get; set; } = null;
    public string? OverrideAIMUpdates { get; set; } = null;
    public bool? AIMUpdatesCheckOverride { get; set; } = null;

}
