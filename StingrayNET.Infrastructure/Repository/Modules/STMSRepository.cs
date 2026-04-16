using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.File;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.STMS;

namespace StingrayNET.Infrastructure.Repository.Modules;

public class STMSRepository : BaseRepository<STMSResult>, IRepositoryS<Procedure, STMSResult>
{
    protected override string Query => "stng.SP_STMS_CRUD";
    private IHttpContextAccessor _httpContextAccessor;
    private readonly IBLOBServiceNew _blobService;

    public STMSRepository(IDatabase<DED> mssql, IHttpContextAccessor httpContextAccessor, IBLOBServiceNew blobService) : base(mssql)
    {
        _httpContextAccessor = httpContextAccessor;
        _blobService = blobService;
    }

    public Task<STMSResult> Op_15(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_14(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_13(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_12(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_11(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_10(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_09(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_08(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_07(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_06(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_05(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_04(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_03(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<STMSResult> Op_02(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public async Task<STMSResult> Op_01(Procedure model = null)
    {
        await _blobService.Upload(_httpContextAccessor.HttpContext, @"STMS", Department.DED);

        return new STMSResult();
    }
}

