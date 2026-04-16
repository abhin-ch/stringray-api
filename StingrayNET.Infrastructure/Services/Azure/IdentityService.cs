using StingrayNET.ApplicationCore.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;
using System.Linq;
using System.Collections.Generic;
using stngadmin = StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.CustomExceptions;
using StingrayNET.ApplicationCore.Specifications;
using Microsoft.Data.SqlClient;
using System.Data;
using System;
using StingrayNET.ApplicationCore.Models.Admin;
using Microsoft.Extensions.Logging;
using System.Threading;
using System.Diagnostics;

namespace StingrayNET.Infrastructure.Services.Azure;

public class IdentityService : IIdentityService
{
    private readonly IKVService _kvService;
    private readonly IDatabase<SC> _dbService;
    private readonly ICacheProvider _cache;
    private readonly ILogger<IIdentityService> _logger;
    private static SemaphoreSlim _semaphoreUser = new SemaphoreSlim(1);

    public IdentityService(ILogger<IIdentityService> logger, IKVService kvService, IDatabase<SC> dbService, ICacheProvider cache)
    {
        _cache = cache;
        _kvService = kvService;
        _dbService = dbService;
        _logger = logger;
    }

    public async Task<bool> EndImpersonation(HttpContext context)
    {
        context.Items.Remove(@"ImpersonateUserID");
        await GetUser(context, forceQuery: true);
        return true;
    }
    public async Task<bool> ImpersonateCheck(HttpContext context, IRepositoryXL<AdminProcedure, AdminResult> repository)
    {
        string empID = await GetOriginalEmployeeID(context);

        string cacheKey = $"hasImpersonate:{empID}";

        try
        {

            if (_cache.TryGet(cacheKey, out bool cachedResult))
            {
                return cachedResult;
            }

            // If expired, get again:
            AdminResult result = await repository.Op_31(new AdminProcedure
            {
                EmployeeID = "SYSTEM",
                EmployeeIDInsert = empID,
                Permission = "Impersonate"
            });

            // If they have the permission, the value will be set to true
            bool hasPermission = result.Data1.Count > 0;
            _cache.Set(cacheKey, hasPermission);
            return hasPermission;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to check impersonate permission for employee {EmployeeID}", empID);
            return false;
        }
    }

    private string GetCacheKeyUser(string userName)
    {
        return $"user:{userName}";
    }

    private string GetCacheKeyOriginalUser(string userName)
    {
        return $"originalUser:{userName}";
    }

    private string GetUserName(HttpContext context)
    {
        string userName = context.User.Identity.Name;

        if (string.IsNullOrEmpty(userName))
        {
            throw new ForbiddenException();
        }

        return userName;
    }

    public async Task<string> GetEmployeeID(HttpContext context, bool forceQuery = false)
    {
        return (await GetUser(context, forceQuery)).EmployeeID;
    }



    public async Task<string> GetOriginalEmployeeID(HttpContext context)
    {
        return (await GetOriginalUser(context)).EmployeeID;
    }

    public async Task<stngadmin.User> GetOriginalUser(HttpContext context)
    {
        string userName = GetUserName(context);
        string cacheKeyOriginalUser = GetCacheKeyOriginalUser(userName);

        if (!_cache.TryGet(cacheKeyOriginalUser, out stngadmin.User originalUser))
        {
            originalUser = await QueryUserByName(userName);
            _cache.Set(cacheKeyOriginalUser, originalUser);
        }

        return originalUser;
    }

    //Gets user (or impersonated user)
    public async Task<stngadmin.User> GetUser(HttpContext context, bool forceQuery = false)
    {
        Stopwatch sw = new Stopwatch();
        sw.Start();

        string userName = GetUserName(context);
        string cacheKeyUser = GetCacheKeyUser(userName);
        stngadmin.User returnUser;

        bool semaphoreFlag = false;

        // if the user doesn't have cached data yet, await so multiple tasks don't rush in before the cache is set
        if (!_cache.Exists(cacheKeyUser))
        {
            semaphoreFlag = true;
            await _semaphoreUser.WaitAsync();
        }

        if (context.Items.ContainsKey(@"STNGUser") && !forceQuery)
        {
            returnUser = (stngadmin.User)context.Items[@"STNGUser"];
        }

        else
        {
            //if impersonating, will get impersonated user
            if (forceQuery || !_cache.TryGet(cacheKeyUser, out stngadmin.User user))
            {
                user = await QueryUser(context);
                _cache.Set(cacheKeyUser, user);
            }

            //always have original user in cache
            stngadmin.User originalUser = await GetOriginalUser(context);

            context.Items[@"STNGUser"] = user;
            context.Items[@"EmployeeID"] = user.EmployeeID;
            context.Items[@"OriginalSTNGUser"] = originalUser;

            returnUser = user;
        }

        //only tasks that awaited semaphore should release it
        if (semaphoreFlag)
        {
            _semaphoreUser.Release();
        }

        sw.Stop();

        Console.WriteLine("User for " + context?.Request?.Path.Value + ", user: " + returnUser.EmployeeID + " received in " + sw.ElapsedMilliseconds.ToString() + " ms");
        return returnUser;
    }

    public async Task<string> GetEmail(HttpContext context, string lanid)
    {
        return (await QueryUserbyLANID(lanid)).Email;
    }

    private async Task<stngadmin.User> QueryUserbyLANID(string lanid)
    {
        List<SqlParameter> parameters = new List<SqlParameter>()
            {
                new SqlParameter()
                {
                    ParameterName = @"@Operation",
                    SqlDbType = SqlDbType.Int,
                    Value = 25
                },
                new SqlParameter()
                {
                    ParameterName = @"@LANID",
                    SqlDbType = SqlDbType.VarChar,
                    Value = lanid
                }
            };

        Dictionary<string, object> dbReturn = (await _dbService.ExecuteReaderAsync(@"stng.SP_Admin_UserManagement", parameters)).Select(x => (Dictionary<string, object>)x).FirstOrDefault();

        return ConvertUser(dbReturn);
    }

    private async Task<stngadmin.User> QueryUserById(string employeeID)
    {
        List<SqlParameter> parameters = new List<SqlParameter>()
            {
                new SqlParameter()
                {
                    ParameterName = @"@Operation",
                    SqlDbType = SqlDbType.Int,
                    Value = 25
                },
                new SqlParameter()
                {
                    ParameterName = @"@EmployeeID",
                    SqlDbType = SqlDbType.VarChar,
                    Value = employeeID
                }
            };

        Dictionary<string, object> dbReturn = (await _dbService.ExecuteReaderAsync(@"stng.SP_Admin_UserManagement", parameters)).Select(x => (Dictionary<string, object>)x).FirstOrDefault();

        return ConvertUser(dbReturn);

    }

    private string GetDBUserField(Dictionary<string, object> dbUser, string field)
    {
        return dbUser.ContainsKey(field) ? dbUser[field].ToString() : null;
    }

    private stngadmin.User ConvertUser(Dictionary<string, object> dbUser)
    {
        return new stngadmin.User()
        {
            JobTitle = GetDBUserField(dbUser, @"Title"),
            FirstName = GetDBUserField(dbUser, @"FirstName"),
            LastName = GetDBUserField(dbUser, @"LastName"),
            Email = GetDBUserField(dbUser, @"Email"),
            EmployeeID = GetDBUserField(dbUser, @"EmployeeID"),
            UserPrincipalName = GetDBUserField(dbUser, @"Email"),
            LANID = GetDBUserField(dbUser, @"LANID"),
            WorkGroup = GetDBUserField(dbUser, @"WorkGroup")
        };

    }

    private async Task<stngadmin.User> QueryUserByName(string principalName)
    {
        List<SqlParameter> parameters = new List<SqlParameter>()
            {
                new SqlParameter()
                {
                    ParameterName = @"@Operation",
                    SqlDbType = SqlDbType.Int,
                    Value = 25
                },
                new SqlParameter()
                {
                    ParameterName = @"@Email",
                    SqlDbType = SqlDbType.VarChar,
                    Value = principalName
                }
            };

        Dictionary<string, object> dbReturn = (await _dbService.ExecuteReaderAsync(@"stng.SP_Admin_UserManagement", parameters)).Select(x => (Dictionary<string, object>)x).FirstOrDefault();

        return ConvertUser(dbReturn);
    }

    private async Task<stngadmin.User> QueryUser(HttpContext context)
    {
        string userName = GetUserName(context);

        if (context.Items.ContainsKey(@"ImpersonateUserID"))
        {
            return await QueryUserById(context.Items[@"ImpersonateUserID"].ToString());
        }

        stngadmin.User currentUser = await QueryUserByName(userName);

        return currentUser;
    }



}
