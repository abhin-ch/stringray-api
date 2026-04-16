namespace StingrayNET.ApplicationCore.Models.File;

public class FileChunkRequest
{
    public int IncrementalID { get; set; }
    public string UUID { get; set; }
    public string Module { get; set; }
    //public Stream File { get; set; }

}
