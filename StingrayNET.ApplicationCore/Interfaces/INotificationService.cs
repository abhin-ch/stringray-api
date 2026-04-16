using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models.Common;
using System.Collections.Generic;

namespace StingrayNET.ApplicationCore.Interfaces;
public interface INotificationService
{
    public Task<string> AddNotification(Notification notification);

    public Task<long> AddressNotification(string notificationID, bool addressAll = false);

    public Task<List<Notification>> GetNotifications();

}
