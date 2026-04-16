using Serilog;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.File;
using StingrayNET.ApplicationCore.HelperFunctions;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Abstractions;

public class CommonRepository : BaseRepository<CommonResult>, IRepositoryM<Procedure, CommonResult>
{
    protected override string Query => "stng.SP_Common_CRUD";
    private readonly IWSService _wsService;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IUserEmailService _userEmailService;

    public CommonRepository(IDatabase<SC> scDatabase, IDatabase<DED> dedDatabase, IWSService wsService, IHttpContextAccessor httpContextAccessor, IUserEmailService userEmailService) : base(scDatabase, dedDatabase)
    {
        _wsService = wsService;
        _httpContextAccessor = httpContextAccessor;
        _userEmailService = userEmailService;
    }

    public async Task<CommonResult> Op_01(Procedure model = null)
    {
        return await ExecuteReader<SC>(1, model);
    }

    public async Task<CommonResult> Op_02(Procedure model = null)
    {
        return await ExecuteReader<SC>(2);
    }

    /// <summary>
    /// Upload all Endpoints
    /// </summary>
    /// <param name="model"></param>
    /// <returns></returns>
    public async Task<CommonResult> Op_03(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 3);
        parameters.AddParameter("@Endpoints", SqlDbType.Structured, new EndpointTable(model.Value1));
        parameters.AddParameter("@Privileges", SqlDbType.Structured, new AppSecurityTable(model.Value2));
        CommonResult result = new CommonResult();
        return result;
    }

    public async Task<CommonResult> Op_04(Procedure model = null)
    {
        switch ((Department)Enum.ToObject(typeof(Department), model.Num1))
        {
            case Department.DED:
                {
                    return await ExecuteNonQuery<DED>(4, model);
                }
            case Department.SC:
                {

                    return await ExecuteNonQuery<SC>(4, model);
                }
        }
        throw new ArgumentException($"Invalid Department {model.Num1}");
    }

    public async Task<CommonResult> Op_05(Procedure model = null)
    {
        switch ((Department)Enum.ToObject(typeof(Department), model.Num1))
        {
            case Department.DED:
                {
                    return await ExecuteReader<DED>(5, model);
                }
            case Department.SC:
                {

                    return await ExecuteReader<SC>(5, model);
                }
        }
        throw new ArgumentException($"Invalid Department {model.Num1}");
    }

    public async Task<CommonResult> Op_06(Procedure model = null)
    {
        CommonResult result = new CommonResult();
        var data = await _sc.ExecuteReaderAsync(Query, model.GetParameters(6));
        result.Data = DataParser.GetValueFromData<string>(data, "url");
        return result;
    }

    public async Task<CommonResult> Op_07(Procedure model = null)
    {
        return await ExecuteReader<SC>(7, model);
    }

    public async Task<CommonResult> Op_08(Procedure model = null)
    {
        switch ((Department)Enum.ToObject(typeof(Department), model.Num1))
        {
            case Department.DED:
                {
                    return await ExecuteNonQuery<DED>(8, model);
                }
            case Department.SC:
                {

                    return await ExecuteNonQuery<SC>(8, model);
                }
        }
        throw new ArgumentException($"Invalid Department {model.Num1}");
    }

    public async Task<CommonResult> Op_09(Procedure model = null)
    {
        return await ExecuteReader<SC>(9, model);
    }

    public async Task<CommonResult> Op_10(Procedure model = null)
    {
        return await ExecuteReader<SC>(10);
    }

    public async Task<CommonResult> Op_11(Procedure model = null)
    {
        var query = "stng.SP_Common_UserDropDown";
        return await ExecuteReader<SC>(1, model, query);
    }

    public async Task<CommonResult> Op_12(Procedure model = null)
    {
        var query = "stng.SP_Common_UserDropDown";
        return await ExecuteReader<SC>(2, model, query);
    }

    public async Task<CommonResult> Op_13(Procedure model = null)
    {
        var query = "stng.SP_Common_UserDropDown";
        return await ExecuteReader<SC>(3, model, query);
    }

    public async Task<CommonResult> Op_14(Procedure model = null)
    {
        var query = "stng.SP_Common_UserDropDown";
        return await ExecuteReader<SC>(4, model, query);
    }

    public async Task<CommonResult> Op_15(Procedure model = null)
    {
        var result = new CommonResult();
        result.Data = await _wsService.IssueToken(endpoint: model.Value1, context: _httpContextAccessor.HttpContext);
        return result;
    }

    public async Task<CommonResult> Op_30(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_29(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_28(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_27(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_26(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_25(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_24(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_23(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_22(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_21(Procedure model = null) { throw new NotImplementedException(); }
    public async Task<CommonResult> Op_20(Procedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await _userEmailService.SaveUserEmailSelection(model);
    }
    public async Task<CommonResult> Op_19(Procedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await _userEmailService.GetUserEmailOptions(model);
    }
    public async Task<CommonResult> Op_18(Procedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }
    public async Task<CommonResult> Op_17(Procedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }
    public async Task<CommonResult> Op_16(Procedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }
}