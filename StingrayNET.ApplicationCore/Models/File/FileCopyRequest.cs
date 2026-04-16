namespace StingrayNET.ApplicationCore.Models.File;
public class FileCopyRequest
{
    public Department Department { get; set; }
    public string DelimitedFileMetaIDs { get; set; }
    public string DelimitedParentIDs { get; set; }
}
