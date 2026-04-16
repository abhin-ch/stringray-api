using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.CMDS;

public class CMDSProcedure : BaseProcedure
{

    public class Cat
    {
        public string? id { get; set; }
        public string? name { get; set; }
        public bool value { get; set; }
    }

    public string? CurrentUser { get; set; } = null;
    public string? Title { get; set; } = null;
    public string? UniqueID { get; set; } = null;
    public int? CommentID { get; set; } = null;
    public string? Comment { get; set; } = null;
    public string? Section { get; set; } = null;
    public string? WorkProgram { get; set; } = null;
    public string? GoalLevel { get; set; } = null;
    public string? Description { get; set; } = null;
    public string? Owner { get; set; } = null;
    public string? Status { get; set; } = null;
    public string? Year { get; set; } = null;
    public string? Quarter { get; set; } = null;
    public DateTime? TCD { get; set; } = null;
    public string? CompletionNotes { get; set; } = null;
    public string? AssignedTo { get; set; } = null;
    public string? Action { get; set; } = null;
    public string? ActionStatus { get; set; } = null;
    public int? ActionID { get; set; } = null;
    public string? Value { get; set; } = null;
    public string? DateType { get; set; } = null;
    public string? Category { get; set; } = null;
    public List<Cat>? Categories { get; set; } = null;

}
