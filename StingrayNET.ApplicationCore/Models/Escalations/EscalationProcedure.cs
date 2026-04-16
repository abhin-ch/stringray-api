using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Escalations;
public class EscalationProcedure : BaseProcedure
{
    public string? ProjectID { get; set; } = null;
    public bool? Scheduled { get; set; } = null;
    public string? CommentBody { get; set; } = null;

    public string? Title { get; set; } = null;

    public string? Type { get; set; } = null;

    public string? ActivityID { get; set; } = null;
    public string? EscalationID { get; set; } = null;
    public bool? Archive { get; set; } = null;


    public string? UpdateCol { get; set; } = null;

    public string? UpdateVal { get; set; } = null;

    public string? PK_ID { get; set; } = null;


}