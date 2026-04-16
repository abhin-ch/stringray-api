using System.Text.Json.Serialization;

namespace StingrayNET.ApplicationCore.Models.File;

public class FileStartRequest
{
    //[JsonRequired]
    //public string FileName { get; set; }\
    [JsonRequired]
    public string Module { get; set; }

}
