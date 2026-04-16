using System;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Models.ETDB;

namespace StingrayNET.ApplicationCore.Models.CARLA;
public class CARLAProcedure : BaseProcedure
{
    public ScheduleTable<SubFragnetList>? SubFragnetList { get; set; }
    public ScheduleTable<ScheduleUpdate>? ScheduleUpdate { get; set; }
    public string? ActivityID { get; set; }
    public string? SubActivity { get; set; }
    public string? MainActivity { get; set; }
    public string? status { get; set; }
    public string? UniqueID { get; set; }
    public string? EmailName { get; set; }
    public DateTime? LUD { get; set; }
    public string? LUB { get; set; }
    public string? CurrentUser { get; set; }
    public string? FieldName { get; set; }
    public bool? Actualized { get; set; }
    public bool? NR { get; set; }
    public bool? ClearIcon { get; set; }
    public bool? OriginalData { get; set; }
    public bool? Icon { get; set; }
    public string? Priority { get; set; }
    public DateTime? CompletionDate { get; set; }
    public string? Search { get; set; }
    public string? SearchKind { get; set; }
    public string? ProjectID { get; set; }
    public string? Comment { get; set; }
    public string? CommentID { get; set; }
    public string? Filter { get; set; }
    public List<ScopeDetails>? ScopeDetails { get; set; }
    public List<PendingChanges>? PendingChanges { get; set; }
}
public class PendingChanges
{
    public string? ID { get; set; }
    public string? type { get; set; }
    public string? Names { get; set; }
    public string? PreviousName { get; set; }
}
