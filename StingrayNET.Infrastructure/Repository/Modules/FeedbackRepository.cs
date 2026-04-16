using Serilog;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Feedback;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class FeedbackRepository : IRepositoryS<FeedbackProcedure, FeedbackResult>
{
    private readonly string _procedure = "stng.SP_Admin_UserFeedback";

    private readonly IDatabase<SC> _mssql;

    public FeedbackRepository(IDatabase<SC> mssql)
    {
        _mssql = mssql;
    }

    public Task<FeedbackResult> Op_15(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_14(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_13(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_12(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_11(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_10(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_09(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_08(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<FeedbackResult> Op_07(FeedbackProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<FeedbackResult> Op_06(FeedbackProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 6);
        parameters.AddParameter("@FeedbackID", System.Data.SqlDbType.Int, model.Num1);
        var result = new FeedbackResult();
        var db = await _mssql.ExecuteReaderSetAsync(_procedure, parameters);
        result.Data1 = db[0]; // files
        result.Data2 = db[1]; // feedbacklist 
        return result;
    }

    public async Task<FeedbackResult> Op_05(FeedbackProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 5);
        parameters.AddParameter("@FeedbackID", System.Data.SqlDbType.Int, model.Num1);
        parameters.AddParameter("@AddressedBy", System.Data.SqlDbType.VarChar, model.Value1);
        var result = new FeedbackResult();
        result.Data1 = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<FeedbackResult> Op_04(FeedbackProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 4);
        parameters.AddParameter("@FeedbackID", System.Data.SqlDbType.Int, model.Num1);
        parameters.AddParameter("@Status", System.Data.SqlDbType.VarChar, model.Value1);
        var result = new FeedbackResult();
        result.Data1 = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<FeedbackResult> Op_03(FeedbackProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 3);
        var result = new FeedbackResult();
        var db = await _mssql.ExecuteReaderSetAsync(_procedure, parameters);
        result.Data1 = db[0]; // users
        result.Data2 = db[1]; // feedbacklist 
        return result;
    }

    public async Task<FeedbackResult> Op_02(FeedbackProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 2);
        parameters.AddParameter("@FeedbackID", System.Data.SqlDbType.Int, model.Num1);
        var result = new FeedbackResult();
        result.Data1 = await _mssql.ExecuteReaderAsync(_procedure, parameters);

        return result;
    }

    public async Task<FeedbackResult> Op_01(FeedbackProcedure model = null)
    {
        var parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", System.Data.SqlDbType.TinyInt, 1);
        parameters.AddParameter("@CurrentUser", System.Data.SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@Module", System.Data.SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@Type", System.Data.SqlDbType.VarChar, model.Value2);
        parameters.AddParameter("@Comment", System.Data.SqlDbType.VarChar, model.Value3);
        parameters.AddParameter("@Version", System.Data.SqlDbType.VarChar, model.Value4);
        parameters.AddParameter("@Resource", System.Data.SqlDbType.Structured, model.Resource);
        var result = new FeedbackResult();
        var db = await _mssql.ExecuteReaderSetAsync(_procedure, parameters);
        result.Data1 = db[0]; // users
        result.Data2 = db[1]; // feedbacklist 
        return result;
    }
}

