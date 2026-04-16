using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models.CMDS;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class CMDSRepository : BaseRepository<CMDSResult>, IRepositoryL<CMDSProcedure, CMDSResult>
{
    protected override string Query => "stng.SP_CMDS_CRUD";

    public CMDSRepository(IDatabase<DED> mssql) : base(mssql) { }


    public Task<CMDSResult> Op_45(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_44(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_43(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_42(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_41(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_40(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_39(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_38(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CMDSResult> Op_37(CMDSProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<CMDSResult> Op_36(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(38, model);
    }

    public async Task<CMDSResult> Op_35(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(37, model);
    }

    public async Task<CMDSResult> Op_34(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(36, model);
    }

    public async Task<CMDSResult> Op_33(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(35, model);
    }

    public async Task<CMDSResult> Op_32(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(34, model);
    }

    public async Task<CMDSResult> Op_31(CMDSProcedure model = null)
    {
        var result = new CMDSResult();

        foreach (var category in model.Categories)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 31);
            parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
            parameters.AddParameter("@Category", SqlDbType.UniqueIdentifier, Guid.Parse(category.id));

            List<object> categories = await _ded.ExecuteReaderAsync(Query, parameters);
            if ((category.value && categories.Count > 0) || (!category.value && categories.Count == 0))
            {
                continue;
            }
            else if (category.value)
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 32);
                parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
                parameters.AddParameter("@Category", SqlDbType.UniqueIdentifier, Guid.Parse(category.id));
                parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.CurrentUser);

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
            else
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 33);
                parameters.AddParameter("@UniqueID", SqlDbType.UniqueIdentifier, Guid.Parse(model.UniqueID));
                parameters.AddParameter("@Category", SqlDbType.UniqueIdentifier, Guid.Parse(category.id));

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
        }

        return result;

    }

    public async Task<CMDSResult> Op_30(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(30, model);
    }

    public async Task<CMDSResult> Op_29(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(29, model);
    }

    public async Task<CMDSResult> Op_28(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(28, model);
    }

    public async Task<CMDSResult> Op_27(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(27, model);
    }

    public async Task<CMDSResult> Op_26(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(26, model);
    }

    public async Task<CMDSResult> Op_25(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<CMDSResult> Op_24(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<CMDSResult> Op_23(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<CMDSResult> Op_22(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<CMDSResult> Op_21(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<CMDSResult> Op_20(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<CMDSResult> Op_19(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<CMDSResult> Op_18(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<CMDSResult> Op_17(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(17, model);
    }

    public async Task<CMDSResult> Op_16(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<CMDSResult> Op_15(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<CMDSResult> Op_14(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(14, model);
    }

    public async Task<CMDSResult> Op_13(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }

    public async Task<CMDSResult> Op_12(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<CMDSResult> Op_11(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<CMDSResult> Op_10(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<CMDSResult> Op_09(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<CMDSResult> Op_08(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<CMDSResult> Op_07(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<CMDSResult> Op_06(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<CMDSResult> Op_05(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<CMDSResult> Op_04(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public async Task<CMDSResult> Op_03(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(3, model);
    }

    public async Task<CMDSResult> Op_02(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<CMDSResult> Op_01(CMDSProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }

}
