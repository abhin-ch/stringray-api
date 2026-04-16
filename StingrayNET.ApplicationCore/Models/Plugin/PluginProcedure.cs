using StingrayNET.ApplicationCore.Abstractions;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.Plugin;
public class PluginProcedure : BaseProcedure
{
    public string? SessionTemplate { get; set; }
    public string? SessionID { get; set; }

    public List<SessionTaskParameter>? SessionTaskParameters { get; set; }

    public string? InstanceID { get; set; }
    public string? SessionStatus { get; set; }
    public string? SessionTaskID { get; set; }
}