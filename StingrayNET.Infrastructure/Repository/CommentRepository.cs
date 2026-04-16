using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Comment;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Repository;

public class CommentRepository : BaseRepository<CommentResult>, IRepositoryS<Procedure, CommentResult>
{
    public CommentRepository(IDatabase<SC> mssql) : base(mssql) { }

    protected override string Query => "stng.SP_Comment_CRUD";

    public async Task<CommentResult> Op_01(Procedure model = null)
    {
        return await ExecuteReader<SC>(1, model);
    }

    public async Task<CommentResult> Op_02(Procedure model = null)
    {
        return await ExecuteNonQuery<SC>(2, model);
    }

    public async Task<CommentResult> Op_03(Procedure model = null)
    {
        return await ExecuteNonQuery<SC>(3, model);
    }

    public async Task<CommentResult> Op_04(Procedure model = null)
    {
        return await ExecuteNonQuery<SC>(4, model);
    }

    public async Task<CommentResult> Op_05(Procedure model = null)
    {
        return await ExecuteReader<SC>(5, model);
    }

    public async Task<CommentResult> Op_06(Procedure model = null)
    {
        return await ExecuteReader<SC>(6, model);
    }

    public Task<CommentResult> Op_07(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_08(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_09(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_10(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_11(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_12(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_13(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_14(Procedure model = null)
    {
        throw new NotImplementedException();
    }

    public Task<CommentResult> Op_15(Procedure model = null)
    {
        throw new NotImplementedException();
    }
}