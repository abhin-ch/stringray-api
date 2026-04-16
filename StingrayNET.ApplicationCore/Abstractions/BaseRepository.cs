using StingrayNET.ApplicationCore.Specifications;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using StingrayNET.ApplicationCore.CustomExceptions;
using System.Linq;
using StingrayNET.ApplicationCore.Interfaces;

namespace StingrayNET.ApplicationCore.Abstractions;

public abstract class BaseRepository<K> where K : BaseOperation, new()
{
    protected abstract string Query { get; }
    protected readonly IDatabase<SC> _sc = null!;
    protected readonly IDatabase<DED> _ded = null!;

    public BaseRepository(IDatabase<SC> mssql)
    {
        _sc = mssql;
    }
    public BaseRepository(IDatabase<DED> mssql)
    {
        _ded = mssql;
    }
    public BaseRepository(IDatabase<SC> sc, IDatabase<DED> ded)
    {
        _sc = sc;
        _ded = ded;
    }
    public BaseRepository(IDatabase<DED> ded, IDatabase<SC> sc)
    {
        _sc = sc;
        _ded = ded;
    }

    public async Task<K> ExecuteReaderValidation<D>(int operation, BaseProcedure model = null!,
        string validationMessageFieldName = @"ReturnMessage",
        bool throwValidationException = true,
        bool throwUnauthorizedException = true, string unauthorizedMessageFieldName = @"ReturnMessageUnauthorized") where D : IDepartment
    {
        var returnReader = await ExecuteReader<D>(operation, model);

        if (returnReader is BaseOperation)
        {
            BaseOperation returnReaderCast = returnReader;

            if (returnReaderCast.Data1.Count > 0)
            {
                Dictionary<string, object> returnReaderData = (Dictionary<string, object>)returnReaderCast.Data1[0];

                if (returnReaderData.Where(x => x.Key == validationMessageFieldName && x.Value != null).Count() > 0 && throwValidationException)
                {

                    throw new ValidationException(returnReaderData[validationMessageFieldName].ToString());

                }

                else if (returnReaderData.Where(x => x.Key == unauthorizedMessageFieldName && x.Value != null).Count() > 0 && throwUnauthorizedException)
                {
                    throw new UnauthorizedException(returnReaderData[unauthorizedMessageFieldName].ToString());
                }

            }
        }

        return returnReader;

    }

    public async Task<K> ExecuteReader<D>(int operation, BaseProcedure model = null!, string? query = null!) where D : IDepartment
    {
        return await ExecuteReaderSet<D>(operation, model, query);
    }

    public async Task<K> ExecuteNonQuery<D>(int operation, BaseProcedure model = null!, string? query = null!) where D : IDepartment
    {
        K result = new K();
        var type = typeof(D);


        if (string.IsNullOrEmpty(Query)) throw new ArgumentNullException("Query property inside repository is empty.");
        switch (type.Name)
        {
            case nameof(DED):
                {
                    result.RowsAffected = await _ded.ExecuteNonQueryAsync(query ?? Query, model != null ? model.GetParameters(operation) : BaseProcedure.SetOperation(operation));
                    break;
                }
            case nameof(SC):
                {
                    result.RowsAffected = await _sc.ExecuteNonQueryAsync(query ?? Query, model != null ? model.GetParameters(operation) : BaseProcedure.SetOperation(operation));
                    break;
                }
        }
        return result;

    }

    private async Task<K> ExecuteReaderSet<D>(int operation, BaseProcedure model = null!, string? query = null!) where D : IDepartment
    {
        K result = new K();
        var type = typeof(D);

        if (string.IsNullOrEmpty(Query)) throw new ArgumentNullException("Query property inside repository is empty.");
        IReadOnlyDictionary<int, List<object>> data = null!;
        switch (type.Name)
        {
            case nameof(DED):
                {
                    data = await _ded.ExecuteReaderSetAsync(query ?? Query, model != null ? model.GetParameters(operation) : BaseProcedure.SetOperation(operation));
                    break;

                }
            case nameof(SC):
                {
                    data = await _sc.ExecuteReaderSetAsync(query ?? Query, model != null ? model.GetParameters(operation) : BaseProcedure.SetOperation(operation));
                    break;

                }
        }
        for (int i = 0; i < data?.Count; i++)
        {
            switch (i)
            {
                case 0:
                    {
                        result.Data1 = data[i];
                        break;
                    }
                case 1:
                    {
                        result.Data2 = data[i];
                        break;
                    }
                case 2:
                    {
                        result.Data3 = data[i];
                        break;
                    }
                case 3:
                    {
                        result.Data4 = data[i];
                        break;
                    }
            }
        }

        return result;

    }

}