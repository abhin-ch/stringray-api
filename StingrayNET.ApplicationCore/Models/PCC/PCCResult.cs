using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.PCC;

public class PCCResult : BaseOperation
{
    public EmailResult? Email { get; set; }
    //public IEnumerable<PCCMain>? PCCMain { get; set; }



    public class EmailResult
    {
        public List<string>? To { get; set; }
        public List<string>? CC { get; set; }
        public List<string>? BCC { get; set; }
        public string? EmailBody { get; set; }

        public string? EmailSubject { get; set; }
    }
    public double? PipelineDuration { get; set; }
    public string? FileUploadID { get; set; }
    public bool? HasP6Error { get; set; }
}
