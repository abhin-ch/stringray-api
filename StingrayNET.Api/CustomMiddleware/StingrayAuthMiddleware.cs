using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.CustomExceptions;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Serilog.Context;
using System.Diagnostics;

namespace StingrayNET.Api
{
    /// <summary>
    /// Authorization middleware that validates user permissions for API endpoints.
    /// Performs endpoint permission checks and RSS validation.
    /// Results are cached for 15 minutes to improve performance.
    /// </summary>
    public class StingrayAuthMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ICacheProvider _cache;
        private readonly ILogger<StingrayAuthMiddleware> _logger;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private static SemaphoreSlim _semaphore = new SemaphoreSlim(1);

        // Constants for better performance and maintainability
        private static readonly Regex ApiPrefixRegex = new(@"^/api/", RegexOptions.Compiled | RegexOptions.IgnoreCase);

        public StingrayAuthMiddleware(IHttpContextAccessor httpContextAccessor, RequestDelegate next, ICacheProvider cache, ILogger<StingrayAuthMiddleware> logger)
        {
            _next = next;
            _cache = cache;
            _logger = logger;
            _httpContextAccessor = httpContextAccessor;
        }

        /// <summary>
        /// Removes "/api/" prefix from path to match database format.
        /// Example: "/api/users/list" → "users/list"
        /// </summary>
        private static string NormalizePath(string path)
        {
            if (!path.StartsWith("/api/", StringComparison.OrdinalIgnoreCase))
                return path;
            return path.Length > 5 ? path.Substring(5) : string.Empty;
        }

        /// <summary>
        /// Gets all endpoint permissions for a user and caches them.
        /// Calls Op_48 stored procedure. Results cached by empID.
        /// </summary>
        private async Task<(HashSet<string> Permissions, bool FromCache)> GetUserEndpointPermissions(string empID, IRepositoryXL<AdminProcedure, AdminResult> repository)
        {
            Stopwatch sw = new Stopwatch();
            sw.Start();

            string cacheKey = $"endpoint_perms:{empID}";
            bool semaphoreFlag = false;

            // if the user doesn't have cached data yet, await so multiple tasks don't rush in before the cache is set
            if (!_cache.Exists(cacheKey))
            {
                semaphoreFlag = true;
                await _semaphore.WaitAsync();
            }



            try
            {
                // Try to get cached permissions if they exist
                if (_cache.TryGet(cacheKey, out HashSet<string> permissions))
                {
                    return (permissions, true); // from cache
                }


                AdminResult result = await repository.Op_48(new AdminProcedure
                {
                    EmployeeID = empID
                });

                var permissionSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                // loop through items here
                foreach (var item in result.Data1.Cast<Dictionary<string, object>>())
                {
                    // get path and verb from each line of data
                    string endpoint = item["Endpoint"]?.ToString()?.ToLowerInvariant();
                    string verb = item["HTTPVerb"]?.ToString()?.ToUpperInvariant();

                    if (!string.IsNullOrEmpty(endpoint) && !string.IsNullOrEmpty(verb))
                    {
                        permissionSet.Add($"{endpoint}:{verb}");
                    }
                }

                _cache.Set(cacheKey, permissionSet);
                return (permissionSet, false); // fresh from DB
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to fetch endpoint permissions for employee {EmployeeID}", empID);
                return (new HashSet<string>(), false);
            }
            finally
            {
                // only tasks that awaited semaphore should release it
                if (semaphoreFlag)
                {
                    _semaphore.Release();
                }
                sw.Stop();
                Console.WriteLine("Permissions for " + this?._httpContextAccessor?.HttpContext?.Request?.Path.Value + ", user: " + empID + " received in " + sw.ElapsedMilliseconds.ToString() + " ms");
            }
        }

        /// <summary>
        /// Checks if user has permission to access specific endpoint/verb combination.
        /// Calls Op_48 stored procedure. Results cached by empID.
        /// </summary>
        private async Task<(bool HasPermission, bool FromCache)> EndpointPermissionCheck(string path, string verb, string empID, IRepositoryXL<AdminProcedure, AdminResult> repository)
        {
            var (permissions, fromCache) = await GetUserEndpointPermissions(empID, repository);
            string permissionKey = $"{path.ToLowerInvariant()}:{verb.ToUpperInvariant()}";
            return (permissions.Contains(permissionKey), fromCache);
        }

        // NOT BEING USED RIGHT NOW
        /// <summary>
        /// Checks if user has named permission (e.g., "Impersonate").
        /// Calls Op_31 stored procedure. Results cached by empID:permission.
        /// </summary>
        private async Task<HashSet<string>> GetUserNamedPermissions(string empIdInsert, string empID, IRepositoryXL<AdminProcedure, AdminResult> repository)
        {
            string cacheKey = $"user_perms:{empID}";

            // Try to get cached permissions if they exist
            if (_cache.TryGet(cacheKey, out HashSet<string> permissions))
                return permissions;

            try
            {
                AdminResult result = await repository.Op_31(new AdminProcedure
                {
                    EmployeeID = "SYSTEM",
                    EmployeeIDInsert = empIdInsert
                });

                var permissionSet = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                // loop through items here
                foreach (var item in result.Data1.Cast<Dictionary<string, object>>())
                {
                    // get permission from each line of data
                    string permission = item["Permission"]?.ToString();
                    if (!string.IsNullOrEmpty(permission))
                    {
                        permissionSet.Add(permission);
                    }
                }

                _cache.Set(cacheKey, permissionSet);
                return permissionSet;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to fetch named permissions for employee {EmployeeID}", empID);
                return new HashSet<string>();
            }
        }



        /// <summary>
        /// This is the main entry point for the middleware, executed once per HTTP request
        /// Scoped services (repositories, etc.) are injected here as method parameters
        /// </summary>
        public async Task InvokeAsync(
            HttpContext context,
            IRepositoryXL<AdminProcedure, AdminResult> repository,
            IIdentityService identityService,
            IExpressionRepository expressionRepo)
        {
            try
            {
                // For WebSocket requests, authorization is handled differently, so we skip this middleware
                if (context.GetEndpoint()?.Metadata?.GetMetadata<AllowAnonymousAttribute>() != null &&
                    context.WebSockets.IsWebSocketRequest)
                {
                    await _next(context);
                    return;
                }

                // Get HTTPContext variables
                string path = context.Request.Path.Value?.ToLowerInvariant() ?? string.Empty;
                string verb = context.Request.Method;
                string normalizedPath = NormalizePath(path);

                //Important Call to ensure important httpContext Items are set
                await identityService.GetUser(context);

                // First, establish the user's identity
                string empID = await identityService.GetEmployeeID(context);
                string originalEmpID = await identityService.GetOriginalEmployeeID(context); // Store original for impersonation checks

                // Next, handle impersonation if requested
                string isImpersonated = "False";
                if (context.Request.Headers.TryGetValue("STNG-IMPERSONATE-AS", out var impersonateHeader))
                {
                    // Before allowing impersonation, verify the ORIGINAL user has the 'Impersonate' permission
                    if (await identityService.ImpersonateCheck(context, repository))
                    {
                        // If authorized, update the context with the impersonated user's ID
                        // and re-fetch the employee ID, which will now be the impersonated user
                        context.Items["ImpersonateUserID"] = impersonateHeader.ToString();
                        empID = await identityService.GetEmployeeID(context, forceQuery: true);
                        isImpersonated = originalEmpID;
                    }
                    else
                    {
                        throw new UnauthorizedException("Impersonation not permitted");
                    }
                }

                // --- Main Permission Checks ---
                // The request will only proceed if it passes all relevant checks
                var (hasEndpointPermission, fromCache) = await EndpointPermissionCheck(normalizedPath, verb, empID, repository);

                // Enrich Serilog log context
                using (LogContext.PushProperty("Impersonated", isImpersonated))
                {
                    // Endpoint Permission Check
                    if (!hasEndpointPermission)
                        throw new UnauthorizedException($"URL {path} not authorized");

                    // If all checks pass, allow the request to proceed to the next middleware or the controller
                    await _next(context);
                }
            }
            catch (UnauthorizedException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error in StingrayAuthMiddleware for path {Path}", context.Request.Path);
                throw;
            }
        }
    }

    /// <summary>
    /// A simple extension method to make registering the middleware in Program.cs cleaner
    /// Allows for `app.UseStingrayAuth()` instead of `app.UseMiddleware<StingrayAuthMiddleware>()`
    /// </summary>
    public static class StingrayAuthMiddlewareExtensions
    {
        public static IApplicationBuilder UseStingrayAuth(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<StingrayAuthMiddleware>();
        }
    }
}
