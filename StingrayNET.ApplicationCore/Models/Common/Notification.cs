using System;
using StingrayNET.ApplicationCore.CustomExceptions;

namespace StingrayNET.ApplicationCore.Models.Common;

public enum NotificationActionTypeEnum
{
    Prepare = 1,
    Verify = 2,
    Approve = 3,
    Review = 4
}

public enum NotificationIDTypeEnum
{
    UUID = 1,
    Integer = 2,
    Filter = 3
}

public class Notification
{
    public string NotificationActionType { get; private set; }
    public string Module { get; private set; }
    public string NotificationIDType { get; private set; }
    public string? ModuleView { get; private set; }

    public string RecordIDFieldName { get; private set; }
    public string RecordIDVal { get; private set; }

    public string? EmployeeID { get; private set; }

    public int? ASID { get; private set; }

    public string? NotificationID { get; private set; }

    public Notification(string notificationActionType, string module, string notificationIDType, string recordIDFieldName, string recordIDVal, string? moduleView = null, string? employeeID = null, int? asid = null, string? notificationID = null)
    {

        if (!Enum.IsDefined(typeof(NotificationActionTypeEnum), notificationActionType))
        {
            throw new ValidationException(string.Format(@"notificationActionType {0} is not valid", notificationActionType));
        }

        NotificationActionType = notificationActionType;

        if (!Enum.IsDefined(typeof(NotificationIDTypeEnum), notificationIDType))
        {
            throw new ValidationException(string.Format(@"notificationIDType {0} is not valid", notificationIDType));
        }

        NotificationIDType = notificationIDType;

        if (!Enum.IsDefined(typeof(ModuleEnum), module))
        {
            throw new ValidationException(string.Format(@"module {0} does not exist", module));
        }

        Module = module;

        RecordIDFieldName = recordIDFieldName;
        RecordIDVal = recordIDVal;

        ModuleView = moduleView;

        if (string.IsNullOrEmpty(employeeID) && asid == null)
        {
            throw new ValidationException(@"Either a EmployeeID or ASID parameter must be provided");
        }

        EmployeeID = employeeID;
        ASID = asid;
        NotificationID = notificationID;
    }
}
