using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Escalations;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository.Modules;
public class EscalationRepository : BaseRepository<EscalationResult>, IRepositoryS<EscalationProcedure, EscalationResult>
{
    public EscalationRepository(IDatabase<SC> mssql, IHttpContextAccessor httpContext) : base(mssql)
    {
    }

    protected override string Query => "stng.SP_Escalations_CRUD";

    public async Task<EscalationResult> Op_01(EscalationProcedure model = null)
    {
        return await ExecuteReader<SC>(1, model);
    }

    public async Task<EscalationResult> Op_02(EscalationProcedure model = null)
    {
        // var result = new EscalationResult();
        return await ExecuteReader<SC>(2, model);
        //  var data = await _sc.ExecuteReaderSetAsync(Query, model.GetParameters(2));
        //  result.Data1 = data[0]; // Escalations
        //  result.Data2 = data[1]; // Status Options. TODO: remove-Get on request
        //  result.Data3 = data[2]; // Comments TODO: remove-Get on request
        //  result.Data4 = data[3]; // StatusOptions TODO: remove-Get on request
        //return result;
    }

    public async Task<EscalationResult> Op_03(EscalationProcedure model = null)
    {

        //if(model.UpdateCol == "Scheduled" || model.UpdateCol == "PMCApproval" || model.UpdateCol == "SCApproval")
        //{
        //    model.UpdateCol = Convert.ToBoolean(model.UpdateCol);
        //}
        return await ExecuteNonQuery<SC>(3, model);
    }

    public async Task<EscalationResult> Op_04(EscalationProcedure model = null)
    {
        return await ExecuteReader<SC>(4, model);
    }


    public async Task<EscalationResult> Op_05(EscalationProcedure model = null)
    {
        return await ExecuteReader<SC>(5, model);
    }



    public Task<EscalationResult> Op_06(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_07(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_08(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_09(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_10(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_11(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_12(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_13(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_14(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<EscalationResult> Op_15(EscalationProcedure model = null)
    {
        throw new NotImplementedException();
    }
}