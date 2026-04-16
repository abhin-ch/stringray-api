using StingrayNET.ApplicationCore.Interfaces;
using System.Threading.Tasks;
using System;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.Common;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Data;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore;

namespace StingrayNET.Infrastructure.Services;
public class UserEmailService : IUserEmailService
{
    private readonly IDatabase<DED> _databaseService;
    private readonly IIdentityService _identityService;
    private readonly IHttpContextAccessor _httpContextAccessor;

    private readonly string _storedProcedure = @"stng.SP_UserEmail_CRUD";

    public UserEmailService(IDatabase<DED> databaseService, IIdentityService identityService, IHttpContextAccessor httpContextAccessor)
    {
        _databaseService = databaseService;
        _identityService = identityService;
        _httpContextAccessor = httpContextAccessor;
    }

    private async Task<CommonResult> MultiSelectProcess(int operation, Procedure model)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var result = new CommonResult();

        DataTable runningItemList = new DataTable();
        runningItemList.Columns.Add(new DataColumn("ID", typeof(string)));

        foreach (var option in model.MultiSelectList)
        {
            runningItemList.Rows.Add();

            runningItemList.Rows[runningItemList.Rows.Count - 1][0] = option.id;

        }

        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, operation);
        parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.CurrentUser);
        parameters.AddParameter("@Module", SqlDbType.VarChar, model.Module);
        parameters.AddParameter("@MultiSelectList", SqlDbType.Structured, runningItemList);


        result.Data1 = await _databaseService.ExecuteReaderAsync(_storedProcedure, parameters);

        return result;
    }

    public async Task<CommonResult> GetUserEmailOptions(Procedure model = null)
    {
        var result = new CommonResult();
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 1);
        parameters.AddParameter("@Module", SqlDbType.VarChar, model.Module);
        parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.CurrentUser);

        var data = await _databaseService.ExecuteReaderSetAsync(_storedProcedure, parameters);
        result.Data1 = data[0];
        result.Data2 = data[1];

        // result.Data1 = await _databaseService.ExecuteReaderAsync(_storedProcedure, parameters);
        return result;
    }

    public Task<CommonResult> SaveUserEmailSelection(Procedure model = null)
    {

        return MultiSelectProcess(2, model);
    }



}

