using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.StandardComp;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;
namespace StingrayNET.Infrastructure.Repository.Modules;

public class StandardCompRepository : BaseRepository<StandardCompResult>, IRepositoryS<StandardCompProcedure, StandardCompResult>
{

    public StandardCompRepository(IDatabase<DED> mssql) : base(mssql)
    {
    }

    protected override string Query => "stng.SP_Standardized_CRUD";

    public async Task<StandardCompResult> Op_01(StandardCompProcedure model = null)
    {
        return await ExecuteReader<DED>(1);
    }

    public async Task<StandardCompResult> Op_02(StandardCompProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public Task<StandardCompResult> Op_03(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_04(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_05(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_06(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_07(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_08(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_09(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_10(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_11(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_12(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_13(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_14(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<StandardCompResult> Op_15(StandardCompProcedure model = null)
    {
        throw new NotImplementedException();
    }
}
