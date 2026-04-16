namespace StingrayNET.ApplicationCore.Requests.PCC;

public class PCCValidateChecklistRequest
{
    public int SDQUID { get; set; } = 0;
    public string ChecklistType { get; set; }
    public string ChecklistID { get; set; }

}