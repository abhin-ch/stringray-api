using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models.TWP;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Infrastructure.Repository.Modules;
public class TWPRepository : BaseRepository<TWPResult>, IRepositoryL<TWPProcedure, TWPResult>
{
    protected override string Query => "stng.SP_TWP_CRUD";

    public TWPRepository(IDatabase<SC> mssql) : base(mssql)
    {
    }

    public async Task<TWPResult> Op_01(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(1, model);
    }
    public async Task<TWPResult> Op_02(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(2, model);
    }


    public async Task<TWPResult> Op_03(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(3, model);
    }

    public async Task<TWPResult> Op_04(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(4, model);
    }

    public async Task<TWPResult> Op_05(TWPProcedure model = null)
    {
        return await ExecuteReaderValidation<SC>(5, model);
    }

    public async Task<TWPResult> Op_06(TWPProcedure model = null)
    {
        return await ExecuteReaderValidation<SC>(6, model);
    }

    public async Task<TWPResult> Op_07(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(7);
    }

    public async Task<TWPResult> Op_11(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(11);
    }

    public async Task<TWPResult> Op_12(TWPProcedure model = null)
    {
        return await ExecuteReaderValidation<SC>(12, model);
    }

    public async Task<TWPResult> Op_13(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(13, model);
    }

    public Task<TWPResult> Op_14(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<TWPResult> Op_15(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(15);
    }


    public Task<TWPResult> Op_10(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<TWPResult> Op_09(TWPProcedure model = null)
    {
        var gcTable = new GCATable(model.Value1);
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 9);
        parameters.AddParameter("@GCActivity", System.Data.SqlDbType.Structured, gcTable);
        var result = new TWPResult();
        result.Data1 = await _sc.ExecuteReaderAsync(Query, parameters);

        return result;
    }

    public async Task<TWPResult> Op_08(TWPProcedure model = null)
    {
        return await ExecuteReader<SC>(8, model);
    }

    public Task<TWPResult> Op_44(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_43(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_42(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_41(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_40(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_39(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_38(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_37(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_36(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_35(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_34(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_33(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_32(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_31(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_30(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_29(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_28(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_27(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_26(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_25(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_24(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_23(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_22(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_21(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_20(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_19(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_18(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_17(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TWPResult> Op_16(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }


    public Task<TWPResult> Op_45(TWPProcedure model = null)
    {
        throw new NotImplementedException();
    }
}