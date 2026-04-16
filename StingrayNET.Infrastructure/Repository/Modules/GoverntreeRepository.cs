using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Specifications;
using System;
using StingrayNET.ApplicationCore.Models.Governtree;
using System.Threading.Tasks;
using System.Collections.Generic;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;
public class GoverntreeRepository : BaseRepository<GoverntreeResult>, IRepositoryXL<GoverntreeProcedure, GoverntreeResult>
{
    protected override string Query => "stng.SP_Governtree_CRUD";

    private readonly IHttpContextAccessor _httpContextAccessor;

    private readonly List<string> _allowedJobAidDomain = new List<string>()
        {
            @"bpinfonet.sharepoint.com"

        };

    public GoverntreeRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task<GoverntreeResult> Op_60(GoverntreeProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(60, model);
    }

    public async Task<GoverntreeResult> Op_59(GoverntreeProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(59, model);
    }

    public async Task<GoverntreeResult> Op_58(GoverntreeProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(58, model);
    }

    public async Task<GoverntreeResult> Op_57(GoverntreeProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(57, model);
    }

    public async Task<GoverntreeResult> Op_56(GoverntreeProcedure model = null)
    {
        model.CurrentUser = (_httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()).ToString();
        return await ExecuteReaderValidation<DED>(56, model);
    }

    public async Task<GoverntreeResult> Op_55(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(55, model);
    }

    public async Task<GoverntreeResult> Op_54(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(54, model);
    }

    public async Task<GoverntreeResult> Op_53(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(53, model);
    }

    public async Task<GoverntreeResult> Op_52(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(52, model);
    }

    public async Task<GoverntreeResult> Op_51(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(51, model);
    }

    public async Task<GoverntreeResult> Op_50(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(50, model);
    }

    public async Task<GoverntreeResult> Op_49(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(49, model);
    }

    public async Task<GoverntreeResult> Op_48(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(48, model);
    }

    public async Task<GoverntreeResult> Op_47(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(47, model);
    }

    public async Task<GoverntreeResult> Op_46(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(46, model);
    }

    public async Task<GoverntreeResult> Op_45(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(45, model);

    }
    public async Task<GoverntreeResult> Op_44(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(44, model);

    }
    public async Task<GoverntreeResult> Op_43(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(43, model);

    }
    public async Task<GoverntreeResult> Op_42(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(42, model);

    }
    public async Task<GoverntreeResult> Op_41(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(41, model);

    }
    public async Task<GoverntreeResult> Op_40(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(40, model);

    }
    public async Task<GoverntreeResult> Op_39(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(39, model);

    }
    public async Task<GoverntreeResult> Op_38(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(38, model);

    }
    public async Task<GoverntreeResult> Op_37(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(37, model);

    }
    public async Task<GoverntreeResult> Op_36(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(36, model);

    }



    public async Task<GoverntreeResult> Op_35(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(35, model);

    }
    public async Task<GoverntreeResult> Op_34(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(34, model);

    }
    public async Task<GoverntreeResult> Op_33(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(33, model);

    }
    public async Task<GoverntreeResult> Op_32(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(32, model);

    }
    public async Task<GoverntreeResult> Op_31(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(31, model);

    }
    public async Task<GoverntreeResult> Op_30(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(30, model);

    }
    public async Task<GoverntreeResult> Op_29(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(29, model);

    }
    public async Task<GoverntreeResult> Op_28(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(28, model);

    }
    public async Task<GoverntreeResult> Op_27(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

        return await ExecuteReader<DED>(27, model);

    }
    public async Task<GoverntreeResult> Op_26(GoverntreeProcedure model = null)
    {

        return await ExecuteReader<DED>(26, model);
    }
    public async Task<GoverntreeResult> Op_25(GoverntreeProcedure model = null)
    {

        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

        return await ExecuteReader<DED>(25, model);
    }
    public async Task<GoverntreeResult> Op_24(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();

        return await ExecuteReader<DED>(24, model);
    }
    public async Task<GoverntreeResult> Op_23(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }
    public async Task<GoverntreeResult> Op_22(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }
    public async Task<GoverntreeResult> Op_21(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }
    public async Task<GoverntreeResult> Op_20(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }
    public async Task<GoverntreeResult> Op_19(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }
    public async Task<GoverntreeResult> Op_18(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }
    public async Task<GoverntreeResult> Op_17(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }
    public async Task<GoverntreeResult> Op_16(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }
    public async Task<GoverntreeResult> Op_15(GoverntreeProcedure model = null)
    {
        return await ExecuteNonQuery<DED>(15, model);
    }
    public async Task<GoverntreeResult> Op_14(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(14, model);
    }
    public async Task<GoverntreeResult> Op_13(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }
    public async Task<GoverntreeResult> Op_12(GoverntreeProcedure model = null)
    {
        return await ExecuteNonQuery<DED>(12, model);
    }
    public async Task<GoverntreeResult> Op_11(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(11, model);
    }
    public async Task<GoverntreeResult> Op_10(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }
    public async Task<GoverntreeResult> Op_09(GoverntreeProcedure model = null)
    {
        return await ExecuteNonQuery<DED>(9, model);
    }
    public async Task<GoverntreeResult> Op_08(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(8, model);
    }
    public async Task<GoverntreeResult> Op_07(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }
    public async Task<GoverntreeResult> Op_06(GoverntreeProcedure model = null)
    {
        return await ExecuteNonQuery<DED>(6, model);
    }
    public async Task<GoverntreeResult> Op_05(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(5, model);
    }
    public async Task<GoverntreeResult> Op_04(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }
    public async Task<GoverntreeResult> Op_03(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteNonQuery<DED>(3, model);
    }
    public async Task<GoverntreeResult> Op_02(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(2, model);
    }

    public async Task<GoverntreeResult> Op_01(GoverntreeProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }

    public async Task<GoverntreeResult> Op_61(GoverntreeProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(61, model);
    }

    public async Task<GoverntreeResult> Op_62(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(62, model);
    }

    public async Task<GoverntreeResult> Op_63(GoverntreeProcedure model = null)
    {
        return await ExecuteReaderValidation<DED>(63, model);
    }

    public async Task<GoverntreeResult> Op_64(GoverntreeProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(64, model);
    }

    public Task<GoverntreeResult> Op_65(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_66(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_67(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_68(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_69(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_70(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_71(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_72(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_73(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_74(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_75(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_76(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_77(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_78(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_79(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_80(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_81(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_82(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_83(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_84(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_85(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_86(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_87(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_88(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_89(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<GoverntreeResult> Op_90(GoverntreeProcedure model = null)
    {
        throw new NotImplementedException();
    }
}