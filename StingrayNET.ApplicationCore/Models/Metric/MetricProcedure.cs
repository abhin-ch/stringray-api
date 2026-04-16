using System.Data;
using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Metric;

public class MetricProcedure : BaseProcedure
{

    public class Option
    {
        public string? id { get; set; }
    }
    public List<Option>? MultiSelectList { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public string? UniqueID { get; set; } = null;

    public int? MetricIntID { get; set; } = null;
    public string? MeasureCategory { get; set; } = null;
    public string? MeasureName { get; set; } = null;
    public string? Department { get; set; } = null;
    public string? Section { get; set; } = null;
    public string? Unit { get; set; } = null;
    public string? MetricOwner { get; set; } = null;
    public string? DataOwner { get; set; } = null;
    public string? MonthlyTarget { get; set; } = null;
    public string? YTDTarget { get; set; } = null;
    public string? MonthlyVariance { get; set; } = null;
    public string? YearlyVariance { get; set; } = null;
    public string? TargetForMonth { get; set; } = null;
    public string? ActualForMonth { get; set; } = null;
    public string? Variance { get; set; } = null;
    public string? Frequency { get; set; } = null;
    public string? MeasureType { get; set; } = null;
    public string? KPICategorization { get; set; } = null;
    public string? ActionStatus { get; set; } = null;
    public string? Period { get; set; } = null;
    public string? Action { get; set; } = null;
    public string? Responsibility { get; set; } = null;
    public DateTime? DueDate { get; set; } = null;
    public string? ReportingYear { get; set; } = null;
    public string? StatusID { get; set; } = null;
    public string? StatusC { get; set; } = null;
    public string? MetricID { get; set; } = null;
    public string? RedCriteriaC { get; set; } = null;
    public string? WhiteCriteriaC { get; set; } = null;
    public string? GreenCriteriaC { get; set; } = null;
    public string? YellowCriteriaC { get; set; } = null;
    public string? Defnition { get; set; } = null;
    public string? Driver { get; set; } = null;
    public string? DataSource { get; set; } = null;
    public DateTime? RedRecoveryDate { get; set; } = null;
    public string? OwnershipType { get; set; } = null;
    public string? ActionsReviewID { get; set; } = null;
    public string? Objective { get; set; } = null;
    public string? Definition { get; set; } = null;
    public string? Operators { get; set; } = null;

    public string? Criteria { get; set; } = null;
    public bool? Scoped { get; set; } = null;
    public double? Value1 { get; set; } = null;
    public string? Operator1 { get; set; } = null;
    public double? Value2 { get; set; } = null;
    public bool? AND { get; set; } = null;
    public double? Value3 { get; set; } = null;
    public string? Operator2 { get; set; } = null;
    public double? Value4 { get; set; } = null;

    public int? Year { get; set; } = null;
    public int? Month { get; set; } = null;
    public string? MonthYear { get; set; } = null;
    public string? AdminOptionText { get; set; } = null;
    public double? TargetVal { get; set; } = null;
    public string? StatusShort { get; set; } = null;
    public string? ParentMeasure { get; set; } = null;
    public string? ActiveStatus { get; set; } = null;
    public bool? MyView { get; set; } = null;

}
