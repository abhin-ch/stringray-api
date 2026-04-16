using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models.SORT;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class SORTRepository : IRepositoryS<SORTProcedure, SORTResult>
{
    private readonly string _procedure = "stng.SP_SORT_CRUD";

    private readonly IDatabase<SC> _mssql;

    public SORTRepository(IDatabase<SC> mssql)
    {
        _mssql = mssql;
    }
    public async Task<SORTResult> Op_01(SORTProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 1);
        parameters.AddParameter("@CurrentUser", System.Data.SqlDbType.VarChar, model.EmployeeID);
        SORTResult result = new SORTResult();
        result.Data1 = await _mssql.ExecuteReaderAsync(_procedure, parameters);

        return result;
    }

    public async Task<SORTResult> Op_02(SORTProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 2);
        parameters.AddParameter("@CurrentUser", System.Data.SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@PK_ID", System.Data.SqlDbType.VarChar, model.Value1);
        var result = new SORTResult();
        var data = await _mssql.ExecuteReaderSetAsync(_procedure, parameters);
        result.Data1 = data[0]; // scopeline
        result.Data2 = data[1]; // line records
        result.Data3 = data[2]; // commitments
        result.Data4 = data[3]; // tags
        return result;
    }

    public async Task<SORTResult> Op_03(SORTProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 3);
        parameters.AddParameter("@CurrentUser", System.Data.SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@PK_ID", System.Data.SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@Category", System.Data.SqlDbType.VarChar, model.Value2);
        parameters.AddParameter("@Estimated", System.Data.SqlDbType.VarChar, model.Value3);
        parameters.AddParameter("@Actualized", System.Data.SqlDbType.VarChar, model.Value4);
        parameters.AddParameter("@Type", System.Data.SqlDbType.TinyInt, model.Num1);
        parameters.AddParameter("@Probability", System.Data.SqlDbType.TinyInt, model.Num2);
        parameters.AddParameter("@Tags", System.Data.SqlDbType.Structured, model.Tags);
        SORTResult result = new SORTResult();
        result.Data1 = await _mssql.ExecuteReaderAsync(_procedure, parameters);

        return result;
    }

    public async Task<SORTResult> Op_04(SORTProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 4);
        parameters.AddParameter("@CurrentUser", System.Data.SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@FK_ProjectID", System.Data.SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@PK_ID", System.Data.SqlDbType.VarChar, model.Value2);
        parameters.AddParameter("@UpdateVal", System.Data.SqlDbType.VarChar, model.Value3);
        parameters.AddParameter("@UpdateCol", System.Data.SqlDbType.VarChar, model.Value4);

        var result = new SORTResult();
        result.RowsAffected = await _mssql.ExecuteNonQueryAsync(_procedure, parameters);
        return result;
    }

    public async Task<SORTResult> Op_05(SORTProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 5);
        parameters.AddParameter("@CurrentUser", System.Data.SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@FK_ProjectID", System.Data.SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@PK_ID", System.Data.SqlDbType.VarChar, model.Value2);
        parameters.AddParameter("@Tags", System.Data.SqlDbType.Structured, model.Tags);
        var result = new SORTResult();
        result.RowsAffected = await _mssql.ExecuteNonQueryAsync(_procedure, parameters);

        return result;
    }

    public Task<SORTResult> Op_06(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_07(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_08(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_09(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_10(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_11(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_12(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_13(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_14(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<SORTResult> Op_15(SORTProcedure model = null)
    {
        throw new NotImplementedException();
    }
}

