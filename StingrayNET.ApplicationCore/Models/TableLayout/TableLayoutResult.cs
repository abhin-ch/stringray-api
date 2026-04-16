
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.TableLayout;

public class TableLayoutResult : BaseOperation
{
    public List<object>? LayoutList { get; }
    public List<object>? Layout { get; set; }
    public List<object>? LayoutShare { get; set; }
    public List<object>? ShareList { get; set; }

}
