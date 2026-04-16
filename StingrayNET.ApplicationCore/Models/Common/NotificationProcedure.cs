using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;

namespace StingrayNET.ApplicationCore.Models.Common;

public class NotificationProcedure : BaseProcedure
{
    public Notification? Notification { get; set; }
    public string? NotificationID { get; set; }
    public bool? AddressAll { get; set; }
}

