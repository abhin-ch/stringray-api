using Newtonsoft.Json;
using System.Diagnostics.CodeAnalysis;
namespace StingrayNET.ApplicationCore.Models.File;
public class FileDownloadRequest
{
    [JsonRequired, NotNull]
    public string UUID { get; set; }

}
