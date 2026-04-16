using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Metric;
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

public class MetricRepository : BaseRepository<MetricResult>, IRepositoryXL<MetricProcedure, MetricResult>
{
    protected override string Query => "stng.SP_Metric_CRUD";

    private readonly IHttpContextAccessor _httpContextAccessor;

    public MetricRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private async Task<MetricResult> MultiSelectProcess(int operation, MetricProcedure model)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var result = new MetricResult();

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

    public Task<MetricResult> Op_90(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_89(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_88(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_87(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_86(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_85(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_84(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_83(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<MetricResult> Op_82(MetricProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<MetricResult> Op_81(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var result = new MetricResult();

        DataTable runningItemList = new DataTable();
        runningItemList.Columns.Add(new DataColumn("ID", typeof(string)));

        foreach (var option in model.MultiSelectList)
        {
            runningItemList.Rows.Add();

            runningItemList.Rows[runningItemList.Rows.Count - 1][0] = option.id;

        }

        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 81);
        parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.CurrentUser);
        parameters.AddParameter("@MultiSelectList", SqlDbType.Structured, runningItemList);
        parameters.AddParameter("@MonthYear", SqlDbType.VarChar, model.MonthYear);

        result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);

        return result;
    }

    public async Task<MetricResult> Op_80(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(80, model);
    }

    public async Task<MetricResult> Op_79(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(79, model);
    }

    public async Task<MetricResult> Op_78(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(78, model);
    }

    public async Task<MetricResult> Op_77(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(77, model);
    }

    public async Task<MetricResult> Op_76(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(76, model);
    }

    public async Task<MetricResult> Op_75(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(75);
    }

    public Task<MetricResult> Op_74(MetricProcedure model = null)
    {
        return MultiSelectProcess(74, model);
    }

    public async Task<MetricResult> Op_73(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(73, model);
    }

    public async Task<MetricResult> Op_72(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(72, model);
    }

    public async Task<MetricResult> Op_71(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(71, model);
    }

    public async Task<MetricResult> Op_70(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(70, model);
    }
    public async Task<MetricResult> Op_69(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(69, model);
    }
    public async Task<MetricResult> Op_68(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(68, model);
    }
    public async Task<MetricResult> Op_67(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(67, model);
    }
    public async Task<MetricResult> Op_66(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(66, model);
    }
    public async Task<MetricResult> Op_65(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(65, model);
    }
    public async Task<MetricResult> Op_64(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(64);
    }

    public async Task<MetricResult> Op_63(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(63, model);
    }

    public async Task<MetricResult> Op_62(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(62, model);
    }

    public async Task<MetricResult> Op_61(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(61, model);
    }

    public async Task<MetricResult> Op_60(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(60, model);
    }

    public async Task<MetricResult> Op_59(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(59, model);
    }

    public async Task<MetricResult> Op_58(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(58, model);
    }

    public async Task<MetricResult> Op_57(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(57, model);
    }

    public async Task<MetricResult> Op_56(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(56, model);
    }

    public async Task<MetricResult> Op_55(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(55, model);
    }

    public async Task<MetricResult> Op_54(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(54, model);
    }

    public async Task<MetricResult> Op_53(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(53, model);
    }

    public async Task<MetricResult> Op_52(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(52, model);
    }

    public async Task<MetricResult> Op_51(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(51, model);
    }

    public async Task<MetricResult> Op_50(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(50, model);
    }

    public async Task<MetricResult> Op_49(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(49, model);
    }

    public async Task<MetricResult> Op_48(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(48, model);
    }

    public async Task<MetricResult> Op_47(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(47, model);
    }

    public async Task<MetricResult> Op_46(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(46, model);
    }

    public async Task<MetricResult> Op_45(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(45, model);

    }

    public async Task<MetricResult> Op_44(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(44, model);
    }

    public async Task<MetricResult> Op_43(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(43, model);
    }

    public async Task<MetricResult> Op_42(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(42, model);
    }

    public async Task<MetricResult> Op_41(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(41, model);
    }

    public async Task<MetricResult> Op_40(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(40, model);
    }

    public async Task<MetricResult> Op_39(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(39, model);
    }

    public async Task<MetricResult> Op_38(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(38, model);
    }

    public async Task<MetricResult> Op_37(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(37, model);
    }

    public async Task<MetricResult> Op_36(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(36, model);
    }

    public async Task<MetricResult> Op_35(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(35, model);
    }

    public async Task<MetricResult> Op_34(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(34, model);
    }

    public async Task<MetricResult> Op_33(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(33, model);
    }

    public async Task<MetricResult> Op_32(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(32, model);
    }

    public async Task<MetricResult> Op_31(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(31, model);
    }

    public async Task<MetricResult> Op_30(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(30, model);
    }

    public async Task<MetricResult> Op_29(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(29, model);
    }

    public async Task<MetricResult> Op_28(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(28, model);
    }

    public async Task<MetricResult> Op_27(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(27, model);
    }

    public async Task<MetricResult> Op_26(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<MetricResult> Op_25(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<MetricResult> Op_24(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<MetricResult> Op_23(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }


    public async Task<MetricResult> Op_22(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<MetricResult> Op_21(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<MetricResult> Op_20(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<MetricResult> Op_19(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<MetricResult> Op_18(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<MetricResult> Op_17(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<MetricResult> Op_16(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<MetricResult> Op_15(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<MetricResult> Op_14(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<MetricResult> Op_13(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<MetricResult> Op_12(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<MetricResult> Op_11(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<MetricResult> Op_10(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<MetricResult> Op_09(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<MetricResult> Op_08(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<MetricResult> Op_07(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(7, model);
    }


    public async Task<MetricResult> Op_06(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(6, model);
    }


    public async Task<MetricResult> Op_05(MetricProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<MetricResult> Op_04(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<MetricResult> Op_03(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<MetricResult> Op_02(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<MetricResult> Op_01(MetricProcedure model = null)
    {
        model.CurrentUser = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(1, model);
    }

}