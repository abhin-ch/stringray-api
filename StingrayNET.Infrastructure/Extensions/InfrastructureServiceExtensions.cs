using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.Infrastructure.Services;
using StingrayNET.Infrastructure.Services.Azure;

namespace StingrayNET.Infrastructure.Extensions
{
    public static class InfrastructureServiceExtensions
    {
        public static IServiceCollection AddAzureServices(this IServiceCollection services)
        {
            services.AddScoped<IKVService, KVService>();
            services.AddTransient<IWSService, WSService>();
            services.AddSingleton<ICacheProvider, CacheProvider>();
            services.AddScoped<IIdentityService, IdentityService>();
            services.AddTransient<IBLOBService, BLOBService>();
            services.AddTransient<IBLOBServiceNew, BLOBServiceNew>();
            services.AddTransient<IEmailService, EmailService>();
            services.AddSingleton<ISingletonEmailSender, SingletonEmailSender>();
            services.AddTransient<IADFService, ADFService>();
            services.AddTransient<IDevopsService, DevopsService>();

            return services;
        }

        public static IServiceCollection AddDatabaseServers(this IServiceCollection services, IConfiguration configuration)
        {
            // For the SC database
            services.AddScoped<IDatabase<SC>>(sp =>
            {
                var connectionString = configuration.GetConnectionString("SC_CONNECTION");
                return new MSSQL<SC>(connectionString);
            });

            // For the DED database
            services.AddScoped<IDatabase<DED>>(sp =>
            {
                var connectionString = configuration.GetConnectionString("DED_CONNECTION");
                return new MSSQL<DED>(connectionString);
            });

            return services;
        }
    }
}