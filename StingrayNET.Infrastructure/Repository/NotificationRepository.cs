using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Specifications;
using System.Threading.Tasks;
using System;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository;

public class NotificationRepository : BaseRepository<NotificationResult>, IRepositoryS<NotificationProcedure, NotificationResult>
{
    protected override string Query => "stng.SP_Notification_CRUD";
    private readonly INotificationService _notificationService;

    public NotificationRepository(IDatabase<SC> database, INotificationService notificationService) : base(database)
    {
        _notificationService = notificationService;
    }

    public async Task<NotificationResult> Op_15(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_14(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_13(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_12(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_11(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_10(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_09(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_08(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_07(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_06(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_05(NotificationProcedure model = null) { throw new NotImplementedException(); }
    public async Task<NotificationResult> Op_04(NotificationProcedure model = null) { throw new NotImplementedException(); }


    public async Task<NotificationResult> Op_01(NotificationProcedure model = null)
    {
        NotificationResult result = new NotificationResult();
        result.Notifications = await _notificationService.GetNotifications();

        return result;
    }

    public async Task<NotificationResult> Op_02(NotificationProcedure model = null)
    {
        NotificationResult result = new NotificationResult();
        result.NotificationID = await _notificationService.AddNotification(model.Notification);

        return result;
    }

    public async Task<NotificationResult> Op_03(NotificationProcedure model = null)
    {
        NotificationResult result = new NotificationResult();
        result.UniqueID = await _notificationService.AddressNotification(model.NotificationID, false);

        return result;
    }
}