using StingrayNET.ApplicationCore.Interfaces;
using System.Threading.Tasks;
using System;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Data;
using StingrayNET.ApplicationCore.CustomExceptions;
using Microsoft.AspNetCore.Http;

namespace StingrayNET.Infrastructure.Services;
public class NotificationService : INotificationService
{
    private readonly IDatabase<SC> _databaseService;
    private readonly IIdentityService _identityService;
    private readonly IHttpContextAccessor _httpContextAccessor;

    private readonly string _storedProcedure = @"stng.SP_Notification_CRUD";

    public NotificationService(IDatabase<SC> databaseService, IIdentityService identityService, IHttpContextAccessor httpContextAccessor)
    {
        _databaseService = databaseService;
        _identityService = identityService;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<string> AddNotification(Notification notification)
    {
        List<SqlParameter> sqlParams = new List<SqlParameter>()
            {
                new SqlParameter(@"@Operation",SqlDbType.Int)
                {
                    Value = 1
                },
                new SqlParameter(@"@EmployeeID",SqlDbType.VarChar)
                {
                    Value = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()
                },
                new SqlParameter(@"@ModuleShort",SqlDbType.VarChar)
                {
                    Value = notification.Module.ToString()
                },
                new SqlParameter(@"@ActionType",SqlDbType.VarChar)
                {
                    Value = notification.NotificationActionType.ToString()
                },
                new SqlParameter(@"@IDType",SqlDbType.VarChar)
                {
                    Value = notification.NotificationIDType.ToString()
                },
                new SqlParameter(@"@ModuleView",SqlDbType.VarChar)
                {
                    Value = notification.ModuleView
                },
                new SqlParameter(@"@RecordIDFieldName",SqlDbType.VarChar)
                {
                    Value = notification.RecordIDFieldName
                },
                new SqlParameter(@"@RecordIDVal",SqlDbType.VarChar)
                {
                    Value = notification.RecordIDVal
                },
                new SqlParameter(@"@RelatedEmployeeID",SqlDbType.VarChar)
                {
                    Value = notification.EmployeeID
                },
                new SqlParameter(@"@ASID",SqlDbType.Int)
                {
                    Value = notification.ASID
                },

            };

        var returnList = await _databaseService.ExecuteReaderAsync(_storedProcedure, sqlParams);

        foreach (var obj in returnList)
        {
            //Cast
            Dictionary<string, object> row = (Dictionary<string, object>)obj;

            //Check for ReturnMessage
            if (row.ContainsKey(@"ReturnMessage"))
            {
                throw new ValidationException(row[@"ReturnMessage"].ToString());
            }

            //Check for ReturnID
            else if (row.ContainsKey(@"ReturnID"))
            {
                return row[@"ReturnID"].ToString();
            }
        }

        throw new Exception(@"Unable to obtain NotificationID from new Notification");

    }

    public async Task<long> AddressNotification(string notificationID, bool addressAll = false)
    {
        List<SqlParameter> sqlParams = new List<SqlParameter>()
            {
                new SqlParameter(@"@Operation",SqlDbType.Int)
                {
                    Value = 2
                },
                new SqlParameter(@"@EmployeeID",SqlDbType.VarChar)
                {
                    Value = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()
                },
                new SqlParameter(@"@NotificationID",SqlDbType.VarChar)
                {
                    Value =  notificationID
                },
                new SqlParameter(@"@AddressAll",SqlDbType.Bit)
                {
                    Value = addressAll
                }
            };

        var returnList = await _databaseService.ExecuteReaderAsync(_storedProcedure, sqlParams);

        foreach (var obj in returnList)
        {
            //Cast
            Dictionary<string, object> row = (Dictionary<string, object>)obj;

            //Check for ReturnMessage
            if (row.ContainsKey(@"ReturnMessage"))
            {
                throw new ValidationException(row[@"ReturnMessage"].ToString());
            }

            //Check for ReturnID
            else if (row.ContainsKey(@"ReturnID"))
            {
                return Convert.ToInt64(row[@"ReturnID"]);
            }
        }

        throw new Exception(@"Unable to address Notification");

    }

    public async Task<List<Notification>> GetNotifications()
    {
        List<SqlParameter> sqlParams = new List<SqlParameter>()
            {
                new SqlParameter(@"@Operation",SqlDbType.Int)
                {
                    Value = 3
                },
                new SqlParameter(@"@EmployeeID",SqlDbType.VarChar)
                {
                    Value = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()
                }
            };

        var returnList = await _databaseService.ExecuteReaderAsync(_storedProcedure, sqlParams);

        if (returnList.Count > 0)
        {
            var firstRow = (Dictionary<string, object>)returnList[0];

            if (firstRow.ContainsKey(@"ReturnMessage"))
            {
                throw new ValidationException(firstRow[@"ReturnMessage"].ToString());
            }

            return ConvertNotifications(returnList);
        }
        else
        {
            return new List<Notification>();
        }


    }

    private List<Notification> ConvertNotifications(List<object> data)
    {
        List<Notification> returnList = new List<Notification>();

        //Check for presence of all required fields
        var firstRow = (Dictionary<string, object>)data[0];

        //TODO - centralize this somehow (Or true up prop names)
        List<string> requiredFields = new List<string>()
            {
                @"NotificationID",
                @"ActionType",
                @"ModuleShort",
                @"RecordIDType",
                @"ModuleView",
                @"RecordIDFieldName",
                @"RecordIDVal",
                @"EmployeeID",
                @"ASID"
            };


        foreach (string requiredField in requiredFields)
        {
            if (!firstRow.ContainsKey(requiredField))
            {
                throw new Exception(string.Format(@"{0} not in Notification DB return", requiredField));
            }
        }

        foreach (var obj in data)
        {
            //Cast
            var row = (Dictionary<string, object>)obj;

            //Add notification to returnList
            returnList.Add(new Notification(

                notificationID: row[@"NotificationID"].ToString(),
                notificationActionType: row[@"ActionType"].ToString(),
                module: row[@"ModuleShort"].ToString(),
                notificationIDType: row[@"RecordIDType"].ToString(),
                recordIDFieldName: row[@"RecordIDFieldName"].ToString(),
                recordIDVal: row[@"RecordIDVal"].ToString(),
                moduleView: string.IsNullOrEmpty(row[@"ModuleView"].ToString()) ? null : row[@"ModuleView"].ToString(),
                employeeID: string.IsNullOrEmpty(row[@"EmployeeID"].ToString()) ? null : row[@"EmployeeID"].ToString(),
                asid: string.IsNullOrEmpty(row[@"ASID"].ToString()) ? null : Convert.ToInt32(row[@"ASID"])

            ));

        }

        return returnList;
    }
}

