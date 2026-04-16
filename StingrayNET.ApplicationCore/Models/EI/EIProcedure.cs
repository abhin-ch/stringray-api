using StingrayNET.ApplicationCore.Abstractions;
using System;
using System.Collections.Generic;
namespace StingrayNET.ApplicationCore.Models.EI;
public class EIProcedure : BaseProcedure
{
    public class Option
    {
        public string? id { get; set; }
    }
    public List<Option>? MultiSelectList { get; set; } = null;

    public string? UniqueID { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public string? Title { get; set; } = null;
    public string? Details { get; set; } = null;
    public string? Section { get; set; } = null;
    public string? QualityRating { get; set; } = null;
    public string? Status { get; set; } = null;
    public string? AdminOptionText { get; set; } = null;
    public string? Outcome { get; set; } = null;
    public string? FocusArea { get; set; } = null;
    public string? CR { get; set; } = null;
    public DateTime? SubmissionDate { get; set; } = null;
    public string? ObservedGroup { get; set; } = null;
    public decimal? QualityScore { get; set; } = null;
    public bool? ErrorDetected { get; set; } = null;

}
