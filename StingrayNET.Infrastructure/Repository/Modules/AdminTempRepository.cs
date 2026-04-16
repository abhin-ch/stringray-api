using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository;
public class AdminTempRepository : BaseRepository<AdminResult>, IRepositoryS<AdminTempProcedure, AdminResult>
{
    protected override string Query => "stng.SP_Admin_Temp";

    private readonly IHttpContextAccessor _httpContextAccessor;

    public AdminTempRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<AdminResult> Op_15(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_14(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_13(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_12(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_11(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_10(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_09(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_08(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_07(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_06(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_05(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_04(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_03(AdminTempProcedure model = null)
    {
        throw new NotImplementedException();
    }
    public async Task<AdminResult> Op_02(AdminTempProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }
    public async Task<AdminResult> Op_01(AdminTempProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReader<DED>(1, model);
    }

}
