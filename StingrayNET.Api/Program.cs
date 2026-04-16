using Microsoft.Identity.Web;
using Serilog;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.Infrastructure.Repository;
using StingrayNET.Infrastructure.Services;
using StingrayNET.Api;
using StingrayNET.Infrastructure.Services.Azure;
using Microsoft.Extensions.Azure;
using Azure.Identity;
using Microsoft.Identity.Web.TokenCacheProviders.Distributed;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using StingrayNET.ApplicationCore.CustomExceptions;
using Microsoft.AspNetCore.Authorization;
using StingrayNET.Application.Extensions;
using StingrayNET.Infrastructure.Extensions;
using Microsoft.Data.SqlClient;
using Microsoft.AspNetCore.ResponseCompression;
using System.IO.Compression;
using StingrayNET.ApplicationCore.Specifications;
using Microsoft.AspNetCore.ResponseCompression;
using System.IO.Compression;

var builder = WebApplication.CreateBuilder(args);

//Configure HTTP protocol
builder.WebHost.ConfigureKestrel((c, o) =>
{
    o.ConfigureEndpointDefaults(p => p.Protocols = HttpProtocols.Http1AndHttp2);
});

// Add services to the container.
builder.Services.AddHttpContextAccessor();
builder.Services.AddAzureServices();
builder.Services.AddModuleRepository();
builder.Services.AddApplicationServices();
builder.Services.AddTransient<IExpressionSerializer, ExpressionSerializer>();
builder.Services.AddTransient<IExcelService, ExcelService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IExpressionRepository, ExpressionRepository>();
builder.Services.AddTransient<IUserEmailService, UserEmailService>();

// Database Service Registration
builder.Services.AddDatabaseServers(builder.Configuration);

builder.Services.AddMicrosoftIdentityWebApiAuthentication(builder.Configuration)
    .EnableTokenAcquisitionToCallDownstreamApi(options => builder.Configuration.GetSection("AzureAd"))
    .AddMicrosoftGraph(builder.Configuration.GetSection("GraphApi"))
    .AddDistributedTokenCaches();

// Distributed token caches have a L1/L2 mechanism.
// L1 is in memory, and L2 is the distributed cache
// implementation that you will choose below.
// You can configure them to limit the memory of the 
// L1 cache, encrypt, and set eviction policies.
builder.Services.Configure<MsalDistributedTokenCacheAdapterOptions>(options =>
{
    // Optional: Disable the L1 cache in apps that don't use session affinity by setting DisableL1Cache to 'true'.
    options.DisableL1Cache = false;

    // Or limit the memory (by default, this is 500 MB)
    //options.L1CacheOptions.SizeLimit = 1024 * 1024 * 1024; // 1 GB

    // You can choose if you encrypt or not encrypt the cache
    options.Encrypt = false;

    // And you can set eviction policies for the distributed cache.
    options.SlidingExpiration = TimeSpan.FromHours(1);
});

// good for prototyping and testing, but this is NOT persisted and it is NOT distributed - do not use in production
//builder.Services.AddDistributedMemoryCache();
builder.Services.AddDistributedSqlServerCache(options =>
{
    options.ConnectionString = builder.Configuration.GetConnectionString("SC_CONNECTION");
    options.SchemaName = "stng";
    options.TableName = "TokenCache";

    // You don't want the SQL token cache to be purged before the access token has expired. Usually
    // access tokens expire after 1 hour (but this can be changed by token lifetime policies), whereas
    // the default sliding expiration for the distributed SQL database is 20 mins. 
    // Use a value which is above 60 mins (or the lifetime of a token in case of longer lived tokens)
    options.DefaultSlidingExpiration = TimeSpan.FromMinutes(90);
});

builder.Services.AddMemoryCache();
// The following flag can be used to get more descriptive errors. This is set to true in development environment
Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true;

// Enables controllers and pages to get GraphServiceClient by dependency injection
// And use an in memory token cache
builder.Services.AddAzureClients(clientBuilder =>
{
    // Add a KeyVault client
    clientBuilder.AddSecretClient(builder.Configuration.GetSection("KeyVault"));

    // Add a storage account client
    clientBuilder.AddBlobServiceClient(builder.Configuration.GetSection("Storage"));

    // Use DefaultAzureCredential by default
    clientBuilder.UseCredential(new DefaultAzureCredential());
});


builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
    options.JsonSerializerOptions.PropertyNamingPolicy = null;

});

// Enable Brotli + Gzip compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<BrotliCompressionProvider>();
    options.Providers.Add<GzipCompressionProvider>();
});

builder.Services.Configure<BrotliCompressionProviderOptions>(options =>
{
    options.Level = CompressionLevel.Optimal; // Brotli optimal as default
});

builder.Services.Configure<GzipCompressionProviderOptions>(options =>
{
    options.Level = CompressionLevel.Fastest; // Gzip fastest as fallback
});

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.CustomSchemaIds(schema => schema?.FullName?.Replace('+', '.'));
});

builder.Host.UseSerilog((hostingContext, loggerConfiguration) =>
{
    loggerConfiguration.ReadFrom.Configuration(hostingContext.Configuration).Enrich.FromLogContext();
});

const string policyname = "stingrayCORS";
builder.Services.AddCors(options =>
{
    options.AddPolicy(policyname,
        policy =>
        {
            policy.WithOrigins(builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>())
                .AllowAnyHeader()
                .AllowAnyMethod()
                .WithExposedHeaders("*");
        });
});
builder.WebHost.UseUrls("http://*:80");


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true;
}

// Configure CORS to enable this
app.UseHttpsRedirection();
app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
});

app.UseMiddleware<ExceptionMiddleware>();
app.UseWebSockets();

// Enable compression middleware
app.UseResponseCompression();

app.UseRouting();
app.UseCors(policyname);
app.UseAuthentication();

//403 and 404 check
app.Use((context, next) =>
{
    var metadata = context.GetEndpoint()?.Metadata;
    if (!context.User.Identity.IsAuthenticated && (metadata?.GetMetadata<AllowAnonymousAttribute>() == null || !context.WebSockets.IsWebSocketRequest))
    {
        throw new ForbiddenException();
    }

    if (context.GetEndpoint() == null)
    {
        throw new NotFoundException();
    }

    return next(context);

});

app.UseAuthorization();

app.UseStingrayAuth();

app.MapControllers();

app.Run();