using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Common;

public class Procedure : BaseProcedure
{
    public class Option
    {
        public string? id { get; set; }
    }
    public List<Option>? MultiSelectList { get; set; } = null;
    public string? UniqueID { get; set; } = null;
    public string? CurrentUser { get; set; } = null;
    public string? Module { get; set; } = null;
}
