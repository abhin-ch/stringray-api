using System;

namespace StingrayNET.ApplicationCore.Models.PCC.SDQ;

public class SDQChecklistResponse
{
    public string ChecklistItemID { get; set; }
    public string Answer { get; set; }
    public string Comment { get; set; }
    public bool IsValid => (Answer == "N/A" && string.IsNullOrEmpty(Comment)) || (Answer == "No" && string.IsNullOrEmpty(Comment)) ? false : true;
}