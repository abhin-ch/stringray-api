using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class DelegateRepository : BaseRepository<DelegateResult>, IRepositoryM<Procedure, DelegateResult>
{

    public DelegateRepository(IDatabase<SC> mssql) : base(mssql)
    {
    }

    protected override string Query => "stng.SP_Admin_DelegationCRUD";

    public async Task<DelegateResult> Op_01(Procedure model = null)
    {
        return await ExecuteReader<SC>(1, model);
    }

    public async Task<DelegateResult> Op_02(Procedure model = null)
    {
        return await ExecuteReader<SC>(2, model);
    }

    public async Task<DelegateResult> Op_03(Procedure model = null)
    {
        return await ExecuteReader<SC>(3, model);
    }

    public async Task<DelegateResult> Op_04(Procedure model = null)
    {
        return await ExecuteReader<SC>(4, model);
    }

    public async Task<DelegateResult> Op_05(Procedure model = null)
    {
        return await ExecuteReader<SC>(5, model);
    }

    public async Task<DelegateResult> Op_06(Procedure model = null)
    {
        return await ExecuteReader<SC>(6, model);
    }

    public async Task<DelegateResult> Op_07(Procedure model = null)
    {
        return await ExecuteReader<SC>(7, model);
    }

    public async Task<DelegateResult> Op_08(Procedure model = null)
    {
        return await ExecuteReader<SC>(8, model);
    }

    public async Task<DelegateResult> Op_09(Procedure model = null)
    {
        return await ExecuteReader<SC>(9, model);
    }

    public async Task<DelegateResult> Op_10(Procedure model = null)
    {
        return await ExecuteReader<SC>(10, model);
    }

    public async Task<DelegateResult> Op_11(Procedure model = null)
    {
        return await ExecuteReader<SC>(11, model);
    }

    public async Task<DelegateResult> Op_12(Procedure model = null)
    {
        return await ExecuteReader<SC>(12, model);
    }

    public async Task<DelegateResult> Op_13(Procedure model = null)
    {
        return await ExecuteReader<SC>(13, model);
    }

    public async Task<DelegateResult> Op_14(Procedure model = null)
    {
        return await ExecuteReader<SC>(14, model);
    }

    public async Task<DelegateResult> Op_15(Procedure model = null)
    {
        return await ExecuteReader<SC>(15, model);
    }

    public async Task<DelegateResult> Op_16(Procedure model = null)
    {
        return await ExecuteReader<SC>(16, model);
    }

    public async Task<DelegateResult> Op_17(Procedure model = null)
    {
        return await ExecuteReader<SC>(17, model);
    }

    public async Task<DelegateResult> Op_18(Procedure model = null)
    {
        return await ExecuteReader<SC>(18, model);
    }

    public async Task<DelegateResult> Op_19(Procedure model = null)
    {
        return await ExecuteReader<SC>(19, model);
    }

    public async Task<DelegateResult> Op_20(Procedure model = null)
    {
        return await ExecuteReader<SC>(20, model);
    }

    public async Task<DelegateResult> Op_21(Procedure model = null)
    {
        return await ExecuteReader<SC>(21, model);
    }

    public async Task<DelegateResult> Op_22(Procedure model = null)
    {
        return await ExecuteReader<SC>(22, model);
    }

    public async Task<DelegateResult> Op_23(Procedure model = null)
    {
        return await ExecuteReader<SC>(23, model);
    }

    public async Task<DelegateResult> Op_24(Procedure model = null)
    {
        return await ExecuteReader<SC>(24, model);
    }

    public async Task<DelegateResult> Op_25(Procedure model = null)
    {
        return await ExecuteReader<SC>(25, model);
    }

    public async Task<DelegateResult> Op_26(Procedure model = null)
    {
        return await ExecuteReader<SC>(26, model);
    }

    public Task<DelegateResult> Op_27(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<DelegateResult> Op_28(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<DelegateResult> Op_29(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<DelegateResult> Op_30(Procedure model = null)
    {
        throw new NotImplementedException();
    }

}