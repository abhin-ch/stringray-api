using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.ALR;
public class ALRResult : BaseOperation
{
    public List<object> MainTableData { get; set; }
    public List<object> UserAssignment { get; set; }
    public List<object> Comments { get; set; }
    public List<object> WorkOrders { get; set; }
    public List<object> RelatedItems { get; set; }
    public List<object> Activities { get; set; }
    public List<object> TabRowCounts { get; set; }
    public List<object> PossibleAssignments { get; set; }

}
