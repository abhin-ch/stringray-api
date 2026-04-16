using StingrayNET.ApplicationCore.Abstractions;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Models.Common;
public class NotificationResult : BaseOperation
{
    public List<Notification>? Notifications { get; set; }
    public string? NotificationID { get; set; }
    public long? UniqueID { get; set; }
}
