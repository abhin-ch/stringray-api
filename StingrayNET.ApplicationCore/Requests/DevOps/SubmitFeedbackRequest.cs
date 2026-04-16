using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Requests;

public class SubmitFeedbackRequest
{
    public List<SubmitFeedbackSubRequest>? AddWISubrequests { get; set; }
    public string? WIType { get; set; }
    public string? Module { get; set; }

}

public class SubmitFeedbackSubRequest
{
    public string? op { get; set; }
    public string? path { get; set; }
    public string? from { get; set; } = string.Empty;
    public string? value { get; set; }
}