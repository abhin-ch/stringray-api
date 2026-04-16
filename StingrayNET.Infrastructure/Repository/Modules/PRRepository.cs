using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models.PR;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Abstractions;
namespace StingrayNET.Infrastructure.Repository.Modules;

public class PRRepository : BaseRepository<PRResult>, IRepositoryM<PRProcedure, PRResult>
{
    protected override string Query => "stng.SP_PR_CRUD";


    public PRRepository(IDatabase<DED> mssql) : base(mssql)
    {
    }
    public async Task<PRResult> Op_15(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }

    public async Task<PRResult> Op_14(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }

    public async Task<PRResult> Op_13(PRProcedure model = null)
    {
        var result = new PRResult();

        foreach (var solution in model.Solutions)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 26);
            parameters.AddParameter("@APID", SqlDbType.UniqueIdentifier, Guid.Parse(model.APID));
            parameters.AddParameter("@SolutionID", SqlDbType.UniqueIdentifier, Guid.Parse(solution.id));

            List<object> apStrategies = await _ded.ExecuteReaderAsync(Query, parameters);
            if ((solution.value && apStrategies.Count > 0) || (!solution.value && apStrategies.Count == 0))
            {
                continue;
            }
            else if (solution.value)
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 13);
                parameters.AddParameter("@APID", SqlDbType.UniqueIdentifier, Guid.Parse(model.APID));
                parameters.AddParameter("@SolutionID", SqlDbType.UniqueIdentifier, Guid.Parse(solution.id));
                parameters.AddParameter("@CurrentUser", SqlDbType.VarChar, model.CurrentUser);

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
            else
            {
                parameters = new List<SqlParameter>();
                parameters.AddParameter("@Operation", SqlDbType.TinyInt, 14);
                parameters.AddParameter("@APID", SqlDbType.UniqueIdentifier, Guid.Parse(model.APID));
                parameters.AddParameter("@SolutionID", SqlDbType.UniqueIdentifier, Guid.Parse(solution.id));

                result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);
            }
        }
        return result;


    }

    public async Task<PRResult> Op_12(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(12, model);
    }

    public async Task<PRResult> Op_11(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(11, model);
    }

    public async Task<PRResult> Op_10(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(10, model);
    }

    public async Task<PRResult> Op_09(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }

    public async Task<PRResult> Op_08(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }

    public async Task<PRResult> Op_07(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }

    public async Task<PRResult> Op_06(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }

    public async Task<PRResult> Op_05(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }

    public async Task<PRResult> Op_04(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(4, model);
    }

    public Task<PRResult> Op_03(PRProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<PRResult> Op_02(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }

    public async Task<PRResult> Op_01(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }

    public Task<PRResult> Op_30(PRProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<PRResult> Op_29(PRProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<PRResult> Op_28(PRProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<PRResult> Op_27(PRProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<PRResult> Op_26(PRProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<PRResult> Op_25(PRProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<PRResult> Op_24(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(18, model);
    }

    public async Task<PRResult> Op_23(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(25, model);
    }

    public async Task<PRResult> Op_22(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(24, model);
    }

    public async Task<PRResult> Op_21(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(23, model);
    }

    public async Task<PRResult> Op_20(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(22, model);
    }

    public async Task<PRResult> Op_19(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(21, model);
    }

    public async Task<PRResult> Op_18(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(20, model);
    }

    public async Task<PRResult> Op_17(PRProcedure model = null)
    {
        return await ExecuteReader<DED>(19, model);
    }

    public async Task<PRResult> Op_16(PRProcedure model = null)
    {
        return await ExecuteNonQuery<DED>(17, model);
    }
}