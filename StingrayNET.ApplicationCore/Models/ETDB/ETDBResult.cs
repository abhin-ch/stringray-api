using StingrayNET.ApplicationCore.Abstractions;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.ETDB;
public class ETDBResult : BaseOperation
{
    public EmailResult? Email { get; set; }

    public class EmailResult
    {
        public List<string>? To { get; set; }
        public List<string>? CC { get; set; }
        public string? EmailBody { get; set; }
    }

}
