using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Interfaces;
using s = Serilog;
using System.Diagnostics;
using System.Net.Sockets;
using System.Net;
using System.Text.RegularExpressions;

namespace StingrayNET.Api
{
    public class ExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly s.ILogger _logger;
        public ExceptionMiddleware(RequestDelegate next, s.ILogger logger)
        {
            _next = next;
            _logger = logger;
        }

        /// The main entry point for the middleware.
        public async Task InvokeAsync(HttpContext context, IIdentityService identityService)
        {
            Stopwatch sw = new Stopwatch();
            sw.Start();

            try
            {
                context.Response.OnStarting(() =>
                {
                    sw.Stop();
                    if (context.Response.StatusCode == 200)
                    {
                        //Get header and ip info
                        var headerInfo = GetHeaderInfo(context);
                        var ipInfo = GetIPAddress(context);

                        _logger
                            .ForContext(@"EmployeeID", context.Items[@"EmployeeID"]?.ToString())
                            .ForContext(@"SourceContext", @"ResponseLogging")
                            .ForContext(@"RequestMethod", context.Request.Method)
                            .ForContext(@"RequestPath", context.Request.Path.ToString())
                            .ForContext(@"StatusCode", context.Response.StatusCode)
                            .ForContext(@"Elapsed", sw.ElapsedMilliseconds.ToString())
                            .ForContext(@"ClientIP", ipInfo.IP)
                            .ForContext(@"ClientIPLocal", ipInfo.IsLocal)
                            .ForContext(@"Origin", headerInfo.Origin)
                            .ForContext(@"UserAgent", headerInfo.UserAgent)
                        .Information("{Method} {Path} successful", context.Request.Method, context.Request.Path.ToString());
                    }

                    return Task.CompletedTask;
                });

                await _next(context);
            }

            catch (Exception e)
            {
                ErrorResponse errorResponse = await HandleExceptionAsync(context, e);
                sw.Stop();

                //Get header and ip info
                var headerInfo = GetHeaderInfo(context);
                var ipInfo = GetIPAddress(context);

                string? empID = @"NONAUTH";
                if (errorResponse.StatusCode != 403)
                {
                    // Use the identityService that was passed into this method.
                    empID = context.Items.ContainsKey(@"EmployeeID") ? context.Items[@"EmployeeID"].ToString() : await identityService.GetEmployeeID(context);
                }

                _logger
                    .ForContext(@"EmployeeID", empID)
                    .ForContext(@"UUID", errorResponse.ErrorID)
                    .ForContext(@"SourceContext", @"ResponseLogging")
                    .ForContext(@"RequestMethod", context.Request.Method)
                    .ForContext(@"RequestPath", context.Request.Path.ToString())
                    .ForContext(@"StatusCode", context.Response.StatusCode)
                    .ForContext(@"Elapsed", sw.ElapsedMilliseconds.ToString())
                    .ForContext(@"ClientIP", ipInfo.IP)
                    .ForContext(@"ClientIPLocal", ipInfo.IsLocal)
                    .ForContext(@"Origin", headerInfo.Origin)
                    .ForContext(@"UserAgent", headerInfo.UserAgent)
                .Error(e, e.Message);
            }
        }

        private async Task<ErrorResponse> HandleExceptionAsync(HttpContext context, Exception e)
        {

            ErrorResponse errorResponse = new ErrorResponse(e);

            //Set context params
            if (!context.WebSockets.IsWebSocketRequest)
            {
                context.Response.ContentType = @"application/json";
                context.Response.StatusCode = errorResponse.StatusCode;
                await context.Response.WriteAsync(await errorResponse.ToJSON());
            }

            return errorResponse;

        }

        private (bool? IsLocal, string IP) GetIPAddress(HttpContext context)
        {
            string? ip = null;
            //Localhost means local test
            if ((Environment.GetEnvironmentVariable(@"ASPNETCORE_URLS") ?? string.Empty).Contains(@"localhost"))
            {
                ip = @"127.0.0.1";
            }

            else if (context.Request.Headers.ContainsKey(@"X-Client-IP"))
            {
                ip = context.Request.Headers[@"X-Client-IP"].ToString();
            }

            else if (context.Request.Headers.ContainsKey(@"X-Forwarded-For"))
            {
                ip = Regex.Match(context.Request.Headers[@"X-Forwarded-For"].ToString(), @"[0-9\.]+(?=\:|$)").Value;
            }

            if (ip != null)
            {
                string serverIP = Dns.GetHostEntry(Dns.GetHostName()).AddressList.FirstOrDefault(a => a.AddressFamily == AddressFamily.InterNetwork).ToString();

                return (ip == serverIP || ip == @"127.0.0.1", ip);

            }

            else
            {
                return (null, @"Unknown");
            }
        }

        private (string? Origin, string? UserAgent) GetHeaderInfo(HttpContext context)
        {
            var requestHeaders = context.Request.Headers;
            string? origin = requestHeaders.ContainsKey(@"Origin") ? requestHeaders[@"Origin"].ToString() : null;
            string? userAgent = requestHeaders.ContainsKey(@"User-Agent") ? requestHeaders[@"User-Agent"].ToString() : null;
            return (origin, userAgent);
        }

    }

}