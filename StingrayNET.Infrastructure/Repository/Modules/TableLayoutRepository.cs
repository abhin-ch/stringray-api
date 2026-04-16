using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models.TableLayout;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class TableLayoutRepository : IRepositoryS<Procedure, TableLayoutResult>
{
    private readonly string _procedure = "stng.SP_App_TableLayout_CRUD";

    private readonly IDatabase<SC> _mssql;

    public TableLayoutRepository(IDatabase<SC> mssql)
    {
        _mssql = mssql;
    }
    public async Task<TableLayoutResult> Op_01(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 1);
        parameters.AddParameter("@ModuleName", SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@EmployeeID", SqlDbType.VarChar, model.EmployeeID);
        TableLayoutResult result = new TableLayoutResult();
        result.Layout = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<TableLayoutResult> Op_02(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 2);
        parameters.AddParameter("@TableLayoutID", SqlDbType.Int, model.Num1);
        TableLayoutResult result = new TableLayoutResult();
        result.Layout = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }


    public async Task<TableLayoutResult> Op_03(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 3);
        parameters.AddParameter("@ModuleName", SqlDbType.VarChar, model.Value3);
        parameters.AddParameter("@EmployeeID", SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@LayoutName", SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@JSONLiteral", SqlDbType.VarChar, model.Value2);
        TableLayoutResult result = new TableLayoutResult();

        result.Layout = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<TableLayoutResult> Op_04(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 4);
        parameters.AddParameter("@TableLayoutID", SqlDbType.Int, model.Num1);
        parameters.AddParameter("@LayoutName", SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@JSONLiteral", SqlDbType.VarChar, model.Value2);

        TableLayoutResult result = new TableLayoutResult();

        result.Layout = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<TableLayoutResult> Op_05(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 5);
        parameters.AddParameter("@TableLayoutID", SqlDbType.Int, model.Num1);

        TableLayoutResult result = new TableLayoutResult();

        result.Layout = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }
    public async Task<TableLayoutResult> Op_06(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 6);
        parameters.AddParameter("@TableLayoutID", SqlDbType.Int, model.Num1);
        parameters.AddParameter("@ShareUserID", SqlDbType.Int, model.Num2);
        parameters.AddParameter("@EmployeeID", SqlDbType.VarChar, model.EmployeeID);
        TableLayoutResult result = new TableLayoutResult();

        result.LayoutShare = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }
    public async Task<TableLayoutResult> Op_07(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 7);
        parameters.AddParameter("@ModuleName", SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@EmployeeID", SqlDbType.VarChar, model.EmployeeID);
        TableLayoutResult result = new TableLayoutResult();
        result.ShareList = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }
    public Task<TableLayoutResult> Op_08(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_09(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_10(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_11(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_12(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_13(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_14(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_15(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<TableLayoutResult> Op_16(Procedure model = null)
    {
        throw new NotImplementedException();
    }


}
