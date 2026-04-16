using Microsoft.AspNetCore.Http;
using Serilog;
using StingrayNET.ApplicationCore;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.ALR;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Data.SqlClient;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules
{
    public class ALRRepository : IRepositoryS<Procedure, ALRResult>
    {
        private readonly string _procedure = "stng.SP_ALR_CRUD";

        private readonly IDatabase<SC> _mssql;
        private readonly int _userID = 1;

        public ALRRepository(IDatabase<SC> mssql)
        {
            _mssql = mssql;
        }
        public async Task<ALRResult> Op_01(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 1);
            //parameters.AddParameter("@paramtest", SqlDbType.Bit, model.ALRString);
            ALRResult result = new ALRResult();

            result.MainTableData = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_02(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 2);
            parameters.AddParameter("@ParentID", SqlDbType.BigInt, model.Num1);
            parameters.AddParameter("@SourceName", SqlDbType.VarChar, model.Value1);

            ALRResult result = new ALRResult();

            result.UserAssignment = await _mssql.ExecuteReaderAsync(_procedure, parameters);

            return result;
        }

        public async Task<ALRResult> Op_03(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 3);
            parameters.AddParameter("@ParentID", SqlDbType.BigInt, model.Num1);

            ALRResult result = new ALRResult();
            result.Comments = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_04(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 4);
            parameters.AddParameter("@ParentID", SqlDbType.BigInt, model.Num1);
            parameters.AddParameter("@SourceName", SqlDbType.VarChar, model.Value1);

            ALRResult result = new ALRResult();
            result.WorkOrders = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_05(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 5);
            parameters.AddParameter("@ParentID", SqlDbType.BigInt, model.Num1);
            parameters.AddParameter("@SourceName", SqlDbType.VarChar, model.Value1);

            ALRResult result = new ALRResult();
            result.RelatedItems = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_06(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 6);
            parameters.AddParameter("@ParentID", SqlDbType.BigInt, model.Num1);

            ALRResult result = new ALRResult();
            result.Activities = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_07(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 7);
            parameters.AddParameter("@ParentID", SqlDbType.BigInt, model.Num1);
            parameters.AddParameter("@SourceName", SqlDbType.VarChar, model.Value1);

            ALRResult result = new ALRResult();
            result.TabRowCounts = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_08(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 8);
            parameters.AddParameter("@ParentID", SqlDbType.BigInt, model.Num1);
            parameters.AddParameter("@UserID", SqlDbType.TinyInt, _userID);
            parameters.AddParameter("@SourceName", SqlDbType.VarChar, model.Value1);
            parameters.AddParameter("@Deliverable", SqlDbType.VarChar, model.Value2);
            parameters.AddParameter("@AStatus", SqlDbType.VarChar, model.Value3);
            parameters.AddParameter("@Hour", SqlDbType.BigInt, model.Num2);
            parameters.AddParameter("@UserIDAssigned", SqlDbType.BigInt, model.Num3);

            ALRResult result = new ALRResult();
            result.UserAssignment = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_09(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 9);
            parameters.AddParameter("@ADID", SqlDbType.BigInt, model.Num1);
            parameters.AddParameter("@UserID", SqlDbType.TinyInt, _userID);
            parameters.AddParameter("@Deliverable", SqlDbType.VarChar, model.Value1);
            parameters.AddParameter("@AStatus", SqlDbType.VarChar, model.Value2);
            parameters.AddParameter("@Hour", SqlDbType.BigInt, model.Num2);
            parameters.AddParameter("@UserIDAssigned", SqlDbType.BigInt, model.Num3);

            ALRResult result = new ALRResult();
            result.UserAssignment = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public async Task<ALRResult> Op_10(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 10);
            parameters.AddParameter("@ADID", SqlDbType.BigInt, model.Num1);
            parameters.AddParameter("@UserID", SqlDbType.TinyInt, _userID);

            ALRResult result = new ALRResult();
            result.UserAssignment = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }

        public Task<ALRResult> Op_11(Procedure model = null)
        {
            throw new NotImplementedException();
        }

        public async Task<ALRResult> Op_12(Procedure model = null)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.AddParameter("@Operation", SqlDbType.TinyInt, 12);

            ALRResult result = new ALRResult();
            result.PossibleAssignments = await _mssql.ExecuteReaderAsync(_procedure, parameters);
            return result;
        }
        public Task<ALRResult> Op_13(Procedure model = null)
        {
            throw new NotImplementedException();
        }

        public Task<ALRResult> Op_14(Procedure model = null)
        {
            throw new NotImplementedException();
        }

        public Task<ALRResult> Op_15(Procedure model = null)
        {
            throw new NotImplementedException();
        }

        public Task<ALRResult> Op_16(Procedure model = null)
        {
            throw new NotImplementedException();
        }


    }
}
