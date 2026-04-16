using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.EI;
using StingrayNET.ApplicationCore.Specifications;
using Microsoft.AspNetCore.Http;
using System;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.Infrastructure.Repository.Modules;
public class EIRepository : BaseRepository<EIResult>, IRepositoryL<EIProcedure, EIResult>
{
    protected override string Query => "stng.SP_EI_CRUD";
    private readonly IHttpContextAccessor _httpContextAccessor;

    public EIRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }
    private async Task<EIResult> MultiSelectProcess(int operation, EIProcedure model)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var result = new EIResult();

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
        parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
        parameters.AddParameter("@MultiSelectList", SqlDbType.Structured, runningItemList);


        result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);

        return result;
    }

    public Task<EIResult> Op_45(EIProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<EIResult> Op_44(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(44, model);
    }

    public async Task<EIResult> Op_43(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(43, model);
    }

    public async Task<EIResult> Op_42(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(42, model);
    }

    public async Task<EIResult> Op_41(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(41, model);
    }

    public async Task<EIResult> Op_40(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(40, model);
    }

    public async Task<EIResult> Op_39(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(39, model);
    }

    public async Task<EIResult> Op_38(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(38, model);
    }

    public async Task<EIResult> Op_37(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(37, model);
    }

    public async Task<EIResult> Op_36(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(36, model);
    }

    public Task<EIResult> Op_35(EIProcedure model = null)
    {
        return MultiSelectProcess(35, model);
    }
    public async Task<EIResult> Op_34(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(34, model);
    }

    public async Task<EIResult> Op_33(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(33, model);
    }

    public async Task<EIResult> Op_32(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(32, model);
    }

    public async Task<EIResult> Op_31(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(31, model);
    }

    public Task<EIResult> Op_30(EIProcedure model = null)
    {
        return MultiSelectProcess(30, model);
    }

    public async Task<EIResult> Op_29(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(29, model);
    }

    public async Task<EIResult> Op_28(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public Task<EIResult> Op_27(EIProcedure model = null)
    {
        return MultiSelectProcess(27, model);
    }

    public async Task<EIResult> Op_26(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<EIResult> Op_25(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<EIResult> Op_24(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<EIResult> Op_23(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public Task<EIResult> Op_22(EIProcedure model = null)
    {
        return MultiSelectProcess(22, model);
    }

    public async Task<EIResult> Op_21(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<EIResult> Op_20(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<EIResult> Op_19(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<EIResult> Op_18(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }
    public Task<EIResult> Op_17(EIProcedure model = null)
    {
        return MultiSelectProcess(17, model);
    }

    public async Task<EIResult> Op_16(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<EIResult> Op_15(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<EIResult> Op_14(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<EIResult> Op_13(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public Task<EIResult> Op_12(EIProcedure model = null)
    {
        return MultiSelectProcess(12, model);
    }

    public async Task<EIResult> Op_11(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<EIResult> Op_10(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<EIResult> Op_09(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<EIResult> Op_08(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<EIResult> Op_07(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<EIResult> Op_06(EIProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<EIResult> Op_05(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<EIResult> Op_04(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<EIResult> Op_03(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<EIResult> Op_02(EIProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<EIResult> Op_01(EIProcedure model = null)
    {
        model = new EIProcedure();
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(1, model);
    }
}