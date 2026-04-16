using Microsoft.Graph;
using System.Diagnostics.CodeAnalysis;
using System.Text.Json.Serialization;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.File;

public class FileEndRequest
{
    [JsonRequired, NotNull]
    public string FileName { get; set; }
    [JsonRequired, NotNull]
    public string UUID { get; set; }
    [JsonRequired, NotNull]
    public string Module { get; set; }
    [JsonRequired]
    public List<int> IncrementalIDs { get; set; }
    [JsonRequired]
    public Department Department { get; set; }
    public string? ParentID { get; set; }
    public string? GroupBy { get; set; }
}
public enum Department
{
    SC,
    DED
}
