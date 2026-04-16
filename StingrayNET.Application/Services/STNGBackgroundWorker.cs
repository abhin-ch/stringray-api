
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using StingrayNET.ApplicationCore.Interfaces;

public class STNGBackgroundWorker : BackgroundService
{
    private readonly ILogger<STNGBackgroundWorker> _logger;

    public STNGBackgroundWorker(IBackgroundTaskQueue taskQueue, IServiceProvider serviceProvider,
        ILogger<STNGBackgroundWorker> logger)
    {
        TaskQueue = taskQueue;
        _logger = logger;
        Services = serviceProvider;
    }

    public IBackgroundTaskQueue TaskQueue { get; }
    public IServiceProvider Services { get; }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Queued Hosted Service is running.");

        await BackgroundProcessing(stoppingToken);
    }

    private async Task BackgroundProcessing(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {

            var workItem =
                await TaskQueue.DequeueAsync(stoppingToken);

            try
            {
                await workItem(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error occurred executing {WorkItem}.", nameof(workItem));
            }
        }
    }
}