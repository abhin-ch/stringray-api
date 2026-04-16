using Serilog;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Models.Catalog;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;
public class CatalogRepository : IRepositoryS<Procedure, CatalogResult>
{
    private readonly string _procedure = "stng.SP_Catalog_CRUD";

    private readonly IDatabase<SC> _mssql;

    public CatalogRepository(IDatabase<SC> mssql)
    {
        _mssql = mssql;
    }
    public async Task<CatalogResult> Op_01(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 1);
        CatalogResult result = new CatalogResult();

        result.Data = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<CatalogResult> Op_02(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 2);
        parameters.AddParameter("@EmployeeID", SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@Value1", SqlDbType.VarChar, model.Value1); // RequestorID
        parameters.AddParameter("@Value6", SqlDbType.VarChar, model.Value6); // ReasonForAccess
        parameters.AddParameter("@ID1", SqlDbType.Int, model.Num1); // ModuleID

        var result = new CatalogResult();
        result.Data1 = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<CatalogResult> Op_03(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 3);

        var result = new CatalogResult();
        result.Data = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public async Task<CatalogResult> Op_04(Procedure model = null)
    {
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Value1", SqlDbType.VarChar, model.Value1);
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 4);
        CatalogResult result = new CatalogResult();

        result.Data = await _mssql.ExecuteReaderAsync(_procedure, parameters);
        return result;
    }

    public Task<CatalogResult> Op_05(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_06(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_07(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_08(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_09(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_10(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_11(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_12(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_13(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_14(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CatalogResult> Op_15(Procedure model = null)
    {
        throw new NotImplementedException();
    }


}
