using StingrayNET.ApplicationCore.Abstractions;
using System.Collections.Generic;
namespace StingrayNET.ApplicationCore.Models.Admin;

public class AdminResult : BaseOperation
{
    public EmailResult? Email { get; set; }
    public bool? canImpersonate { get; set; }
    public List<object>? permissions { get; set; }
    public List<object>? roles { get; set; }

    public List<object>? endpoints { get; set; }
    public List<object>? attributes { get; set; }
    public List<object>? delegates { get; set; }
    public class EmailResult
    {
        public List<string>? To { get; set; }
        public List<string>? CC { get; set; }
        public List<string>? BCC { get; set; }
        public string? EmailBody { get; set; }
        public string? EmailSubject { get; set; }
    }
}