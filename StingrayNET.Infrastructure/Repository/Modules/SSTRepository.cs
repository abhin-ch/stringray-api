using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.SST;
using StingrayNET.ApplicationCore.Models.File;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class SSTRepository : BaseRepository<SSTResult>, IRepositoryL<SSTProcedure, SSTResult>
{
    protected override string Query => "stng.SP_SST_CRUD";
    private IHttpContextAccessor _httpContextAccessor;
    private readonly IBLOBServiceNew _blobService;

    public SSTRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor, IBLOBServiceNew blobService) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
        _blobService = blobService;
    }

    public async Task<SSTResult> Op_01(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(1, model);
    }
    public async Task<SSTResult> Op_02(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(2, model);
    }
    public async Task<SSTResult> Op_03(SSTProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(3, model);
    }
    public async Task<SSTResult> Op_04(SSTProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReaderValidation<DED>(4, model);
    }
    public async Task<SSTResult> Op_05(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(5, model);
    }
    public async Task<SSTResult> Op_06(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(6, model);
    }
    public async Task<SSTResult> Op_07(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(7, model);
    }
    public async Task<SSTResult> Op_08(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(8, model);
    }
    public async Task<SSTResult> Op_09(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(9, model);
    }
    public async Task<SSTResult> Op_10(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_11(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_12(SSTProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        var result = new SSTResult();

        DataTable SSTIDList = new DataTable();
        SSTIDList.Columns.Add(new DataColumn("UUID", typeof(string)));

        foreach (var SSTID in model.SSTIDList)
        {
            SSTIDList.Rows.Add();

            SSTIDList.Rows[SSTIDList.Rows.Count - 1][0] = SSTID.UUID;

        }

        DataTable cloneIDList = new DataTable();
        cloneIDList.Columns.Add(new DataColumn("UUID", typeof(string)));

        foreach (var cloneID in model.SSTCloneIDList)
        {
            cloneIDList.Rows.Add();

            cloneIDList.Rows[cloneIDList.Rows.Count - 1][0] = cloneID.UUID;

        }

        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.AddParameter("@Operation", SqlDbType.TinyInt, 12);
        parameters.AddParameter("@EmployeeID", SqlDbType.VarChar, model.EmployeeID);
        parameters.AddParameter("@SSTCloneIDList", SqlDbType.Structured, cloneIDList);
        parameters.AddParameter("@SSTIDList", SqlDbType.Structured, SSTIDList);


        result.Data1 = await _ded.ExecuteReaderAsync(Query, parameters);

        return result;
    }
    public async Task<SSTResult> Op_13(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(13, model);
    }
    public async Task<SSTResult> Op_14(SSTProcedure model = null)
    {
        model.EmployeeID = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString();
        return await ExecuteReader<DED>(14, model);
    }
    public async Task<SSTResult> Op_15(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(15, model);
    }
    public async Task<SSTResult> Op_16(SSTProcedure model = null)
    {
        return await ExecuteReader<DED>(16, model);
    }
    public async Task<SSTResult> Op_17(SSTProcedure model = null)
    {
        await _blobService.Upload(_httpContextAccessor.HttpContext, @"SST", Department.DED, true);

        return new SSTResult();
    }
    public async Task<SSTResult> Op_18(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_19(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_20(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_21(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_22(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_23(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_24(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_25(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_26(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_27(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_28(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_29(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_30(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_31(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_32(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_33(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_34(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_35(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_36(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_37(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_38(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_39(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_40(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_41(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_42(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_43(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_44(SSTProcedure model = null) { throw new NotImplementedException(); }
    public async Task<SSTResult> Op_45(SSTProcedure model = null) { throw new NotImplementedException(); }


}

