using System;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.StandardComp;

public class StandardCompProcedure : BaseProcedure
{
    public int? PrimaryValue { get; set; } = null;
    public string? TextField1 { get; set; } = null;
    public string? TextField2 { get; set; } = null;
    public string? LargeTextField1 { get; set; } = null;

    public string? LargeTextField2 { get; set; } = null;

    public bool? CheckboxField1 { get; set; } = null;

    public bool? CheckboxField2 { get; set; } = null;

    public string? DropdownField1 { get; set; } = null;

    public string? DropdownField2 { get; set; } = null;

    public DateTime? DateField1 { get; set; } = null;

    public DateTime? DateField2 { get; set; } = null;
    public string? StatusField1 { get; set; } = null;
}