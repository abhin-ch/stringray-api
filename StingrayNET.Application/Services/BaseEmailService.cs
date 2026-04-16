
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Graph;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.Infrastructure.Services.Azure;

public class BaseEmailService : IBaseEmailService
{
    readonly IServiceScopeFactory _serviceScopeFactory;
    readonly IBackgroundTaskQueue _taskQueue;
    readonly ISingletonEmailSender _singletonEmailSender;
    public BaseEmailService(IServiceScopeFactory serviceScopeFactory, IBackgroundTaskQueue taskQueue, ISingletonEmailSender singletonEmailSender)
    {
        _taskQueue = taskQueue;
        _serviceScopeFactory = serviceScopeFactory;
        _singletonEmailSender = singletonEmailSender;
    }

    public async Task SendEmail(Func<CancellationToken, Task<QuickEmailTemplate>> emailFunction, User originalUser, bool impersonating)
    {
        await _taskQueue.QueueBackgroundWorkItemAsync(token => BuildEmail(emailFunction, token, originalUser, impersonating));
    }

    private async Task BuildEmail(Func<CancellationToken, Task<QuickEmailTemplate>> emailFunction, CancellationToken token, User originalUser, bool impersonating)
    {
        QuickEmailTemplate email = await emailFunction(token);

        await _singletonEmailSender.SendWithCheck(originalUser, impersonating, email);
    }

}