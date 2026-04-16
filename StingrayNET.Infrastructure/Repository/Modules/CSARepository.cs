using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.CSA;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;
namespace StingrayNET.Infrastructure.Repository.Modules;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Abstractions;

public class CSARepository : BaseRepository<CSAResult>, IRepositoryM<CSAProcedure, CSAResult>
{
    protected override string Query => "stng.SP_CSA_CRUD";

    private IHttpContextAccessor _httpContextAccessor;

    public CSARepository(IDatabase<DED> ded, IDatabase<SC> sc, IHttpContextAccessor httpContextAccessor) : base(ded, sc)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private async Task<bool> getAdminStatus()
    {
        var scModel = new AdminProcedure
        {
            EmployeeID = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()),
            Permission = "AdminCSA"
        };


        var db = await _sc.ExecuteReaderSetAsync("stng.SP_Admin_UserManagement", scModel.GetParameters(56));

        if (db[0].Count > 0)
        {
            return true;

        }

        return false;
    }
    public Task<CSAResult> Op_30(CSAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CSAResult> Op_29(CSAProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<CSAResult> Op_28(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public async Task<CSAResult> Op_27(CSAProcedure model = null)
    {
        model.isAdmin = await getAdminStatus();
        return await ExecuteReaderValidation<DED>(27, model);
    }

    public async Task<CSAResult> Op_26(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<CSAResult> Op_25(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<CSAResult> Op_24(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<CSAResult> Op_23(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<CSAResult> Op_22(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<CSAResult> Op_21(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<CSAResult> Op_20(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<CSAResult> Op_19(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<CSAResult> Op_18(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<CSAResult> Op_17(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<CSAResult> Op_16(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<CSAResult> Op_15(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<CSAResult> Op_14(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<CSAResult> Op_13(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<CSAResult> Op_12(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<CSAResult> Op_11(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<CSAResult> Op_10(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<CSAResult> Op_09(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<CSAResult> Op_08(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<CSAResult> Op_07(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<CSAResult> Op_06(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<CSAResult> Op_05(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<CSAResult> Op_04(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<CSAResult> Op_03(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<CSAResult> Op_02(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<CSAResult> Op_01(CSAProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }

}