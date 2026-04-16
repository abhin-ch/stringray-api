using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Plugin;
using StingrayNET.ApplicationCore.Specifications;
using System.Threading.Tasks;
using System;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository;

public class PluginRepository : BaseRepository<PluginResult>, IRepositoryS<PluginProcedure, PluginResult>
{
    protected override string Query => "stng.SP_Plugin_CRUD";
    private readonly IHttpContextAccessor _httpContextAccessor;
    public PluginRepository(IDatabase<SC> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }


    public async Task<PluginResult> Op_15(PluginProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PluginResult> Op_14(PluginProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PluginResult> Op_13(PluginProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PluginResult> Op_12(PluginProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PluginResult> Op_11(PluginProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PluginResult> Op_10(PluginProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PluginResult> Op_09(PluginProcedure model = null) { throw new NotImplementedException(); }
    public async Task<PluginResult> Op_08(PluginProcedure model = null)
    {
        return await ExecuteReaderValidation<SC>(8);
    }
    public async Task<PluginResult> Op_07(PluginProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<SC>(7, model);
    }
    public async Task<PluginResult> Op_06(PluginProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<SC>(6, model);
    }
    public async Task<PluginResult> Op_05(PluginProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<SC>(5, model);
    }
    public async Task<PluginResult> Op_04(PluginProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<SC>(4, model);
    }
    public async Task<PluginResult> Op_03(PluginProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<SC>(3, model);
    }
    public async Task<PluginResult> Op_02(PluginProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<SC>(2, model);
    }
    public async Task<PluginResult> Op_01(PluginProcedure model = null)
    {
        return await ExecuteReaderValidation<SC>(1);
    }
}