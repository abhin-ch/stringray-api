using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.ApplicationCore.Models.CARLA;
public class CARLAResult : BaseOperation
{

    public EmailResult? Email { get; set; }
    public List<object>? Data4 { get; set; }



    public class EmailResult
    {
        public List<string>? To { get; set; }
        public List<string>? CC { get; set; }
        public string? EmailBody { get; set; }
    }

}