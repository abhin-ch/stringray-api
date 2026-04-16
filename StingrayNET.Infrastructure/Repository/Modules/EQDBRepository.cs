using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.EQDB;
using StingrayNET.ApplicationCore.Specifications;
using Microsoft.AspNetCore.Http;
using System;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.Infrastructure.Repository.Modules;

public class EQDBRepository : BaseRepository<EQDBResult>, IRepositoryM<EQDBProcedure, EQDBResult>
{
    protected override string Query => "stng.SP_EQDB_CRUD";
    private readonly IHttpContextAccessor _httpContextAccessor;

    public EQDBRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }
    public Task<EQDBResult> Op_30(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_29(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_28(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_27(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_26(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_25(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_24(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_23(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_22(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_21(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EQDBResult> Op_20(EQDBProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<EQDBResult> Op_19(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<EQDBResult> Op_18(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<EQDBResult> Op_17(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<EQDBResult> Op_16(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<EQDBResult> Op_15(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<EQDBResult> Op_14(EQDBProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<EQDBResult> Op_13(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<EQDBResult> Op_12(EQDBProcedure model = null)
    {

        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<EQDBResult> Op_11(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<EQDBResult> Op_10(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<EQDBResult> Op_09(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<EQDBResult> Op_08(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<EQDBResult> Op_07(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<EQDBResult> Op_06(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<EQDBResult> Op_05(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<EQDBResult> Op_04(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<EQDBResult> Op_03(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<EQDBResult> Op_02(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<EQDBResult> Op_01(EQDBProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }
}
