using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.ECRA;
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
public class ECRARepository : BaseRepository<ECRAResult>, IRepositoryL<ECRAProcedure, ECRAResult>
{
    protected override string Query => "stng.SP_ECRA_CRUD";

    private readonly IHttpContextAccessor _httpContextAccessor;

    public ECRARepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }
    private async Task<ECRAResult> MultiSelectProcess(int operation, ECRAProcedure model)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var result = new ECRAResult();

        DataTable runningItemList = new DataTable();
        runningItemList.Columns.Add(new DataColumn("ID", typeof(string)));

        foreach (var option in model.MultiSelectList)
        {
            runningItemList.Rows.Add();

            runningItemList.Rows[runningItemList.Rows.Count - 1][0] = option.id;

        }

        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, operation);
        parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
        parameters.AddParameter("@MultiSelectList", SqlDbType.Structured, runningItemList);


        result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);

        return result;
    }

    public Task<ECRAResult> Op_45(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_44(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_43(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_42(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_41(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_40(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_39(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_38(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_37(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_36(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_35(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_34(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_33(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_32(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_31(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_30(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_29(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_28(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_27(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_26(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_25(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_24(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_23(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_22(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_21(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_20(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_19(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_18(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_17(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_16(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_15(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_14(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<ECRAResult> Op_13(ECRAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<ECRAResult> Op_12(ECRAProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteNonQuery<DED>(12, model);
    }

    public async Task<ECRAResult> Op_11(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<ECRAResult> Op_10(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<ECRAResult> Op_09(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<ECRAResult> Op_08(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<ECRAResult> Op_07(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(7);
    }

    public async Task<ECRAResult> Op_06(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<ECRAResult> Op_05(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<ECRAResult> Op_04(ECRAProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(4, model);
    }

    public async Task<ECRAResult> Op_03(ECRAProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteNonQuery<DED>(3, model);
    }

    public async Task<ECRAResult> Op_02(ECRAProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<ECRAResult> Op_01(ECRAProcedure model = null)
    {
        return await ExecuteReader<DED>(1);
    }
}
