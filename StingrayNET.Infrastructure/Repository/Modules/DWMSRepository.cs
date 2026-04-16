using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.DWMS;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class DWMSRepository : BaseRepository<DWMSResult>, IRepositoryL<DWMSProcedure, DWMSResult>
{
    protected override string Query => "stng.SP_DWMS_CRUD";


    public DWMSRepository(IDatabase<DED> mssql) : base(mssql) { }


    public Task<DWMSResult> Op_45(DWMSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<DWMSResult> Op_44(DWMSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<DWMSResult> Op_43(DWMSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<DWMSResult> Op_42(DWMSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<DWMSResult> Op_41(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(41, model);
    }

    public async Task<DWMSResult> Op_40(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(40, model);
    }

    public async Task<DWMSResult> Op_39(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(39, model);
    }

    public async Task<DWMSResult> Op_38(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(38, model);
    }

    public async Task<DWMSResult> Op_37(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(37, model);
    }

    public async Task<DWMSResult> Op_36(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(36, model);
    }

    public async Task<DWMSResult> Op_35(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(35, model);
    }

    public async Task<DWMSResult> Op_34(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(34, model);
    }

    public async Task<DWMSResult> Op_33(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(33, model);
    }

    public async Task<DWMSResult> Op_32(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(32, model);
    }

    public async Task<DWMSResult> Op_31(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(31, model);
    }

    public async Task<DWMSResult> Op_30(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(30, model);
    }

    public async Task<DWMSResult> Op_29(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(29, model);
    }

    public async Task<DWMSResult> Op_28(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public async Task<DWMSResult> Op_27(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(27, model);
    }

    public async Task<DWMSResult> Op_26(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<DWMSResult> Op_25(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<DWMSResult> Op_24(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<DWMSResult> Op_23(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<DWMSResult> Op_22(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<DWMSResult> Op_21(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<DWMSResult> Op_20(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<DWMSResult> Op_19(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<DWMSResult> Op_18(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<DWMSResult> Op_17(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<DWMSResult> Op_16(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<DWMSResult> Op_15(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<DWMSResult> Op_14(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<DWMSResult> Op_13(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<DWMSResult> Op_12(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<DWMSResult> Op_11(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<DWMSResult> Op_10(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<DWMSResult> Op_09(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<DWMSResult> Op_08(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<DWMSResult> Op_07(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<DWMSResult> Op_06(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<DWMSResult> Op_05(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<DWMSResult> Op_04(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<DWMSResult> Op_03(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<DWMSResult> Op_02(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<DWMSResult> Op_01(DWMSProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }

}
