using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StingrayNET.Application.Modules.PCC;
using StingrayNET.Application.Modules.PCC.Workflow;
using StingrayNET.Application.Modules.TOQ.Workflow;
using StingrayNET.Application.Services;

namespace StingrayNET.Application.Extensions;

public static class ModuleApplicationExtensions
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddScoped<IPCCService, PCCService>();
        services.AddScoped<ITOQService, TOQService>();
        services.AddScoped<ITOQStatusProvider, TOQStatusProvider>();
        services.AddScoped<IPCCStatusProvider, PCCStatusProvider>();
        services.AddScoped<ITOQHelperFunctions, TOQHelperFunctions>();
        services.AddSingleton<ITOQSingletonService, TOQSingletonService>();
        services.AddScoped<IAdminHelperFunctions, AdminHelperFunctions>();
        services.AddSingleton<IAdminSingletonService, AdminSingletonService>();
        services.AddScoped<IPCCHelperFunctions, PCCHelperFunctions>();
        services.AddSingleton<IPCCSingletonService, PCCSingletonService>();
        services.AddScoped<IMetricEmails, MetricEmails>();

        services.AddScoped<IDevOpsService, DevOpsService>();
        services.AddHostedService<STNGBackgroundWorker>();
        services.AddSingleton<IBackgroundTaskQueue, BackgroundTaskQueue>();
        services.AddSingleton<IBaseEmailService, BaseEmailService>();

        return services;
    }
}