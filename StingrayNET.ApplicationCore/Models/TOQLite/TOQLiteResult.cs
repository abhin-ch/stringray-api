using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.TOQLite;

public class TOQLiteResult : BaseOperation
{
    public EmailResult? Email { get; set; }

    public class EmailResult
    {
        public List<string>? To { get; set; }
        public List<string>? CC { get; set; }
        public string? Subject { get; set; }
        public string? EmailBody { get; set; }
    }

}






